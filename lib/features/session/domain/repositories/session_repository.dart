import '../entities/session_entity.dart';

abstract class SessionRepository {
  Future<SessionEntity> createSession(PreSessionData preSession);
  Future<SessionEntity> completeSession(
      String sessionId, PostSessionData postSession, int durationMinutes);
  List<SessionEntity> getSessions();
  SessionEntity? getSessionById(String id);
}
