import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../../polar/presentation/bloc/polar_state.dart';

/// Centralizes the copy shown once baseline capture ends, so "saved"
/// language can never appear when nothing was actually persisted — this
/// used to always say "Baseline saved" even when the bpm shown was a
/// hardcoded fallback. Extracted as a top-level function so the exact
/// wording is unit-testable without pumping a widget tree (this repo's
/// existing tests are all bloc/unit-level, not widget-level).
@visibleForTesting
({String heading, String cardTitle, String cardBody}) resolveBaselineResultCopy(
  bool hasReading,
) {
  if (hasReading) {
    return (
      heading: 'Your resting heart rate is',
      cardTitle: 'Baseline saved',
      cardBody: 'This is your personal baseline. We\'ll use it to\n'
          'detect when stress affects your performance\n'
          'during competition and training.',
    );
  }
  return (
    heading: "We couldn't get a reading",
    cardTitle: 'No baseline captured',
    cardBody: 'We didn\'t get a heart rate reading from your Polar '
        'device in time, so no baseline was saved.',
  );
}

class BaselineResultScreen extends StatelessWidget {
  const BaselineResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PolarBloc>(),
      child: const _BaselineResultView(),
    );
  }
}

class _BaselineResultView extends StatelessWidget {
  const _BaselineResultView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolarBloc, PolarState>(
      builder: (context, state) {
        // No fallback value: this used to default to a hardcoded 76 and
        // both display it and POST it to the backend as if it were a real
        // measurement whenever Polar hadn't produced a reading yet. A
        // missing reading is now shown and handled honestly instead.
        final bpm = state.latestReading?.bpm;
        final hasReading = bpm != null;
        final copy = resolveBaselineResultCopy(hasReading);

        return Scaffold(
          backgroundColor: DSColors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 196, 24, 24),
                    child: Column(
                      children: [
                        _SuccessMark(hasReading: hasReading),
                        const SizedBox(height: 46),
                        Text(
                          copy.heading,
                          textAlign: TextAlign.center,
                          style: DSTypography.headingLg.copyWith(
                            color: const Color(0xFF000F12),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          bpm?.toString() ?? '—',
                          textAlign: TextAlign.center,
                          style: DSTypography.scoreDisplay.copyWith(
                            color: hasReading
                                ? const Color(0xFF15803D)
                                : DSColors.textSecondary,
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'BPM',
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.textSecondary,
                            fontSize: 16,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 46),
                        _SavedCard(hasReading: hasReading, copy: copy),
                      ],
                    ),
                  ),
                ),
                _ResultFooter(
                  onPressed: () async {
                    // Only persist a real reading — never the athlete's
                    // absence of one — so hamsatech.athlete_physiology
                    // never receives a fabricated resting_hr value.
                    if (hasReading) {
                      final athleteId = AuthHelper.getCurrentAthleteId();
                      if (athleteId != null) {
                        try {
                          await ApiService.instance.saveBaselineHR(
                            athleteId: athleteId,
                            restingHr: bpm,
                          );
                          debugPrint('[BASELINE] resting HR=$bpm saved');
                        } catch (e) {
                          debugPrint('[BASELINE] save failed (non-fatal): $e');
                        }
                      }
                    }
                    await StorageService.setOnboardingComplete(true);
                    if (context.mounted) context.go('/alex-summary');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark({required this.hasReading});

  final bool hasReading;

  @override
  Widget build(BuildContext context) {
    final color = hasReading ? const Color(0xFF15803D) : DSColors.textSecondary;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: hasReading ? const Color(0xFFECFDF5) : DSColors.gray100,
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            hasReading ? Icons.check_rounded : Icons.priority_high_rounded,
            color: color,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.hasReading, required this.copy});

  final bool hasReading;
  final ({String heading, String cardTitle, String cardBody}) copy;

  @override
  Widget build(BuildContext context) {
    final accent =
        hasReading ? const Color(0xFF15803D) : DSColors.textSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: hasReading ? const Color(0xFFF0FDF4) : DSColors.gray100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.cardTitle,
            style: DSTypography.headingMd.copyWith(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            copy.cardBody,
            style: DSTypography.bodyMedium.copyWith(
              color: hasReading ? const Color(0xFF166534) : accent,
              fontSize: 14,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: const BoxDecoration(
        color: DSColors.white,
        border: Border(top: BorderSide(color: DSColors.gray200)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DSColors.terracotta,
            foregroundColor: DSColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Continue',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
