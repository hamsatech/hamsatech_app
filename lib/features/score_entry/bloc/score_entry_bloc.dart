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
    if (s is! ScoreEntryActiveState || !s.isComplete) return;
    await _repository.saveTotals(s.enteredTotals, s.shotsPerSeries);
    _syncSeries(s);
    _syncSessionEnd(s);
    _syncPostLog(s);
    emit(const ScoreEntrySavedState());
  }

  // ── Mobile backend: per-series sync ──────────────────────────────────────────

  void _syncSeries(ScoreEntryActiveState s) {
    final sessionId = SessionMemory.sessionId ?? StorageService.getSessionId();
    final athleteId = AuthHelper.getCurrentAthleteId();

    if (sessionId == null || athleteId == null) {
      debugPrint(
          '[SERIES SYNC] skipped — sessionId=$sessionId athleteId=$athleteId');
      return;
    }

    Future(() async {
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
          // Non-fatal: continue submitting remaining series.
        }
      }
    });
  }

  void _syncSessionEnd(ScoreEntryActiveState s) {
    // Prefer in-memory value; fall back to SharedPreferences for restart recovery.
    final supabaseSessionId =
        SessionMemory.sessionId ?? StorageService.getSessionId();
    if (supabaseSessionId == null) {
      debugPrint('[SESSION END] skipped — no session_id in memory or storage');
      return;
    }

    final totalShots = s.shotsPerSeries * s.enteredTotals.length;
    final avgScore = totalShots > 0 ? s.runningTotal / totalShots : 0.0;
    final bestSeries = s.enteredTotals.isNotEmpty
        ? s.enteredTotals.reduce((a, b) => a > b ? a : b).toDouble()
        : 0.0;

    final pct = s.maxTotalScore > 0
        ? (s.runningTotal / s.maxTotalScore * 100)
        : 0.0;
    final performanceRating = (pct / 10).round().clamp(1, 10);

    Future(() async {
      debugPrint('[SESSION END FLOW ENTERED]');
      debugPrint(
          '[SESSION END] sessionId=$supabaseSessionId totalShots=$totalShots avg=$avgScore best=$bestSeries');

      final athleteId = AuthHelper.getCurrentAthleteId();

      // Step 1: signal completion to mobile backend (canonical endpoint)
      if (athleteId != null) {
        try {
          final completeRes = await ApiService.instance.completeMobileSession(
            athleteId: athleteId,
            sessionId: supabaseSessionId,
            totalShots: totalShots,
            totalScore: s.runningTotal,
            avgScore: avgScore,
            bestSeriesScore: bestSeries,
            performanceRating: performanceRating,
          );
          debugPrint(
              '[SESSION COMPLETE] mobile backend status=${completeRes.statusCode}');
        } catch (e) {
          _logApiError('SESSION COMPLETE', e);
          // Non-fatal: continue to Supabase fallback updates.
        }
      }

      // Step 2: close the session row in Supabase (end_time only)
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
        }
      } else {
        debugPrint(
            '[SCORE SAVE] skipped — no athlete_id (onboarding incomplete)');
      }
    });
  }

  void _syncPostLog(ScoreEntryActiveState s) {
    final supabaseSessionId =
        SessionMemory.sessionId ?? StorageService.getSessionId();
    if (supabaseSessionId == null) {
      debugPrint('[POST LOG] skipped — no session_id in memory or storage');
      return;
    }

    Future(() async {
      debugPrint('[POST LOG FLOW ENTERED]');

      final pct =
          s.maxTotalScore > 0 ? (s.runningTotal / s.maxTotalScore * 100) : 0.0;
      final performanceRating = (pct / 10).round().clamp(1, 10);
      final focusLevel = performanceRating >= 8
          ? 'high'
          : performanceRating >= 5
              ? 'moderate'
              : 'low';

      final postLogBody = {
        'session_id': supabaseSessionId,
        'focus_level': focusLevel,
        'focus_area': 'score_entry',
        'session_duration': '0',
        'performance_rating': performanceRating,
        'challenges': <String>[],
        'coach_feedback': '',
      };

      debugPrint('[POST LOG CALL START]');
      debugPrint('[POST LOG BODY] $postLogBody');

      try {
        final res = await ApiService.instance.savePostSessionLog(
          sessionId: supabaseSessionId,
          focusLevel: focusLevel,
          focusArea: 'score_entry',
          sessionDuration: '0',
          performanceRating: performanceRating,
        );
        debugPrint(
            '[POST LOG RESPONSE] status=${res.statusCode} data=${res.data}');
        SessionMemory.clear();
      } catch (e) {
        _logApiError('POST LOG', e);
      }
    });
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
