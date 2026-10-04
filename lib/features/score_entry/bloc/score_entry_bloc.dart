import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../domain/repositories/score_entry_repository.dart';
import 'score_entry_event.dart';
import 'score_entry_state.dart';

class ScoreEntryBloc extends Bloc<ScoreEntryEvent, ScoreEntryState> {
  ScoreEntryBloc({required ScoreEntryRepository repository})
      : _repository = repository,
        super(const ScoreEntryInitial()) {
    on<ScoreEntryStartRequested>(_onStart);
    on<SeriesTotalSubmitted>(_onTotalSubmitted);
    on<ScoreEntryUndoLast>(_onUndo);
    on<ScoreEntryFinalConfirmed>(_onFinalConfirmed);
    // Legacy event stubs — registered to prevent unhandled-event errors
    // if any old code path still dispatches them.
    on<ScoreScoreSelected>((_, __) {});
    on<ScoreEntrySeriesConfirmed>((_, __) {});
    on<ScoreEntryEditRequested>((_, __) {});
    on<ScoreEntryVoiceInputRequested>((_, __) {});
  }

  final ScoreEntryRepository _repository;

  void _onStart(ScoreEntryStartRequested event, Emitter<ScoreEntryState> emit) {
    if (state is ScoreEntryActiveState) return;
    final config = _repository.getConfig();
    emit(ScoreEntryActiveState(
      sessionTitle: config.sessionTitle,
      totalSeries: config.totalSeries,
      shotsPerSeries: config.shotsPerSeries,
      enteredTotals: const [],
    ));
  }

  void _onTotalSubmitted(
      SeriesTotalSubmitted event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState || s.isComplete) return;
    emit(s.copyWith(enteredTotals: [...s.enteredTotals, event.total]));
  }

  void _onUndo(ScoreEntryUndoLast event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState || !s.canUndo) return;
    final updated = s.enteredTotals.sublist(0, s.enteredTotals.length - 1);
    emit(s.copyWith(enteredTotals: updated));
  }

  Future<void> _onFinalConfirmed(
      ScoreEntryFinalConfirmed event, Emitter<ScoreEntryState> emit) async {
    final s = state;
    if (s is! ScoreEntryActiveState || !s.isComplete || s.isSubmitting) {
      return;
    }

    emit(s.copyWith(isSubmitting: true, clearSubmitError: true));

    await _repository.saveTotals(s.enteredTotals, s.shotsPerSeries);

    // Awaited and validated — a prior version of this method fired these
    // off unawaited and reported success unconditionally, so an athlete
    // could be told "saved" and navigated to the reflection/summary screens
    // before the series/score/completion calls had even resolved, with any
    // failure only reaching a debug log.
    final seriesOk = await _syncSeries(s);
    final sessionOk = await _syncSessionEnd(s);

    // session_post_log is now solely owned by ReflectScreen's
    // saveReflection() call, earlier in the flow — no longer synced here.
    //
    // SessionMemory is deliberately left set (not cleared here): on the
    // non-Polar path, SessionReflectionScreen is reached right after this
    // and needs SessionMemory.sessionId ?? StorageService.getSessionId() to
    // still resolve to this session. StorageService's copy is already gone
    // by this point — LiveTrainingRepositoryImpl.startSession() consumes
    // and clears it as soon as the live/score flow begins — so SessionMemory
    // is the only surviving source; clearing it here left the reflection
    // screen with nothing to read (`resolveReflectionIdentity` throwing
    // "No active session"). SessionSetupBloc overwrites SessionMemory
    // unconditionally the next time a new session is created, so leaving a
    // stale value here between sessions is harmless.
    if (seriesOk && sessionOk) {
      emit(const ScoreEntrySavedState());
    } else {
      emit(s.copyWith(
        isSubmitting: false,
        submitError:
            'Could not save your scores. Check your connection and try again.',
      ));
    }
  }

  // ── Mobile backend: per-series sync ──────────────────────────────────────────

  /// Returns true if every series saved successfully, or if there was
  /// nothing to sync yet (no session/athlete_id resolved — e.g. onboarding
  /// incomplete). Only an actual failed save call counts as false; this
  /// method validates calls it attempts, it does not newly penalize the
  /// pre-existing "nothing to sync yet" case.
  Future<bool> _syncSeries(ScoreEntryActiveState s) async {
    final sessionId = SessionMemory.sessionId ?? StorageService.getSessionId();
    final athleteId = AuthHelper.getCurrentAthleteId();

    if (sessionId == null || athleteId == null) {
      debugPrint(
          '[SERIES SYNC] skipped — sessionId=$sessionId athleteId=$athleteId');
      return true;
    }

    var allSucceeded = true;
    for (var i = 0; i < s.enteredTotals.length; i++) {
      try {
        final res = await ApiService.instance.saveSeries(
          athleteId: athleteId,
          sessionId: sessionId,
          seriesNumber: i + 1,
          totalScore: s.enteredTotals[i],
          shotsFired: s.shotsPerSeries,
        );
        debugPrint(
            '[SERIES SYNC] series ${i + 1} saved status=${res.statusCode}');
      } catch (e) {
        _logApiError('SERIES SYNC [${i + 1}]', e);
        allSucceeded = false;
        // Still attempt the remaining series even after one fails, but the
        // overall result reported back is failure.
      }
    }
    return allSucceeded;
  }

  /// Returns true if the canonical completion and score-save calls both
  /// succeeded (or were skipped because there's nothing to sync yet — no
  /// session/athlete_id resolved). The legacy Supabase end_time patch
  /// (Step 2) remains best-effort and does not gate this result — the
  /// canonical /complete call in Step 1 is what actually records completion.
  Future<bool> _syncSessionEnd(ScoreEntryActiveState s) async {
    // Prefer in-memory value; fall back to SharedPreferences for restart recovery.
    final supabaseSessionId =
        SessionMemory.sessionId ?? StorageService.getSessionId();
    if (supabaseSessionId == null) {
      debugPrint('[SESSION END] skipped — no session_id in memory or storage');
      return true;
    }

    final totalShots = s.shotsPerSeries * s.enteredTotals.length;
    final avgScore = totalShots > 0 ? s.runningTotal / totalShots : 0.0;
    final bestSeries = s.enteredTotals.isNotEmpty
        ? s.enteredTotals.reduce((a, b) => a > b ? a : b).toDouble()
        : 0.0;

    debugPrint('[SESSION END FLOW ENTERED]');
    debugPrint(
        '[SESSION END] sessionId=$supabaseSessionId totalShots=$totalShots avg=$avgScore best=$bestSeries');

    final athleteId = AuthHelper.getCurrentAthleteId();
    var completeSucceeded = true;
    var scoreSucceeded = true;

    // Step 1: signal completion to mobile backend (canonical endpoint)
    if (athleteId != null) {
      try {
        final completeRes = await ApiService.instance.completeMobileSession(
          athleteId: athleteId,
          sessionId: supabaseSessionId,
          totalShots: totalShots,
          avgScore: avgScore,
          bestSeriesScore: bestSeries,
        );
        debugPrint(
            '[SESSION COMPLETE] mobile backend status=${completeRes.statusCode}');
      } catch (e) {
        _logApiError('SESSION COMPLETE', e);
        completeSucceeded = false;
      }
    }

    // Step 2: close the legacy session row in Supabase (end_time only).
    // Best-effort — the canonical /complete call above already records
    // completion, so this step's outcome does not affect the return value.
    try {
      final res = await ApiService.instance.updateSessionComplete(
        sessionId: supabaseSessionId,
      );
      debugPrint('[SESSION END SUCCESS] status=${res.statusCode}');
    } catch (e) {
      _logApiError('SESSION END', e);
      // continue to write shooting log even if end_time patch fails
    }

    // Step 3: persist the score summary through the authenticated backend
    // (hamsatech.shooting_session_log) — replaces the direct Supabase write.
    if (athleteId != null) {
      try {
        final scoreRes = await ApiService.instance.saveScore(
          athleteId: athleteId,
          sessionId: supabaseSessionId,
          totalShots: totalShots,
          avgScore: avgScore,
          bestSeriesScore: bestSeries,
        );
        debugPrint(
            '[SCORE SAVE SUCCESS] status=${scoreRes.statusCode} data=${scoreRes.data}');
      } catch (e) {
        _logApiError('SCORE SAVE', e);
        scoreSucceeded = false;
      }
    } else {
      debugPrint(
          '[SCORE SAVE] skipped — no athlete_id (onboarding incomplete)');
    }

    return completeSucceeded && scoreSucceeded;
  }

  void _logApiError(String tag, Object e) {
    if (e is DioException) {
      debugPrint('[$tag ERROR] DioException type=${e.type.name}');
      debugPrint('[$tag ERROR] status=${e.response?.statusCode}');
      debugPrint('[$tag ERROR] body=${e.response?.data}');
      debugPrint('[$tag ERROR] message=${e.message}');
    } else {
      debugPrint('[$tag ERROR] $e');
    }
  }
}
