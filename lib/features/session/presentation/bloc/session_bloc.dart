import 'package:flutter_bloc/flutter_bloc.dart';
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
      final session = await _repository.createSession(event.preSession);
      emit(SessionStarted(session));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
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
