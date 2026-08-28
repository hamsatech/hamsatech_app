import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
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
      final athleteId = AuthHelper.getCurrentAthleteId();
      if (athleteId != null) {
        try {
          final res = await ApiService.instance.getOnboardingSummary(athleteId);
          final data = res.data;
          if (data is Map) {
            final summary = AlexSummaryEntity(
              discipline: data['discipline']?.toString() ?? 'Air Pistol',
              goal: data['goal_30d']?.toString() ?? '560 in 30d',
              restingHr: data['baseline_hr'] != null
                  ? '${data['baseline_hr']} bpm'
                  : '68 bpm',
              coachStatus: data['coach_status']?.toString() ?? 'Not linked',
            );
            debugPrint('[ALEX SUMMARY] loaded from API athleteId=$athleteId');
            emit(state.copyWith(
              status: AlexSummaryStatus.loaded,
              summary: summary,
            ));
            return;
          }
        } catch (e) {
          debugPrint('[ALEX SUMMARY] API call failed, using defaults: $e');
        }
      }

      // Fallback: hardcoded summary when API is unavailable or athlete_id unknown.
      const summary = AlexSummaryEntity(
        discipline: 'Air Pistol',
        goal: '560 in 30d',
        restingHr: '68 bpm',
        coachStatus: 'Not linked',
      );
      emit(state.copyWith(
        status: AlexSummaryStatus.loaded,
        summary: summary,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AlexSummaryStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}
