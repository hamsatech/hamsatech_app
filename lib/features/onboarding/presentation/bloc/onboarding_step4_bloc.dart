import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
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
    // Goal data itself is persisted by the sibling OnboardingStep3Bloc's
    // submit (PUT /api/v2/onboarding/step-3, which already includes
    // goal30Day/goal6Month — see onboarding_step3_screen.dart, which fires
    // both blocs' submits together). This bloc only owns the local
    // "profile setup" completion flag; it used to also call the backend
    // itself (POST /api/v1/onboarding/goals), but that route was never
    // mounted server-side (always 404'd) and was redundant with Step 3's
    // save regardless — removed rather than implemented.
    await StorageService.setProfileSetupComplete(true);
    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
  }

  OnboardingStep4State _validate(OnboardingStep4State s) {
    final hasAnyGoal = s.goal30Value.isNotEmpty || s.goal6MonthValue.isNotEmpty;
    if (!hasAnyGoal) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please fill in at least one goal to continue',
      );
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
