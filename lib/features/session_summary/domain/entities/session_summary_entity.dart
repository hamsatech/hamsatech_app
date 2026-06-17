import 'package:equatable/equatable.dart';

// ── Session summary ───────────────────────────────────────────────────────────

class SessionSummaryEntity extends Equatable {
  const SessionSummaryEntity({
    required this.sessionTitle,
    required this.totalShots,
    required this.duration,
    required this.total,
    required this.maxPossible,
    required this.averagePerShot,
    required this.efficiency,
    required this.bestShot,
    required this.worstShot,
    required this.bestSeriesLabel,
    required this.worstSeriesLabel,
    required this.seriesBreakdown,
    required this.scorePoints,
    this.moodCorrelation,
  });

  final String sessionTitle;
  final int totalShots;
  final String duration;
  final double total;
  final double maxPossible;
  final double averagePerShot;
  final double efficiency;
  final double bestShot;
  final double worstShot;
  final String bestSeriesLabel;
  final String worstSeriesLabel;
  final List<SeriesBreakdownEntity> seriesBreakdown;
  final List<ScorePointEntity> scorePoints;
  final MoodCorrelationEntity? moodCorrelation;

  static const SessionSummaryEntity empty = SessionSummaryEntity(
    sessionTitle: 'Session',
    totalShots: 0,
    duration: '0:00',
    total: 0,
    maxPossible: 0,
    averagePerShot: 0,
    efficiency: 0,
    bestShot: 0,
    worstShot: 0,
    bestSeriesLabel: '—',
    worstSeriesLabel: '—',
    seriesBreakdown: [],
    scorePoints: [],
  );

  String get formattedTotal {
    final t = total;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  String get formattedAverage => averagePerShot.toStringAsFixed(1);

  String get formattedEfficiency => efficiency.toStringAsFixed(0);

  String get formattedBestShot {
    return bestShot == bestShot.truncateToDouble()
        ? bestShot.toInt().toString()
        : bestShot.toStringAsFixed(1);
  }

  String get formattedWorstShot {
    return worstShot == worstShot.truncateToDouble()
        ? worstShot.toInt().toString()
        : worstShot.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [
        sessionTitle,
        totalShots,
        duration,
        total,
        maxPossible,
        averagePerShot,
        efficiency,
        bestShot,
        worstShot,
        bestSeriesLabel,
        worstSeriesLabel,
        seriesBreakdown,
        scorePoints,
        moodCorrelation,
      ];
}

// ── Series breakdown ──────────────────────────────────────────────────────────

class SeriesBreakdownEntity extends Equatable {
  const SeriesBreakdownEntity({
    required this.seriesNumber,
    required this.total,
    required this.maxTotal,
    required this.isBest,
  });

  final int seriesNumber;
  final double total;
  final double maxTotal;
  final bool isBest;

  double get fraction => maxTotal > 0 ? (total / maxTotal).clamp(0.0, 1.0) : 0;

  String get formattedTotal {
    return total == total.truncateToDouble()
        ? total.toInt().toString()
        : total.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [seriesNumber, total, maxTotal, isBest];
}

// ── Score chart point ─────────────────────────────────────────────────────────

class ScorePointEntity extends Equatable {
  const ScorePointEntity({
    required this.index,
    required this.value,
    required this.isSpike,
  });

  final int index;
  final double value;
  final bool isSpike;

  @override
  List<Object?> get props => [index, value, isSpike];
}

// ── Mood correlation ──────────────────────────────────────────────────────────

class MoodCorrelationEntity extends Equatable {
  const MoodCorrelationEntity({
    required this.moodLabel,
    required this.moodState,
    required this.moodEmoji,
    required this.sessionAvg,
    required this.moodRating,
  });

  final String moodLabel;
  final String moodState;
  final String moodEmoji;
  final double sessionAvg;
  final int moodRating;

  String get formattedAvg => sessionAvg.toStringAsFixed(1);

  @override
  List<Object?> get props =>
      [moodLabel, moodState, moodEmoji, sessionAvg, moodRating];
}
