import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/session_series_entity.dart';
import '../domain/repositories/score_entry_repository.dart';
import 'score_entry_event.dart';
import 'score_entry_state.dart';

class ScoreEntryBloc extends Bloc<ScoreEntryEvent, ScoreEntryState> {
  ScoreEntryBloc({required ScoreEntryRepository repository})
      : _repository = repository,
        super(const ScoreEntryInitial()) {
    on<ScoreEntryStartRequested>(_onStart);
    on<ScoreScoreSelected>(_onScoreSelected);
    on<ScoreEntryUndoLast>(_onUndo);
    on<ScoreEntrySeriesConfirmed>(_onSeriesConfirmed);
    on<ScoreEntryEditRequested>(_onEditRequested);
    on<ScoreEntryFinalConfirmed>(_onFinalConfirmed);
  }

  final ScoreEntryRepository _repository;

  void _onStart(ScoreEntryStartRequested event, Emitter<ScoreEntryState> emit) {
    if (state is ScoreEntryActiveState) return;
    final config = _repository.getConfig();
    emit(ScoreEntryActiveState(
      sessionTitle: config.sessionTitle,
      completedSeries: const [],
      currentShots: const [],
      totalSeries: config.totalSeries,
      shotsPerSeries: config.shotsPerSeries,
    ));
  }

  void _onScoreSelected(
      ScoreScoreSelected event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState) return;

    final updated = [...s.currentShots, event.score];

    if (updated.length >= s.shotsPerSeries) {
      emit(SeriesCompleteState(
        sessionTitle: s.sessionTitle,
        previouslyCompletedSeries: s.completedSeries,
        justCompletedShots: updated,
        totalSeries: s.totalSeries,
        shotsPerSeries: s.shotsPerSeries,
      ));
    } else {
      emit(s.copyWith(currentShots: updated));
    }
  }

  void _onUndo(ScoreEntryUndoLast event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState || !s.canUndo) return;
    emit(s.copyWith(
      currentShots: s.currentShots.sublist(0, s.currentShots.length - 1),
    ));
  }

  void _onSeriesConfirmed(
      ScoreEntrySeriesConfirmed event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! SeriesCompleteState) return;

    final newSeries = SessionSeries(
      seriesNumber: s.justCompletedSeriesNumber,
      shots: s.justCompletedShots,
      shotsPerSeries: s.shotsPerSeries,
    );
    final allCompleted = [...s.previouslyCompletedSeries, newSeries];

    if (s.isLastSeries) {
      emit(AllSeriesCompleteState(allSeries: allCompleted));
    } else {
      emit(ScoreEntryActiveState(
        sessionTitle: s.sessionTitle,
        completedSeries: allCompleted,
        currentShots: const [],
        totalSeries: s.totalSeries,
        shotsPerSeries: s.shotsPerSeries,
      ));
    }
  }

  void _onEditRequested(
      ScoreEntryEditRequested event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! SeriesCompleteState) return;
    emit(ScoreEntryActiveState(
      sessionTitle: s.sessionTitle,
      completedSeries: s.previouslyCompletedSeries,
      currentShots: s.justCompletedShots,
      totalSeries: s.totalSeries,
      shotsPerSeries: s.shotsPerSeries,
    ));
  }

  Future<void> _onFinalConfirmed(
      ScoreEntryFinalConfirmed event, Emitter<ScoreEntryState> emit) async {
    final s = state;
    if (s is! AllSeriesCompleteState) return;
    await _repository.saveScores(s.allSeries);
    emit(const ScoreEntrySavedState());
  }
}
