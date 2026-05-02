import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_step3_event.dart';
import 'onboarding_step3_state.dart';

class OnboardingStep3Bloc
    extends Bloc<OnboardingStep3Event, OnboardingStep3State> {
  OnboardingStep3Bloc() : super(const OnboardingStep3State()) {
    on<OnAvgScoreChanged>(_onAvgScoreChanged);
    on<OnTargetScoreChanged>(_onTargetScoreChanged);
    on<OnFactorToggled>(_onFactorToggled);
    on<OnStep3Submit>(_onSubmit);
  }

  void _onAvgScoreChanged(
    OnAvgScoreChanged event,
    Emitter<OnboardingStep3State> emit,
  ) {
    final next = state.copyWith(avgScore: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onTargetScoreChanged(
    OnTargetScoreChanged event,
    Emitter<OnboardingStep3State> emit,
  ) {
    final next = state.copyWith(targetScore: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onFactorToggled(
    OnFactorToggled event,
    Emitter<OnboardingStep3State> emit,
  ) {
    final current = List<String>.from(state.selectedFactors);

    if (current.contains(event.factorId)) {
      current.remove(event.factorId);
    } else if (current.length < state.maxFactorSelection) {
      current.add(event.factorId);
    }
    // Silently ignore tap when max reached and factor not yet selected

    emit(_validate(state.copyWith(selectedFactors: current, errorMessage: null)));
  }

  Future<void> _onSubmit(
    OnStep3Submit event,
    Emitter<OnboardingStep3State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }
    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
  }

  OnboardingStep3State _validate(OnboardingStep3State s) {
    if (s.avgScore.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please enter your average practice score',
      );
    }
    if (s.targetScore.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please enter your target score',
      );
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
