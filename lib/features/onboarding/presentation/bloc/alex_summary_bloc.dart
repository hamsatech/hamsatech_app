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
        String discipline = 'Air Pistol';
        String goal = '560 in 30d';
        // No backend endpoint exposes coach-linkage status for an athlete
        // (checked: neither GET /api/v2/onboarding nor any academies/coach
        // route returns it) — kept as a static default, not fabricated
        // per-athlete data, until that data source exists.
        const coachStatus = 'Not linked';

        // GET /api/v2/onboarding (OnboardingStatusResponse) — replaces the
        // old GET /api/v1/onboarding/summary/{id}, which was never mounted
        // server-side and always 404'd. Response keys are snake_case (see
        // OnboardingStep3Bloc._onLoadOnboarding for the same convention).
        try {
          final res = await ApiService.instance.getOnboardingStatus();
          final data = res.data;
          if (data is Map) {
            discipline = data['discipline']?.toString() ?? discipline;
            goal = data['goal_30_day']?.toString() ?? goal;
          }
        } catch (e) {
          debugPrint('[ALEX SUMMARY] onboarding status call failed, using defaults: $e');
        }

        String restingHr = '68 bpm';
        try {
          final baselineRes = await ApiService.instance.getBaselineHR(athleteId);
          final baselineData = baselineRes.data;
          if (baselineData is Map && baselineData['resting_heart_rate'] != null) {
            restingHr = '${baselineData['resting_heart_rate']} bpm';
          }
        } catch (e) {
          debugPrint('[ALEX SUMMARY] baseline read-back failed, using default: $e');
        }

        final summary = AlexSummaryEntity(
          discipline: discipline,
          goal: goal,
          restingHr: restingHr,
          coachStatus: coachStatus,
        );
        debugPrint('[ALEX SUMMARY] loaded from API athleteId=$athleteId');
        emit(state.copyWith(
          status: AlexSummaryStatus.loaded,
          summary: summary,
        ));
        return;
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
