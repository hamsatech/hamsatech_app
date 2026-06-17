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

// ── Active — user enters one total score per series ───────────────────────────

class ScoreEntryActiveState extends ScoreEntryState {
  const ScoreEntryActiveState({
    required this.sessionTitle,
    required this.totalSeries,
    required this.shotsPerSeries,
    required this.enteredTotals,
  });

  final String sessionTitle;
  final int totalSeries;
  final int shotsPerSeries;
  final List<double> enteredTotals;

  int get currentSeriesNumber => enteredTotals.length + 1;
  bool get isComplete => enteredTotals.length >= totalSeries;
  double get maxSeriesScore => shotsPerSeries * 10.9;
  double get maxTotalScore => totalSeries * maxSeriesScore;
  double get runningTotal => enteredTotals.fold(0.0, (sum, t) => sum + t);
  bool get canUndo => enteredTotals.isNotEmpty;

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String get formattedRunningTotal => _fmt(runningTotal);
  String get formattedMaxTotalScore => _fmt(maxTotalScore);
  String get formattedMaxSeriesScore => _fmt(maxSeriesScore);
  String formattedEnteredTotal(int index) => _fmt(enteredTotals[index]);

  ScoreEntryActiveState copyWith({List<double>? enteredTotals}) =>
      ScoreEntryActiveState(
        sessionTitle: sessionTitle,
        totalSeries: totalSeries,
        shotsPerSeries: shotsPerSeries,
        enteredTotals: enteredTotals ?? this.enteredTotals,
      );

  @override
  List<Object?> get props => [
        sessionTitle,
        totalSeries,
        shotsPerSeries,
        enteredTotals,
      ];
}

// ── Saved ─────────────────────────────────────────────────────────────────────

class ScoreEntrySavedState extends ScoreEntryState {
  const ScoreEntrySavedState();
}

// ── Legacy states — kept so dead routes compile; not emitted in current flow ──

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

  int get justCompletedSeriesNumber => previouslyCompletedSeries.length + 1;

  double get justCompletedTotal =>
      justCompletedShots.fold(0.0, (sum, s) => sum + s.numeric);

  String get formattedTotal {
    final t = justCompletedTotal;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  bool get isLastSeries => previouslyCompletedSeries.length + 1 >= totalSeries;

  @override
  List<Object?> get props => [
        sessionTitle,
        previouslyCompletedSeries,
        justCompletedShots,
        totalSeries,
        shotsPerSeries,
      ];
}

class AllSeriesCompleteState extends ScoreEntryState {
  const AllSeriesCompleteState({required this.allSeries});

  final List<SessionSeries> allSeries;

  double get grandTotal => allSeries.fold(0.0, (sum, s) => sum + s.total);

  String get formattedGrandTotal {
    final t = grandTotal;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [allSeries];
}
