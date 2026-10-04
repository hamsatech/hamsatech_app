import 'package:equatable/equatable.dart';

import '../domain/entities/session_series_entity.dart';

abstract class ScoreEntryEvent extends Equatable {
  const ScoreEntryEvent();

  @override
  List<Object?> get props => [];
}

class ScoreEntryStartRequested extends ScoreEntryEvent {
  const ScoreEntryStartRequested();
}

// User submits the total score for one series
class SeriesTotalSubmitted extends ScoreEntryEvent {
  const SeriesTotalSubmitted(this.total);

  final double total;

  @override
  List<Object?> get props => [total];
}

class ScoreEntryUndoLast extends ScoreEntryEvent {
  const ScoreEntryUndoLast();
}

class ScoreEntryFinalConfirmed extends ScoreEntryEvent {
  const ScoreEntryFinalConfirmed();
}

// ── Legacy events — no longer dispatched in the active flow ───────────────────

class ScoreScoreSelected extends ScoreEntryEvent {
  const ScoreScoreSelected(this.score);

  final ScoreValue score;

  @override
  List<Object?> get props => [score];
}

class ScoreEntrySeriesConfirmed extends ScoreEntryEvent {
  const ScoreEntrySeriesConfirmed();
}

class ScoreEntryEditRequested extends ScoreEntryEvent {
  const ScoreEntryEditRequested();
}

class ScoreEntryVoiceInputRequested extends ScoreEntryEvent {
  const ScoreEntryVoiceInputRequested();
}
