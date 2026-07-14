import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import 'lifestyle_wellness_event.dart';
import 'lifestyle_wellness_state.dart';

class LifestyleWellnessBloc
    extends Bloc<LifestyleWellnessEvent, LifestyleWellnessState> {
  LifestyleWellnessBloc() : super(const LifestyleWellnessState()) {
    on<OnDietTypeChanged>(_onDietTypeChanged);
    on<OnOutsideFoodFrequencyChanged>(_onOutsideFoodFrequencyChanged);
    on<OnSleepTimeChanged>(_onSleepTimeChanged);
    on<OnWakeTimeChanged>(_onWakeTimeChanged);
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

  Future<void> _onSubmit(
    OnLifestyleWellnessSubmit event,
    Emitter<LifestyleWellnessState> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    // No backend endpoint exists yet for this screen — store locally only.
    // TODO(onboarding-flow): wire to a real API once backend/product decide
    // where this screen sits in the onboarding sequence.
    await StorageService.saveLifestyleWellness({
      'diet_type': validated.dietType,
      'outside_food_frequency': validated.outsideFoodFrequency,
      'sleep_time': validated.sleepTime,
      'wake_time': validated.wakeTime,
    });

    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
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
