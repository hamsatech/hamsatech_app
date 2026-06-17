import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import 'onboarding_step2_event.dart';
import 'onboarding_step2_state.dart';

class OnboardingStep2Bloc
    extends Bloc<OnboardingStep2Event, OnboardingStep2State> {
  OnboardingStep2Bloc() : super(const OnboardingStep2State()) {
    on<OnDisciplineChanged>(_onDisciplineChanged);
    on<OnExperienceChanged>(_onExperienceChanged);
    on<OnYearsIncrement>(_onYearsIncrement);
    on<OnYearsDecrement>(_onYearsDecrement);
    on<OnAcademyChanged>(_onAcademyChanged);
    on<OnStep2Submit>(_onSubmit);
  }

  void _onDisciplineChanged(
    OnDisciplineChanged event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next =
        state.copyWith(discipline: event.discipline, errorMessage: null);
    emit(_validate(next));
  }

  void _onExperienceChanged(
    OnExperienceChanged event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next =
        state.copyWith(experience: event.experience, errorMessage: null);
    emit(_validate(next));
  }

  void _onYearsIncrement(
    OnYearsIncrement event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next = state.copyWith(
      yearsShoot: state.yearsShoot + 1,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  void _onYearsDecrement(
    OnYearsDecrement event,
    Emitter<OnboardingStep2State> emit,
  ) {
    if (state.yearsShoot <= 0) return;
    final next = state.copyWith(
      yearsShoot: state.yearsShoot - 1,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  void _onAcademyChanged(
    OnAcademyChanged event,
    Emitter<OnboardingStep2State> emit,
  ) {
    emit(state.copyWith(academy: event.academy.trim(), errorMessage: null));
  }

  Future<void> _onSubmit(
    OnStep2Submit event,
    Emitter<OnboardingStep2State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }
    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));

    // Fire-and-forget: sync shooting profile to mobile backend.
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId != null) {
      Future(() async {
        try {
          await ApiService.instance.saveOnboardingShootingProfile(
            athleteId: athleteId,
            discipline: state.discipline,
            experienceLevel: state.experience,
            yearsShooting: state.yearsShoot,
            academyOrClub: state.academy,
          );
          debugPrint(
              '[ONBOARDING] shooting-profile synced athleteId=$athleteId');
        } catch (e) {
          debugPrint(
              '[ONBOARDING] shooting-profile sync failed (non-fatal): $e');
        }
      });
    } else {
      debugPrint('[ONBOARDING] shooting-profile skipped — no athlete_id yet');
    }
  }

  OnboardingStep2State _validate(OnboardingStep2State s) {
    if (s.discipline.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please select a discipline',
      );
    }
    if (s.experience.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please select your experience level',
      );
    }
    if (s.yearsShoot < 0) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Years shooting cannot be negative',
      );
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
