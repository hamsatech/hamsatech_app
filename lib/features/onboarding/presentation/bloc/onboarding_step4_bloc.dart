import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_step4_event.dart';
import 'onboarding_step4_state.dart';

class OnboardingStep4Bloc
    extends Bloc<OnboardingStep4Event, OnboardingStep4State> {
  OnboardingStep4Bloc() : super(const OnboardingStep4State()) {
    on<OnGoal30Changed>(_onGoal30Changed);
    on<OnGoal6MonthChanged>(_onGoal6MonthChanged);
    on<OnStep4Submit>(_onSubmit);
  }

  void _onGoal30Changed(
    OnGoal30Changed event,
    Emitter<OnboardingStep4State> emit,
  ) {
    final next = state.copyWith(
      goal30Value: event.value.trim(),
      errorMessage: null,
    );
    emit(_validate(next));
  }

  void _onGoal6MonthChanged(
    OnGoal6MonthChanged event,
    Emitter<OnboardingStep4State> emit,
  ) {
    final next = state.copyWith(
      goal6MonthValue: event.value.trim(),
      errorMessage: null,
    );
    emit(_validate(next));
  }

  Future<void> _onSubmit(
    OnStep4Submit event,
    Emitter<OnboardingStep4State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }
    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
  }

  OnboardingStep4State _validate(OnboardingStep4State s) {
    final hasAnyGoal =
        s.goal30Value.isNotEmpty || s.goal6MonthValue.isNotEmpty;
    if (!hasAnyGoal) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please fill in at least one goal to continue',
      );
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
