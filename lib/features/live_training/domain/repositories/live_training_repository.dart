import '../entities/live_training_config.dart';
import '../entities/session_mood.dart';

abstract class LiveTrainingRepository {
  LiveTrainingConfig getConfig();

  Future<String> startSession(String title);

  Future<void> completeSession({
    required String sessionId,
    required int durationMinutes,
    required SessionMood? mood,
    required String whatWorked,
    required String whatDidnt,
  });
}
