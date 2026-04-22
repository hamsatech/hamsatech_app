import 'package:equatable/equatable.dart';
import '../../domain/entities/session_entity.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}

class SessionStartRequested extends SessionEvent {
  const SessionStartRequested(this.preSession);
  final PreSessionData preSession;
  @override
  List<Object?> get props => [preSession];
}

class SessionCompleteRequested extends SessionEvent {
  const SessionCompleteRequested({
    required this.sessionId,
    required this.postSession,
    required this.durationMinutes,
  });
  final String sessionId;
  final PostSessionData postSession;
  final int durationMinutes;
  @override
  List<Object?> get props => [sessionId, postSession, durationMinutes];
}

class SessionsLoadRequested extends SessionEvent {
  const SessionsLoadRequested();
}
