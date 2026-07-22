import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'lifestyle_wellness_event.dart';
import 'lifestyle_wellness_state.dart';

class LifestyleWellnessBloc
    extends Bloc<LifestyleWellnessEvent, LifestyleWellnessState> {
  LifestyleWellnessBloc() : super(const LifestyleWellnessState()) {
    on<OnDietTypeChanged>(_onDietTypeChanged);
    on<OnOutsideFoodFrequencyChanged>(_onOutsideFoodFrequencyChanged);
    on<OnSleepTimeChanged>(_onSleepTimeChanged);
    on<OnWakeTimeChanged>(_onWakeTimeChanged);
    on<OnLoadOnboarding>(_onLoadOnboarding);
    on<OnLifestyleWellnessSubmit>(_onSubmit);
  }

  void _onDietTypeChanged(
    OnDietTypeChanged event,
    Emitter<LifestyleWellnessState> emit,
  ) {
    final next =
        state.copyWith(dietType: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onOutsideFoodFrequencyChanged(
    OnOutsideFoodFrequencyChanged event,
    Emitter<LifestyleWellnessState> emit,
  ) {
    final next = state.copyWith(
        outsideFoodFrequency: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onSleepTimeChanged(
    OnSleepTimeChanged event,
    Emitter<LifestyleWellnessState> emit,
  ) {
    final next =
        state.copyWith(sleepTime: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onWakeTimeChanged(
    OnWakeTimeChanged event,
    Emitter<LifestyleWellnessState> emit,
  ) {
    final next =
        state.copyWith(wakeTime: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<LifestyleWellnessState> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final dietType = data['diet_type'] as String?;
      final outsideFoodFrequency = data['outside_food_frequency'] as String?;
      final sleepTime = data['sleep_time'] as String?;
      final wakeTime = data['wake_time'] as String?;

      if (dietType == null &&
          outsideFoodFrequency == null &&
          sleepTime == null &&
          wakeTime == null) {
        return;
      }

      final next = state.copyWith(
        dietType: dietType ?? state.dietType,
        outsideFoodFrequency: outsideFoodFrequency ?? state.outsideFoodFrequency,
        sleepTime: sleepTime ?? state.sleepTime,
        wakeTime: wakeTime ?? state.wakeTime,
      );
      emit(_validate(next));
      debugPrint('[LIFESTYLE WELLNESS] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint('[LIFESTYLE WELLNESS] GET onboarding failed (non-fatal): $e');
    }
  }

  Future<void> _onSubmit(
    OnLifestyleWellnessSubmit event,
    Emitter<LifestyleWellnessState> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep5(
        dietType: validated.dietType,
        outsideFoodFrequency: validated.outsideFoodFrequency,
        sleepTime: validated.sleepTime,
        wakeTime: validated.wakeTime,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[LIFESTYLE WELLNESS] PUT step-5 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  LifestyleWellnessState _validate(LifestyleWellnessState s) {
    if (s.dietType.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your diet type');
    }
    if (s.outsideFoodFrequency.isEmpty) {
      return s.copyWith(
          isValid: false,
          errorMessage: 'Please enter your outside food frequency');
    }
    if (s.sleepTime.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your sleep time');
    }
    if (s.wakeTime.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your wake time');
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
