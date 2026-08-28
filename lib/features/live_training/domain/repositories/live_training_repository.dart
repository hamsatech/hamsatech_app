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

  /// Stops associating new Polar HR samples with the just-ended session.
  /// Synchronous, no I/O — must not disconnect Polar or touch the HR
  /// subscription/timer/buffer.
  void stopHrTelemetry();

  /// Awaits a final upload of any HR samples still buffered for the
  /// just-ended session. Must be called after [stopHrTelemetry] so no new
  /// samples can arrive while this is in flight.
  Future<void> flushHrTelemetry();
}
