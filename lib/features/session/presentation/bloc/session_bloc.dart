import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(this._repository) : super(const SessionInitial()) {
    on<SessionStartRequested>(_onStart);
    on<SessionCompleteRequested>(_onComplete);
    on<SessionsLoadRequested>(_onLoad);
  }

  final SessionRepository _repository;

  Future<void> _onStart(
    SessionStartRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      _syncSessionStart(event.preSession);
      final session = await _repository.createSession(event.preSession);
      emit(SessionStarted(session));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  // ── Athlete ID resolution ──────────────────────────────────────────────────
  // AuthHelper resolves in priority order: supabase UUID → profile map → phone/email.
  // Returns null if onboarding never completed an athletes POST (offline or skipped).
  static String? _resolveAthleteId() => AuthHelper.getCurrentAthleteId();

  // ── helpers ────────────────────────────────────────────────────────────────

  String? _extractSessionId(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final row = data.first;
      if (row is Map) return (row['session_id'] ?? row['id'])?.toString();
    }
    if (data is Map) {
      // Handle wrapped response: { "data": { "session_id": "..." } }
      if (data['data'] is Map) {
        final inner = data['data'] as Map;
        return (inner['session_id'] ?? inner['id'])?.toString();
      }
      return (data['session_id'] ?? data['id'])?.toString();
    }
    return null;
  }

  /// Logs the Dio error status + response body so API failures are diagnosable.
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

  // ── Session create + pre-log ──────────────────────────────────────────────

  void _syncSessionStart(PreSessionData pre) {
    Future(() async {
      // ── Step 1: resolve session_id ────────────────────────────────────────
      // SessionSetupBloc already created the session and stored the id.
      // Reuse it to avoid creating a duplicate session record.
      String? sessionId =
          SessionMemory.sessionId ?? StorageService.getSessionId();

      if (sessionId == null) {
        // Standalone flow (pre-session screen reached without Setup screen).
        // Create a new session via the mobile backend using stored setup data.
        final athleteId = _resolveAthleteId();
        if (athleteId == null) {
          debugPrint(
              '[SESSION] skipped — no athlete_id (onboarding incomplete)');
          return;
        }

        final setup = StorageService.getSessionSetup();
        final sessionType = setup?['sessionType'] as String? ?? 'training';
        final rangeType = setup?['rangeType'] as String? ?? 'paper';
        final plannedShots = (setup?['plannedShots'] as num?)?.toInt() ?? 60;
        final discipline = setup?['discipline'] as String? ?? '';

        try {
          debugPrint(
              '[SESSION] standalone — POST api/mobile/athletes/$athleteId/sessions');
          final res = await ApiService.instance.createMobileSession(
            athleteId: athleteId,
            sessionType: sessionType,
            rangeType: rangeType,
            plannedShots: plannedShots,
            discipline: discipline,
          );
          sessionId = _extractSessionId(res.data);
          if (sessionId == null) {
            debugPrint(
                '[SESSION] WARNING: no session_id in response: ${res.data}');
            return;
          }
          SessionMemory.sessionId = sessionId;
          await StorageService.saveSessionId(sessionId);
          debugPrint('[SESSION] standalone session created id=$sessionId');
        } catch (e) {
          _logApiError('SESSION CREATE', e);
          return;
        }
      } else {
        debugPrint(
            '[SESSION] reusing existing session_id=$sessionId from SetupBloc');
      }

      // ── Step 2: pre-log (independent — failure must not block the session) ─
      try {
        final readiness =
            ((pre.energy + pre.focus + (11 - pre.stress) + pre.confidence) / 4)
                .round()
                .clamp(1, 10);
        final mentalState = pre.focus >= 7
            ? 'focused'
            : pre.focus >= 4
                ? 'neutral'
                : 'distracted';
        final feelingRating = pre.energy >= 7
            ? 'high'
            : pre.energy >= 4
                ? 'moderate'
                : 'low';

        final preLogBody = {
          'session_id': sessionId,
          'energy_level': pre.energy,
          'readiness_score': readiness,
          'mental_state': mentalState,
          'feeling_rating': feelingRating,
          'mental_tags': <String>[],
        };
        debugPrint('[PRE LOG] calling savePreSessionLog');
        debugPrint('[PRE LOG BODY] $preLogBody');

        final res = await ApiService.instance.savePreSessionLog(
          sessionId: sessionId,
          energyLevel: pre.energy,
          readinessScore: readiness,
          mentalState: mentalState,
          feelingRating: feelingRating,
        );
        debugPrint(
            '[PRE LOG SUCCESS] status=${res.statusCode} data=${res.data}');
      } catch (e) {
        _logApiError('PRE LOG', e);
      }
    });
  }

  // ── Session complete + post-log ────────────────────────────────────────────

  void _syncSessionComplete(
    String localSessionId,
    PostSessionData post,
    int durationMinutes,
  ) {
    Future(() async {
      final supabaseSessionId = SessionMemory.sessionId;
      if (supabaseSessionId == null) {
        debugPrint('[POST LOG] WARNING: SessionMemory.sessionId is null — '
            'session was likely created offline. Skipping end-time and post-log.');
        return;
      }

      final athleteId = _resolveAthleteId();
      final rating = post.overallRating; // 1–5
      final performanceRating = (rating * 2).clamp(1, 10); // → 2–10

      // ── Step 1: signal completion to mobile backend (canonical endpoint) ────
      if (athleteId != null) {
        try {
          final completeRes = await ApiService.instance.completeMobileSession(
            athleteId: athleteId,
            sessionId: supabaseSessionId,
            durationMinutes: durationMinutes,
            performanceRating: performanceRating,
            notes: post.mentalNotes,
          );
          debugPrint(
              '[SESSION COMPLETE] mobile backend status=${completeRes.statusCode}');
        } catch (e) {
          _logApiError('SESSION COMPLETE', e);
          // Non-fatal: continue to Supabase fallback updates.
        }
      }

      // ── Step 2: update end_time in Supabase (independent — failure must not block post-log)
      try {
        debugPrint(
            '[SESSION END] calling updateSessionEndTime id=$supabaseSessionId');
        await ApiService.instance.updateSessionEndTime(
          sessionId: supabaseSessionId,
          endTime: DateTime.now().toIso8601String(),
        );
        debugPrint('[SESSION END] end_time updated');
      } catch (e) {
        _logApiError('SESSION END TIME', e);
        // intentionally continue to post-log even if end_time patch fails
      }

      // ── Step 3: post-log ──────────────────────────────────────────────────
      try {
        final focusLevel = rating >= 4
            ? 'high'
            : rating >= 3
                ? 'moderate'
                : 'low';
        final challenges =
            post.wentWrong.isNotEmpty ? [post.wentWrong] : <String>[];

        final postLogBody = {
          'session_id': supabaseSessionId,
          'focus_level': focusLevel,
          'focus_area': post.wentWell,
          'session_duration': durationMinutes.toString(),
          'performance_rating': performanceRating,
          'challenges': challenges,
          'coach_feedback': post.mentalNotes,
        };
        debugPrint('[POST LOG] calling savePostSessionLog');
        debugPrint('[POST LOG BODY] $postLogBody');

        final res = await ApiService.instance.savePostSessionLog(
          sessionId: supabaseSessionId,
          focusLevel: focusLevel,
          focusArea: post.wentWell,
          sessionDuration: durationMinutes.toString(),
          performanceRating: performanceRating,
          challenges: challenges,
          coachFeedback: post.mentalNotes,
        );
        debugPrint(
            '[POST LOG SUCCESS] status=${res.statusCode} data=${res.data}');

        SessionMemory.clear();
      } catch (e) {
        _logApiError('POST LOG', e);
      }
    });
  }

  Future<void> _onComplete(
    SessionCompleteRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      _syncSessionComplete(
        event.sessionId,
        event.postSession,
        event.durationMinutes,
      );
      final session = await _repository.completeSession(
        event.sessionId,
        event.postSession,
        event.durationMinutes,
      );
      emit(SessionCompleted(session));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  void _onLoad(
    SessionsLoadRequested event,
    Emitter<SessionState> emit,
  ) {
    try {
      final sessions = _repository.getSessions();
      emit(SessionsListLoaded(sessions));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}
