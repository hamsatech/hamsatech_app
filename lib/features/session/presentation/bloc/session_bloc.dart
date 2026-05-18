import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/session_memory.dart';
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
      // ── Supabase: create session ──────────────────────────────────────────
      try {
        final response = await ApiService.instance.createSession(
          athleteId: 'ATH001',
          sessionType: 'training',
          startTime: DateTime.now().toUtc().toIso8601String(),
        );
        debugPrint('[SESSION CREATED]');
        debugPrint('[SESSION RESPONSE] ${response.data}');
        SessionMemory.sessionId = _extractSessionId(response.data);
        debugPrint('[SESSION ID] ${SessionMemory.sessionId}');
      } catch (apiError) {
        debugPrint('[SESSION API ERROR] $apiError');
        // API failure does not block the local flow.
      }
      // ─────────────────────────────────────────────────────────────────────

      final session = await _repository.createSession(event.preSession);
      emit(SessionStarted(session));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  String? _extractSessionId(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final row = data.first;
      if (row is Map) return (row['id'] ?? row['session_id'])?.toString();
    }
    if (data is Map) return (data['id'] ?? data['session_id'])?.toString();
    return null;
  }

  Future<void> _onComplete(
    SessionCompleteRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
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
