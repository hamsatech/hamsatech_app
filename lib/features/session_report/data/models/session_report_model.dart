/// Parsed response from
/// `GET /api/mobile/athletes/{athleteId}/sessions/{sessionId}/report`.
///
/// Matches the live backend `SessionReportResponse` schema exactly —
/// `scores` and `reflection` are `null` when that category has no saved
/// data for the session; `series` is `[]` when none were saved;
/// `heart_rate` is always present (sample_count 0 with null metrics when
/// there's no HR data).
class SessionReportModel {
  const SessionReportModel({
    required this.sessionId,
    required this.athleteId,
    required this.sessionStatus,
    required this.summary,
    required this.heartRate,
    required this.scores,
    required this.series,
    required this.reflection,
  });

  final String sessionId;
  final String athleteId;
  final String sessionStatus;
  final SessionReportSummary summary;
  final SessionReportHeartRate heartRate;
  final SessionReportScores? scores;
  final List<SessionReportSeriesEntry> series;
  final SessionReportReflection? reflection;

  factory SessionReportModel.fromJson(Map<String, dynamic> json) {
    return SessionReportModel(
      sessionId: json['session_id'] as String,
      athleteId: json['athlete_id'] as String,
      sessionStatus: json['session_status'] as String,
      summary: SessionReportSummary.fromJson(
        json['session_summary'] as Map<String, dynamic>,
      ),
      heartRate: SessionReportHeartRate.fromJson(
        json['heart_rate'] as Map<String, dynamic>,
      ),
      scores: json['scores'] != null
          ? SessionReportScores.fromJson(json['scores'] as Map<String, dynamic>)
          : null,
      series: (json['series'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(SessionReportSeriesEntry.fromJson)
          .toList(),
      reflection: json['reflection'] != null
          ? SessionReportReflection.fromJson(
              json['reflection'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SessionReportSummary {
  const SessionReportSummary({
    required this.sessionType,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
  });

  final String? sessionType;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;

  factory SessionReportSummary.fromJson(Map<String, dynamic> json) {
    return SessionReportSummary(
      sessionType: json['session_type'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
    );
  }
}

class SessionReportHeartRate {
  const SessionReportHeartRate({
    required this.sampleCount,
    required this.averageHeartRate,
    required this.minimumHeartRate,
    required this.maximumHeartRate,
    required this.firstHeartRate,
    required this.lastHeartRate,
  });

  final int sampleCount;
  final int? averageHeartRate;
  final int? minimumHeartRate;
  final int? maximumHeartRate;
  final int? firstHeartRate;
  final int? lastHeartRate;

  factory SessionReportHeartRate.fromJson(Map<String, dynamic> json) {
    return SessionReportHeartRate(
      sampleCount: (json['sample_count'] as num).toInt(),
      averageHeartRate: (json['average_heart_rate'] as num?)?.toInt(),
      minimumHeartRate: (json['minimum_heart_rate'] as num?)?.toInt(),
      maximumHeartRate: (json['maximum_heart_rate'] as num?)?.toInt(),
      firstHeartRate: (json['first_heart_rate'] as num?)?.toInt(),
      lastHeartRate: (json['last_heart_rate'] as num?)?.toInt(),
    );
  }
}

/// `totalShots`/`avgScore`/`bestSeriesScore` come from the client-saved
/// score summary (the `/score` endpoint); `totalScore`/`averageScore`/
/// `minimumScore`/`maximumScore` are aggregates the backend computes over
/// the session's saved series. Either group may be null independently.
class SessionReportScores {
  const SessionReportScores({
    required this.totalShots,
    required this.avgScore,
    required this.bestSeriesScore,
    required this.totalScore,
    required this.averageScore,
    required this.minimumScore,
    required this.maximumScore,
  });

  final int? totalShots;
  final double? avgScore;
  final double? bestSeriesScore;
  final double? totalScore;
  final double? averageScore;
  final double? minimumScore;
  final double? maximumScore;

  factory SessionReportScores.fromJson(Map<String, dynamic> json) {
    return SessionReportScores(
      totalShots: (json['total_shots'] as num?)?.toInt(),
      avgScore: (json['avg_score'] as num?)?.toDouble(),
      bestSeriesScore: (json['best_series_score'] as num?)?.toDouble(),
      totalScore: (json['total_score'] as num?)?.toDouble(),
      averageScore: (json['average_score'] as num?)?.toDouble(),
      minimumScore: (json['minimum_score'] as num?)?.toDouble(),
      maximumScore: (json['maximum_score'] as num?)?.toDouble(),
    );
  }
}

class SessionReportSeriesEntry {
  const SessionReportSeriesEntry({
    required this.seriesNumber,
    required this.totalScore,
    required this.shotsFired,
  });

  final int seriesNumber;
  final double? totalScore;
  final int? shotsFired;

  factory SessionReportSeriesEntry.fromJson(Map<String, dynamic> json) {
    return SessionReportSeriesEntry(
      seriesNumber: (json['series_number'] as num).toInt(),
      totalScore: (json['total_score'] as num?)?.toDouble(),
      shotsFired: (json['shots_fired'] as num?)?.toInt(),
    );
  }
}

/// `mood` is a 1-5 self-reported rating (same scale the app already uses
/// for local mood/check-in ratings — enforced 1-5 server-side too).
class SessionReportReflection {
  const SessionReportReflection({
    required this.mood,
    required this.whatWorked,
    required this.whatDidnt,
  });

  final int? mood;
  final String? whatWorked;
  final String? whatDidnt;

  factory SessionReportReflection.fromJson(Map<String, dynamic> json) {
    return SessionReportReflection(
      mood: (json['mood'] as num?)?.toInt(),
      whatWorked: json['what_worked'] as String?,
      whatDidnt: json['what_didnt'] as String?,
    );
  }
}
