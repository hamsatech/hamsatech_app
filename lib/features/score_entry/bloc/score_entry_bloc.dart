import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/score_entry_repository.dart';
import 'score_entry_event.dart';
import 'score_entry_state.dart';

class ScoreEntryBloc extends Bloc<ScoreEntryEvent, ScoreEntryState> {
  ScoreEntryBloc({required ScoreEntryRepository repository})
      : _repository = repository,
        super(const ScoreEntryInitial()) {
    on<ScoreEntryStartRequested>(_onStart);
    on<SeriesTotalSubmitted>(_onTotalSubmitted);
    on<ScoreEntryUndoLast>(_onUndo);
    on<ScoreEntryFinalConfirmed>(_onFinalConfirmed);
    // Legacy event stubs — registered to prevent unhandled-event errors
    // if any old code path still dispatches them.
    on<ScoreScoreSelected>((_, __) {});
    on<ScoreEntrySeriesConfirmed>((_, __) {});
    on<ScoreEntryEditRequested>((_, __) {});
    on<ScoreEntryVoiceInputRequested>((_, __) {});
  }

  final ScoreEntryRepository _repository;

  void _onStart(
      ScoreEntryStartRequested event, Emitter<ScoreEntryState> emit) {
    if (state is ScoreEntryActiveState) return;
    final config = _repository.getConfig();
    emit(ScoreEntryActiveState(
      sessionTitle: config.sessionTitle,
      totalSeries: config.totalSeries,
      shotsPerSeries: config.shotsPerSeries,
      enteredTotals: const [],
    ));
  }

  void _onTotalSubmitted(
      SeriesTotalSubmitted event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState || s.isComplete) return;
    emit(s.copyWith(enteredTotals: [...s.enteredTotals, event.total]));
  }

  void _onUndo(ScoreEntryUndoLast event, Emitter<ScoreEntryState> emit) {
    final s = state;
    if (s is! ScoreEntryActiveState || !s.canUndo) return;
    final updated =
        s.enteredTotals.sublist(0, s.enteredTotals.length - 1);
    emit(s.copyWith(enteredTotals: updated));
  }

  Future<void> _onFinalConfirmed(
      ScoreEntryFinalConfirmed event,
      Emitter<ScoreEntryState> emit) async {
    final s = state;
    if (s is! ScoreEntryActiveState || !s.isComplete) return;
    await _repository.saveTotals(s.enteredTotals, s.shotsPerSeries);
    emit(const ScoreEntrySavedState());
  }
}
