import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/session_summary_repository.dart';
import 'session_summary_event.dart';
import 'session_summary_state.dart';

class SessionSummaryBloc
    extends Bloc<SessionSummaryEvent, SessionSummaryState> {
  SessionSummaryBloc({required SessionSummaryRepository repository})
      : _repository = repository,
        super(const SessionSummaryInitial()) {
    on<SessionSummaryLoadRequested>(_onLoad);
    on<SessionSummarySeriesSelected>(_onSeriesSelected);
  }

  final SessionSummaryRepository _repository;

  Future<void> _onLoad(
    SessionSummaryLoadRequested event,
    Emitter<SessionSummaryState> emit,
  ) async {
    emit(const SessionSummaryLoading());
    try {
      final data = await _repository.getSummary();
      emit(SessionSummaryLoaded(data: data, selectedSeriesIndex: 0));
    } catch (e) {
      emit(SessionSummaryError(e.toString()));
    }
  }

  void _onSeriesSelected(
    SessionSummarySeriesSelected event,
    Emitter<SessionSummaryState> emit,
  ) {
    final s = state;
    if (s is SessionSummaryLoaded) {
      emit(s.copyWith(selectedSeriesIndex: event.seriesIndex));
    }
  }
}
