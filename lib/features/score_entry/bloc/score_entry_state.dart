import 'package:equatable/equatable.dart';

import '../domain/entities/session_series_entity.dart';

abstract class ScoreEntryState extends Equatable {
  const ScoreEntryState();

  @override
  List<Object?> get props => [];
}

class ScoreEntryInitial extends ScoreEntryState {
  const ScoreEntryInitial();
}

// ── Active — entering shots for current series ─────────────────────────────────

class ScoreEntryActiveState extends ScoreEntryState {
  const ScoreEntryActiveState({
    required this.sessionTitle,
    required this.completedSeries,
    required this.currentShots,
    required this.totalSeries,
    required this.shotsPerSeries,
  });

  final String sessionTitle;
  final List<SessionSeries> completedSeries;
  final List<ScoreValue> currentShots;
  final int totalSeries;
  final int shotsPerSeries;

  int get currentSeriesNumber => completedSeries.length + 1;
  int get currentShotNumber => currentShots.length + 1;
  bool get canUndo => currentShots.isNotEmpty;

  ScoreEntryActiveState copyWith({List<ScoreValue>? currentShots}) =>
      ScoreEntryActiveState(
        sessionTitle: sessionTitle,
        completedSeries: completedSeries,
        currentShots: currentShots ?? this.currentShots,
        totalSeries: totalSeries,
        shotsPerSeries: shotsPerSeries,
      );

  @override
  List<Object?> get props => [
        sessionTitle,
        completedSeries,
        currentShots,
        totalSeries,
        shotsPerSeries,
      ];
}

// ── Series complete — awaiting confirm/edit ────────────────────────────────────

class SeriesCompleteState extends ScoreEntryState {
  const SeriesCompleteState({
    required this.sessionTitle,
    required this.previouslyCompletedSeries,
    required this.justCompletedShots,
    required this.totalSeries,
    required this.shotsPerSeries,
  });

  final String sessionTitle;
  final List<SessionSeries> previouslyCompletedSeries;
  final List<ScoreValue> justCompletedShots;
  final int totalSeries;
  final int shotsPerSeries;

  int get justCompletedSeriesNumber =>
      previouslyCompletedSeries.length + 1;

  double get justCompletedTotal =>
      justCompletedShots.fold(0.0, (sum, s) => sum + s.numeric);

  String get formattedTotal {
    final t = justCompletedTotal;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  bool get isLastSeries =>
      previouslyCompletedSeries.length + 1 >= totalSeries;

  @override
  List<Object?> get props => [
        sessionTitle,
        previouslyCompletedSeries,
        justCompletedShots,
        totalSeries,
        shotsPerSeries,
      ];
}

// ── All series complete — final review ────────────────────────────────────────

class AllSeriesCompleteState extends ScoreEntryState {
  const AllSeriesCompleteState({required this.allSeries});

  final List<SessionSeries> allSeries;

  double get grandTotal =>
      allSeries.fold(0.0, (sum, s) => sum + s.total);

  String get formattedGrandTotal {
    final t = grandTotal;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [allSeries];
}

// ── Saved ─────────────────────────────────────────────────────────────────────

class ScoreEntrySavedState extends ScoreEntryState {
  const ScoreEntrySavedState();
}
