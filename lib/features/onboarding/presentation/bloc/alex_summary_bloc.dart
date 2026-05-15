import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alex_summary_entity.dart';
import 'alex_summary_event.dart';
import 'alex_summary_state.dart';

class AlexSummaryBloc extends Bloc<AlexSummaryEvent, AlexSummaryState> {
  AlexSummaryBloc() : super(const AlexSummaryState()) {
    on<AlexSummaryLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    AlexSummaryLoadRequested event,
    Emitter<AlexSummaryState> emit,
  ) async {
    emit(state.copyWith(status: AlexSummaryStatus.loading));

    try {
      const summary = AlexSummaryEntity(
        discipline: 'Air Pistol',
        goal: '560 in 30d',
        restingHr: '68 bpm',
        coachStatus: 'Not linked',
      );

      emit(
        state.copyWith(
          status: AlexSummaryStatus.loaded,
          summary: summary,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AlexSummaryStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
