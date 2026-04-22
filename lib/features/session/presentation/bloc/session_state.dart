import 'package:equatable/equatable.dart';
import '../../domain/entities/session_entity.dart';

abstract class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionStarted extends SessionState {
  const SessionStarted(this.session);
  final SessionEntity session;
  @override
  List<Object?> get props => [session];
}

class SessionCompleted extends SessionState {
  const SessionCompleted(this.session);
  final SessionEntity session;
  @override
  List<Object?> get props => [session];
}

class SessionsListLoaded extends SessionState {
  const SessionsListLoaded(this.sessions);
  final List<SessionEntity> sessions;
  @override
  List<Object?> get props => [sessions];
}

class SessionError extends SessionState {
  const SessionError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
