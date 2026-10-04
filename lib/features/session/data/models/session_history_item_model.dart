/// One entry in a `GET /api/mobile/athletes/{athleteId}/sessions` page.
///
/// Field names/shape match the real backend response exactly
/// (`app/modules/sessions/schemas/responses.py::SessionHistoryItem` in the
/// ASTRA backend) — every field here is real, persisted data (session
/// timing, saved score summary, saved series count). Deliberately has no
/// pre-session energy/focus/stress/confidence or post-session mood/rating
/// fields: those belonged to the old local-only session log and have no
/// legitimate source in this real backend response.
class SessionHistoryItemModel {
  const SessionHistoryItemModel({
    required this.sessionId,
    required this.sessionType,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.avgScore,
    required this.bestSeriesScore,
    required this.totalShots,
    required this.seriesCount,
  });

  final String sessionId;
  final String? sessionType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final double? avgScore;
  final double? bestSeriesScore;
  final int? totalShots;
  final int seriesCount;

  factory SessionHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryItemModel(
      sessionId: json['session_id'] as String,
      sessionType: json['session_type'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      avgScore: (json['avg_score'] as num?)?.toDouble(),
      bestSeriesScore: (json['best_series_score'] as num?)?.toDouble(),
      totalShots: (json['total_shots'] as num?)?.toInt(),
      seriesCount: (json['series_count'] as num).toInt(),
    );
  }
}
