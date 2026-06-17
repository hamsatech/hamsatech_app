import 'package:equatable/equatable.dart';

// ── Root entity ───────────────────────────────────────────────────────────────

class SessionReportEntity extends Equatable {
  const SessionReportEntity({
    required this.sessionTitle,
    required this.dateLabel,
    required this.timeLabel,
    required this.physiology,
    required this.seriesRows,
    required this.hrMetrics,
    required this.hrPoints,
    required this.mentalState,
    required this.insight,
    required this.recommendations,
    required this.coachFeedback,
  });

  final String sessionTitle;
  final String dateLabel;
  final String timeLabel;
  final PhysiologyMetricsEntity physiology;
  final List<ReportSeriesRowEntity> seriesRows;
  final HrMetricsEntity hrMetrics;
  final List<HrChartPoint> hrPoints;
  final MentalStateComparisonEntity mentalState;
  final InsightEntity insight;
  final List<RecommendationItemEntity> recommendations;
  final CoachFeedbackEntity coachFeedback;

  static final SessionReportEntity empty = SessionReportEntity(
    sessionTitle: 'Session Report',
    dateLabel: 'Today',
    timeLabel: '',
    physiology: const PhysiologyMetricsEntity(
      avgHr: 0,
      peakHr: 0,
      fatigueLabel: 'N/A',
      fatigueColor: MetricColor.neutral,
      recoveryLabel: 'N/A',
      recoveryColor: MetricColor.neutral,
    ),
    seriesRows: const [],
    hrMetrics: const HrMetricsEntity(
      avgHr: 0,
      peakHr: 0,
      minHr: 0,
      hrZoneLabel: 'Zone 2',
      hrZoneColor: MetricColor.neutral,
      avgPreShotHr: 0,
      spikeCount: 0,
      spikeThreshold: 84,
    ),
    hrPoints: const [],
    mentalState: const MentalStateComparisonEntity(rows: []),
    insight: const InsightEntity(
      headline: 'Great session!',
      body: 'Your performance metrics look good.',
    ),
    recommendations: const [],
    coachFeedback: const CoachFeedbackEntity(
      avatarInitial: 'C',
      coachName: 'Coach',
      timestampLabel: 'just now',
      message: 'Keep it up!',
      planLabel: 'View Assigned Plan',
    ),
  );

  @override
  List<Object?> get props => [
        sessionTitle,
        dateLabel,
        timeLabel,
        physiology,
        seriesRows,
        hrMetrics,
        hrPoints,
        mentalState,
        insight,
        recommendations,
        coachFeedback,
      ];
}

// ── Metric color tag ──────────────────────────────────────────────────────────

enum MetricColor { good, warning, bad, neutral }

// ── Physiology metrics ────────────────────────────────────────────────────────

class PhysiologyMetricsEntity extends Equatable {
  const PhysiologyMetricsEntity({
    required this.avgHr,
    required this.peakHr,
    required this.fatigueLabel,
    required this.fatigueColor,
    required this.recoveryLabel,
    required this.recoveryColor,
  });

  final int avgHr;
  final int peakHr;
  final String fatigueLabel;
  final MetricColor fatigueColor;
  final String recoveryLabel;
  final MetricColor recoveryColor;

  @override
  List<Object?> get props =>
      [avgHr, peakHr, fatigueLabel, fatigueColor, recoveryLabel, recoveryColor];
}

// ── Report series row ─────────────────────────────────────────────────────────

class ReportSeriesRowEntity extends Equatable {
  const ReportSeriesRowEntity({
    required this.seriesNumber,
    required this.total,
    required this.maxTotal,
    required this.avgHr,
    required this.isBest,
  });

  final int seriesNumber;
  final double total;
  final double maxTotal;
  final int avgHr;
  final bool isBest;

  double get fraction => maxTotal > 0 ? (total / maxTotal).clamp(0.0, 1.0) : 0;

  String get formattedTotal {
    return total == total.truncateToDouble()
        ? total.toInt().toString()
        : total.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [seriesNumber, total, maxTotal, avgHr, isBest];
}

// ── HR metrics ────────────────────────────────────────────────────────────────

class HrMetricsEntity extends Equatable {
  const HrMetricsEntity({
    required this.avgHr,
    required this.peakHr,
    required this.minHr,
    required this.hrZoneLabel,
    required this.hrZoneColor,
    required this.avgPreShotHr,
    required this.spikeCount,
    required this.spikeThreshold,
  });

  final int avgHr;
  final int peakHr;
  final int minHr;
  final String hrZoneLabel;
  final MetricColor hrZoneColor;
  final int avgPreShotHr;
  final int spikeCount;
  final int spikeThreshold;

  @override
  List<Object?> get props => [
        avgHr,
        peakHr,
        minHr,
        hrZoneLabel,
        hrZoneColor,
        avgPreShotHr,
        spikeCount,
        spikeThreshold
      ];
}

// ── HR chart point ────────────────────────────────────────────────────────────

class HrChartPoint extends Equatable {
  const HrChartPoint({
    required this.index,
    required this.bpm,
    this.isSpike = false,
    this.isSeriesBoundary = false,
  });

  final int index;
  final double bpm;
  final bool isSpike;
  final bool isSeriesBoundary;

  @override
  List<Object?> get props => [index, bpm, isSpike, isSeriesBoundary];
}

// ── Mental state comparison ───────────────────────────────────────────────────

class MentalStateComparisonEntity extends Equatable {
  const MentalStateComparisonEntity({required this.rows});

  final List<MentalStateRowEntity> rows;

  @override
  List<Object?> get props => [rows];
}

// Each row holds two independent cells (before & after) — each with its own label
class MentalStateRowEntity extends Equatable {
  const MentalStateRowEntity({
    required this.before,
    required this.after,
  });

  final MentalStateCellEntity before;
  final MentalStateCellEntity after;

  @override
  List<Object?> get props => [before, after];
}

class MentalStateCellEntity extends Equatable {
  const MentalStateCellEntity({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final MetricColor color;

  @override
  List<Object?> get props => [label, value, color];
}

// ── Key insight ───────────────────────────────────────────────────────────────

class InsightEntity extends Equatable {
  const InsightEntity({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  List<Object?> get props => [headline, body];
}

// ── Recommendation ────────────────────────────────────────────────────────────

class RecommendationItemEntity extends Equatable {
  const RecommendationItemEntity({
    required this.text,
    this.isChecked = false,
  });

  final String text;
  final bool isChecked;

  @override
  List<Object?> get props => [text, isChecked];
}

// ── Coach feedback ────────────────────────────────────────────────────────────

class CoachFeedbackEntity extends Equatable {
  const CoachFeedbackEntity({
    required this.avatarInitial,
    required this.coachName,
    required this.timestampLabel,
    required this.message,
    required this.planLabel,
  });

  final String avatarInitial;
  final String coachName;
  final String timestampLabel;
  final String message;
  final String planLabel;

  @override
  List<Object?> get props =>
      [avatarInitial, coachName, timestampLabel, message, planLabel];
}
