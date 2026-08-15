import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/live_training_config.dart';
import '../../domain/entities/session_mood.dart';
import '../../domain/repositories/live_training_repository.dart';
import '../services/hr_telemetry_service.dart';

class LiveTrainingRepositoryImpl implements LiveTrainingRepository {
  LiveTrainingRepositoryImpl(this._hrTelemetryService);

  final HrTelemetryService _hrTelemetryService;

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
    // The backend-created session ID (single source of truth for HR
    // correlation) is created and stored by SessionSetupBloc._onBeginRitual
    // just before this point in the navigation flow. Consume it once here
    // so a later failed session-creation attempt can never pick up a stale
    // ID left over from an earlier, successful one.
    final backendSessionId = StorageService.getSessionId();
    if (backendSessionId != null && backendSessionId.isNotEmpty) {
      debugPrint('[SESSION] Using backend sessionId: $backendSessionId');
      await StorageService.clearSessionId();
    } else {
      debugPrint(
          '[SESSION] No backend sessionId available — HR samples will be skipped for this session');
    }

    // Local-only bookkeeping ID, used solely to key this app's local
    // sessions list (see completeSession below) — never sent to the
    // backend or to HrTelemetryService. Falls back to a local UUID only
    // when no backend session ID exists, so this list/return value keeps
    // working exactly as before regardless of backend availability.
    final id = backendSessionId ?? const Uuid().v4();
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

    debugPrint('[HR] Using sessionId: $backendSessionId');
    _hrTelemetryService.setActiveSessionId(backendSessionId);
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
    // Stop accepting new HR samples before anything else, so none are
    // buffered while the backend call below is in flight.
    _hrTelemetryService.setActiveSessionId(null);

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

    // `sessionId` is the real backend session_id whenever one exists (see
    // startSession above). Non-fatal: a network/API failure here must not
    // affect the local completion state already saved above.
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId != null) {
      try {
        await ApiService.instance.completeMobileSession(
          athleteId: athleteId,
          sessionId: sessionId,
          durationMinutes: durationMinutes,
          performanceRating: mood?.rating,
        );
      } catch (e) {
        debugPrint('[SESSION COMPLETE] backend call failed: $e');
      }
    }
  }

  @override
  void stopHrTelemetry() {
    _hrTelemetryService.setActiveSessionId(null);
  }

  @override
  Future<void> flushHrTelemetry() {
    return _hrTelemetryService.flushNow();
  }
}
