import 'package:uuid/uuid.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/live_training_config.dart';
import '../../domain/entities/session_mood.dart';
import '../../domain/repositories/live_training_repository.dart';

class LiveTrainingRepositoryImpl implements LiveTrainingRepository {
  static const _shotsPerSeries = 10;
  static const _defaultBaselineHr = 65;

  @override
  LiveTrainingConfig getConfig() {
    final setup = StorageService.getSessionSetup();
    String title = 'Paper Session';
    int plannedShots = 60;

    if (setup != null) {
      title = _buildTitle(setup);
      plannedShots = (setup['plannedShots'] as num?)?.toInt() ?? 60;
    }

    return LiveTrainingConfig(
      sessionTitle: title,
      plannedShots: plannedShots,
      shotsPerSeries: _shotsPerSeries,
      baselineHr: _getBaselineHr(),
    );
  }

  String _buildTitle(Map<String, dynamic> setup) {
    final rangeTypeStr = setup['rangeType'] as String? ?? 'paper';
    final sessionTypeStr = setup['sessionType'] as String?;
    final rangeLabel = rangeTypeStr == 'electronic' ? 'Electronic' : 'Paper';
    final typeLabel = switch (sessionTypeStr) {
      'scoring' => ' Scoring',
      'grouping' => ' Grouping',
      'dryFire' => ' Dry Fire',
      _ => '',
    };
    return '$rangeLabel$typeLabel Session';
  }

  int _getBaselineHr() {
    final scores = StorageService.getBaselineScores();
    if (scores != null && scores.containsKey('heartRate')) {
      return scores['heartRate']!.toInt();
    }
    return _defaultBaselineHr;
  }

  @override
  Future<String> startSession(String title) async {
    final id = const Uuid().v4();
    final sessions = StorageService.getSessions();
    sessions.add({
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'status': 'active',
      'durationMinutes': null,
      'preSession': {'energy': 5, 'focus': 5, 'stress': 5, 'confidence': 5},
      'postSession': null,
    });
    await StorageService.saveSessions(sessions);
    return id;
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required int durationMinutes,
    required SessionMood? mood,
    required String whatWorked,
    required String whatDidnt,
  }) async {
    final sessions = StorageService.getSessions();
    final idx = sessions.indexWhere((s) => s['id'] == sessionId);
    if (idx == -1) return;
    sessions[idx] = {
      ...sessions[idx],
      'status': 'completed',
      'durationMinutes': durationMinutes,
      'postSession': {
        'overallRating': mood?.rating ?? 3,
        'wentWell': whatWorked,
        'wentWrong': whatDidnt,
        'mentalNotes': '',
      },
    };
    await StorageService.saveSessions(sessions);
  }
}
