import 'package:equatable/equatable.dart';

abstract class LifestyleWellnessEvent extends Equatable {
  const LifestyleWellnessEvent();

  @override
  List<Object?> get props => [];
}

class OnDietTypeChanged extends LifestyleWellnessEvent {
  final String value;
  const OnDietTypeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnOutsideFoodFrequencyChanged extends LifestyleWellnessEvent {
  final String value;
  const OnOutsideFoodFrequencyChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnSleepTimeChanged extends LifestyleWellnessEvent {
  final String value;
  const OnSleepTimeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnWakeTimeChanged extends LifestyleWellnessEvent {
  final String value;
  const OnWakeTimeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Fetches the athlete's saved onboarding progress so Step 5 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen
/// opens, mirroring AcademicProfileBloc's OnLoadOnboarding.
class OnLoadOnboarding extends LifestyleWellnessEvent {
  const OnLoadOnboarding();
}

class OnLifestyleWellnessSubmit extends LifestyleWellnessEvent {
  const OnLifestyleWellnessSubmit();
}
