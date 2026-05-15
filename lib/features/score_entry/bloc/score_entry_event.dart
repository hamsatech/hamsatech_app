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

class ScoreScoreSelected extends ScoreEntryEvent {
  const ScoreScoreSelected(this.score);

  final ScoreValue score;

  @override
  List<Object?> get props => [score];
}

class ScoreEntryUndoLast extends ScoreEntryEvent {
  const ScoreEntryUndoLast();
}

class ScoreEntrySeriesConfirmed extends ScoreEntryEvent {
  const ScoreEntrySeriesConfirmed();
}

class ScoreEntryEditRequested extends ScoreEntryEvent {
  const ScoreEntryEditRequested();
}

class ScoreEntryFinalConfirmed extends ScoreEntryEvent {
  const ScoreEntryFinalConfirmed();
}

// Placeholder for future voice input integration
class ScoreEntryVoiceInputRequested extends ScoreEntryEvent {
  const ScoreEntryVoiceInputRequested();
}
