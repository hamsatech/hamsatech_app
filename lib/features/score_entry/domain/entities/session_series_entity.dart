import 'package:equatable/equatable.dart';

// ── Score value ───────────────────────────────────────────────────────────────

class ScoreValue extends Equatable {
  const ScoreValue({required this.display, required this.numeric});

  final String display; // '10.9', '10', '9', '8', '7', '6', '<5', 'X'
  final double numeric; // numeric equivalent

  static const all = [
    ScoreValue(display: '10.9', numeric: 10.9),
    ScoreValue(display: '10', numeric: 10.0),
    ScoreValue(display: '9', numeric: 9.0),
    ScoreValue(display: '8', numeric: 8.0),
    ScoreValue(display: '7', numeric: 7.0),
    ScoreValue(display: '6', numeric: 6.0),
    ScoreValue(display: '<5', numeric: 4.5),
    ScoreValue(display: 'X', numeric: 0.0),
  ];

  bool get isMiss => display == 'X';
  bool get isSubFive => display == '<5';

  @override
  List<Object?> get props => [display];
}

// ── Session series ─────────────────────────────────────────────────────────────

class SessionSeries extends Equatable {
  const SessionSeries({
    required this.seriesNumber,
    required this.shots,
    required this.shotsPerSeries,
  });

  final int seriesNumber;
  final List<ScoreValue> shots;
  final int shotsPerSeries;

  double get total => shots.fold(0.0, (sum, s) => sum + s.numeric);

  String get formattedTotal {
    final t = total;
    return t == t.truncateToDouble()
        ? t.toInt().toString()
        : t.toStringAsFixed(1);
  }

  bool get isComplete => shots.length >= shotsPerSeries;

  @override
  List<Object?> get props => [seriesNumber, shots, shotsPerSeries];
}
