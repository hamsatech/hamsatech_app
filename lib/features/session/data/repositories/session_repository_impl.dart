import 'package:uuid/uuid.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_model.dart';
import '../../../../core/services/storage_service.dart';

class SessionRepositoryImpl implements SessionRepository {
  @override
  Future<SessionEntity> createSession(PreSessionData preSession) async {
    final session = SessionModel(
      id: const Uuid().v4(),
      date: DateTime.now(),
      preSession: preSession,
      status: SessionStatus.active,
    );
    await StorageService.saveTodayCheckIn({
      'date': DateTime.now().toIso8601String(),
      'energy': preSession.energy,
      'focus': preSession.focus,
      'stress': preSession.stress,
      'confidence': preSession.confidence,
    });
    final sessions = _loadModels();
    sessions.add(session);
    await _save(sessions);
    return session;
  }

  @override
  Future<SessionEntity> completeSession(
    String sessionId,
    PostSessionData postSession,
    int durationMinutes,
  ) async {
    final sessions = _loadModels();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) throw Exception('Session not found: $sessionId');

    final updated = SessionModel(
      id: sessions[index].id,
      date: sessions[index].date,
      preSession: sessions[index].preSession,
      postSession: postSession,
      durationMinutes: durationMinutes,
      status: SessionStatus.completed,
    );
    sessions[index] = updated;
    await _save(sessions);
    return updated;
  }

  @override
  List<SessionEntity> getSessions() => _loadModels();

  @override
  SessionEntity? getSessionById(String id) =>
      _loadModels().cast<SessionEntity?>().firstWhere(
            (s) => s?.id == id,
            orElse: () => null,
          );

  List<SessionModel> _loadModels() => StorageService.getSessions()
      .map((j) => SessionModel.fromJson(j))
      .toList();

  Future<void> _save(List<SessionModel> sessions) =>
      StorageService.saveSessions(sessions.map((s) => s.toJson()).toList());
}
