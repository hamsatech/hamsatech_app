import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'onboarding_step3_event.dart';
import 'onboarding_step3_state.dart';

class OnboardingStep3Bloc
    extends Bloc<OnboardingStep3Event, OnboardingStep3State> {
  OnboardingStep3Bloc() : super(const OnboardingStep3State()) {
    on<OnAvgScoreChanged>(_onAvgScoreChanged);
    on<OnTargetScoreChanged>(_onTargetScoreChanged);
    on<OnFactorToggled>(_onFactorToggled);
    on<OnLoadOnboarding>(_onLoadOnboarding);
    on<OnStep3Submit>(_onSubmit);
  }

  void _onAvgScoreChanged(
    OnAvgScoreChanged event,
    Emitter<OnboardingStep3State> emit,
  ) {
    final next =
        state.copyWith(avgScore: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onTargetScoreChanged(
    OnTargetScoreChanged event,
    Emitter<OnboardingStep3State> emit,
  ) {
    final next =
        state.copyWith(targetScore: event.value.trim(), errorMessage: null);
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

    emit(_validate(
        state.copyWith(selectedFactors: current, errorMessage: null)));
  }

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<OnboardingStep3State> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final avgPracticeScore = data['average_practice_score'];
      final targetScore = data['target_score'];
      final performanceBlockers = data['performance_blockers'] as List<dynamic>?;

      if (avgPracticeScore == null &&
          targetScore == null &&
          performanceBlockers == null) {
        return;
      }

      final next = state.copyWith(
        avgScore: avgPracticeScore != null
            ? avgPracticeScore.toString()
            : state.avgScore,
        targetScore:
            targetScore != null ? targetScore.toString() : state.targetScore,
        selectedFactors: performanceBlockers != null
            ? performanceBlockers.cast<String>()
            : state.selectedFactors,
      );
      emit(_validate(next));
      debugPrint('[ONBOARDING STEP3] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint('[ONBOARDING STEP3] GET onboarding failed (non-fatal): $e');
    }
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

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep3(
        averagePracticeScore: num.parse(validated.avgScore),
        targetScore: num.parse(validated.targetScore),
        performanceBlockers: validated.selectedFactors,
        goal30Day: event.goal30Day,
        goal6Month: event.goal6Month,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[ONBOARDING STEP3] PUT step-3 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
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
