import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../../../live_training/domain/entities/session_mood.dart';

const _kTeal = Color(0xFF2F7E8F);

/// Why a reflection save attempt failed — drives which message is shown.
/// Distinct from a generic "check your connection" for every case: a
/// missing session, an expired token, and an actual dropped connection are
/// different problems with different fixes, and telling the athlete the
/// wrong one sends them (and whoever debugs it later) down the wrong path.
enum ReflectionSaveErrorKind {
  missingSessionId,
  unauthorized,
  forbidden,
  notFound,
  validation,
  serverError,
  timeout,
  network,
  unknown,
}

/// Maps a caught error from the save attempt to why it failed. Pure and
/// side-effect-free so it can be unit-tested directly, same as
/// [resolveReflectionIdentity] below.
@visibleForTesting
ReflectionSaveErrorKind classifyReflectionSaveError(Object error) {
  if (error is StateError) return ReflectionSaveErrorKind.missingSessionId;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ReflectionSaveErrorKind.timeout;
      case DioExceptionType.badResponse:
        return switch (error.response?.statusCode) {
          401 => ReflectionSaveErrorKind.unauthorized,
          403 => ReflectionSaveErrorKind.forbidden,
          404 => ReflectionSaveErrorKind.notFound,
          422 => ReflectionSaveErrorKind.validation,
          final status? when status >= 500 =>
            ReflectionSaveErrorKind.serverError,
          _ => ReflectionSaveErrorKind.network,
        };
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ReflectionSaveErrorKind.network;
    }
  }
  return ReflectionSaveErrorKind.unknown;
}

/// The message shown for each [ReflectionSaveErrorKind]. Timeout's message
/// deliberately avoids claiming the reflection was lost — the backend save
/// is an upsert (safe to retry), so tapping Save & Continue again is a real
/// retry, not a guaranteed duplicate or guaranteed no-op.
@visibleForTesting
String reflectionSaveErrorMessage(ReflectionSaveErrorKind kind) =>
    switch (kind) {
      ReflectionSaveErrorKind.missingSessionId =>
        'No active session found for this reflection. Please restart the session.',
      ReflectionSaveErrorKind.unauthorized =>
        'Your session has expired. Please log in again.',
      ReflectionSaveErrorKind.forbidden =>
        "You don't have permission to save this reflection.",
      ReflectionSaveErrorKind.notFound => 'This session could not be found.',
      ReflectionSaveErrorKind.validation =>
        "Some of your reflection details couldn't be saved. Please check your entries.",
      ReflectionSaveErrorKind.serverError =>
        'Something went wrong on our end. Please try again shortly.',
      ReflectionSaveErrorKind.timeout =>
        "The request took too long, so we're not sure it saved. Tap Save & Continue to retry.",
      ReflectionSaveErrorKind.network =>
        'Could not reach the server. Check your connection and try again.',
      ReflectionSaveErrorKind.unknown =>
        'Could not save your reflection. Please try again.',
    };

/// A short, token-free summary of a caught error for logging — never the
/// raw response body/headers (which could carry the Authorization header
/// or free-text reflection content), just enough to diagnose from logs.
String _safeErrorSummary(Object error) {
  if (error is DioException) {
    return '${error.type.name}: ${error.message ?? "no message"}';
  }
  return error.runtimeType.toString();
}

/// Resolves the session_id and athlete_id needed to save a reflection, or
/// throws if either is missing. By the time an athlete reaches this screen,
/// a session has already been created and scored, so — unlike some earlier
/// onboarding-adjacent flows — a missing identity here is a genuine error
/// to surface, not a silent no-op: this mirrors the same "must fail loudly"
/// rule LiveTrainingRepositoryImpl.saveReflection already enforces on the
/// Polar path. Extracted as a top-level function (rather than inline in the
/// State) so it can be unit-tested without pumping a widget tree.
@visibleForTesting
({String sessionId, String athleteId}) resolveReflectionIdentity() {
  final sessionId = SessionMemory.sessionId ?? StorageService.getSessionId();
  if (sessionId == null) {
    throw StateError('No active session to save reflection for.');
  }
  final athleteId = AuthHelper.getCurrentAthleteId();
  if (athleteId == null) {
    throw StateError('Cannot save reflection: no athlete_id available.');
  }
  return (sessionId: sessionId, athleteId: athleteId);
}

class SessionReflectionScreen extends StatefulWidget {
  const SessionReflectionScreen({super.key});

  @override
  State<SessionReflectionScreen> createState() =>
      _SessionReflectionScreenState();
}

class _SessionReflectionScreenState extends State<SessionReflectionScreen> {
  int? _selectedMood;
  bool _isSubmitting = false;
  String? _submitError;

  final _whatWorkedController = TextEditingController();
  final _whatDidntController = TextEditingController();
  final _wentWellController = TextEditingController();
  final _improveController = TextEditingController();
  final _observationsController = TextEditingController();

  @override
  void dispose() {
    _whatWorkedController.dispose();
    _whatDidntController.dispose();
    _wentWellController.dispose();
    _improveController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  // This screen is reached only from the non-Polar scoring path
  // (score_entry_screen.dart) — the Polar path's equivalent, ReflectScreen,
  // already saves reflection through LiveTrainingBloc/saveReflection. Until
  // now this screen had no bloc, repository, or API call at all: every
  // mood/text-field entry made here was discarded on dispose. This wires it
  // to the same POST .../reflection endpoint, using the same mood scale
  // (SessionMood.rating, 1-5) so both entry points persist identically.
  //
  // The three extra fields below "What Worked"/"What Didn't" ("What went
  // well today?", "What to improve next time?", "Any observations?") have
  // no corresponding backend field on the existing reflection endpoint, so
  // — matching the exact endpoint named for this fix, unchanged — they
  // remain local-only, same as before this change.
  Future<void> _onSaveAndContinue() async {
    if (_isSubmitting) return;

    // Verify a session to save against exists before attempting the network
    // call at all — a missing session is a distinct, immediately-knowable
    // failure, not something worth a request round-trip to discover.
    final ({String sessionId, String athleteId}) identity;
    try {
      identity = resolveReflectionIdentity();
    } catch (e) {
      debugPrint(
          '[REFLECTION SAVE] failed — kind=missingSessionId sessionIdPresent=false');
      setState(() {
        _submitError = reflectionSaveErrorMessage(
            ReflectionSaveErrorKind.missingSessionId);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final mood =
        _selectedMood == null ? null : SessionMood.values[_selectedMood!];
    final stopwatch = Stopwatch()..start();
    try {
      final response = await ApiService.instance.saveReflection(
        athleteId: identity.athleteId,
        sessionId: identity.sessionId,
        mood: mood?.rating,
        whatWorked: _whatWorkedController.text.trim(),
        whatDidnt: _whatDidntController.text.trim(),
      );
      stopwatch.stop();
      debugPrint(
          '[REFLECTION SAVE] success — url=${response.requestOptions.uri} status=${response.statusCode} '
          'elapsedMs=${stopwatch.elapsedMilliseconds} sessionIdPresent=true');

      // Dio's default validateStatus only returns (never throws) for a 2xx
      // response, so reaching here at all already means the request
      // succeeded — navigate only now that the response has actually arrived.
      if (!mounted) return;
      context.go('/session/summary');
    } catch (e) {
      stopwatch.stop();
      final kind = classifyReflectionSaveError(e);
      final url = e is DioException ? e.requestOptions.uri : null;
      final status = e is DioException ? e.response?.statusCode : null;
      debugPrint(
          '[REFLECTION SAVE] failed — kind=$kind url=$url status=$status '
          'elapsedMs=${stopwatch.elapsedMilliseconds} sessionIdPresent=true error=${_safeErrorSummary(e)}');

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = reflectionSaveErrorMessage(kind);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DSColors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.xs, DSSpacing.xl, DSSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Text(
                    'Reflect',
                    style: DSTypography.headingXl.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    'A few quick questions to choose the loop',
                    style: DSTypography.bodySm
                        .copyWith(color: DSColors.textSecondary),
                  ),

                  // ── Mood ──────────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xxl),
                  Text(
                    'How did it feel?',
                    style: DSTypography.bodyLg.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  _MoodSelector(
                    selectedIndex: _selectedMood,
                    onSelected: (i) => setState(() => _selectedMood = i),
                  ),

                  // ── Text areas ────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xxl),
                  _ReflectionField(
                    label: 'What Worked',
                    hint: 'Write your message here...',
                    controller: _whatWorkedController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: "What Didn't",
                    hint: 'Write your message here...',
                    controller: _whatDidntController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'What went well today?',
                    hint: 'Text area for athlete input',
                    controller: _wentWellController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'What to improve next time?',
                    hint: 'Text area for athlete input',
                    controller: _improveController,
                  ),
                  const SizedBox(height: DSSpacing.xl),
                  _ReflectionField(
                    label: 'Any observations?',
                    hint: 'Text area for athlete input',
                    controller: _observationsController,
                  ),

                  // ── Voice note ────────────────────────────────────────────
                  const SizedBox(height: DSSpacing.xl),
                  const _VoiceNoteButton(),
                ],
              ),
            ),
          ),

          // ── Fixed bottom CTA ──────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: DSColors.gray200),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_submitError != null) ...[
                    Text(
                      _submitError!,
                      style:
                          DSTypography.bodySm.copyWith(color: DSColors.error),
                    ),
                    const SizedBox(height: DSSpacing.sm),
                  ],
                  DSPrimaryButton(
                    label: 'Save & View Summary',
                    color: _kTeal,
                    isLoading: _isSubmitting,
                    onPressed: _onSaveAndContinue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood selector
// ─────────────────────────────────────────────────────────────────────────────

class _MoodData {
  const _MoodData(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  static const _moods = [
    _MoodData('😫', 'Trouble'),
    _MoodData('🥺', 'Poor'),
    _MoodData('😐', 'Okay'),
    _MoodData('🙂', 'Good'),
    _MoodData('😄', 'Great'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        _moods.length,
        (i) => _MoodItem(
          mood: _moods[i],
          isSelected: selectedIndex == i,
          onTap: () => onSelected(i),
        ),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  const _MoodItem({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final _MoodData mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? _kTeal.withValues(alpha: 0.10)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _kTeal : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            mood.label,
            style: DSTypography.labelXs.copyWith(
              color: isSelected ? _kTeal : DSColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reflection text field
// ─────────────────────────────────────────────────────────────────────────────

class _ReflectionField extends StatelessWidget {
  const _ReflectionField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DSTypography.bodyLg.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          textCapitalization: TextCapitalization.sentences,
          style: DSTypography.bodyMd.copyWith(color: DSColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                DSTypography.bodyMd.copyWith(color: DSColors.textPlaceholder),
            filled: true,
            fillColor: DSColors.white,
            contentPadding: const EdgeInsets.all(DSSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: DSColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: DSColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DSRadius.borderMd,
              borderSide: const BorderSide(color: _kTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice note button
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceNoteButton extends StatelessWidget {
  const _VoiceNoteButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DSColors.white,
          borderRadius: DSRadius.borderMd,
          border: Border.all(color: DSColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_none_rounded, color: _kTeal, size: 20),
            const SizedBox(width: DSSpacing.sm),
            Text(
              'Add Voice note',
              style: DSTypography.bodyMd.copyWith(
                color: _kTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
