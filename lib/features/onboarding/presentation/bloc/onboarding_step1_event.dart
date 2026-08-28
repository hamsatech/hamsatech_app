import 'package:equatable/equatable.dart';

abstract class OnboardingStep1Event extends Equatable {
  const OnboardingStep1Event();

  @override
  List<Object?> get props => [];
}

class OnNameChanged extends OnboardingStep1Event {
  final String name;
  const OnNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class OnAgeChanged extends OnboardingStep1Event {
  final String age;
  const OnAgeChanged(this.age);

  @override
  List<Object?> get props => [age];
}

class OnGenderSelected extends OnboardingStep1Event {
  final String gender;
  const OnGenderSelected(this.gender);

  @override
  List<Object?> get props => [gender];
}

class OnCityChanged extends OnboardingStep1Event {
  final String city;
  const OnCityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

class OnSubmit extends OnboardingStep1Event {
  const OnSubmit();
}

/// Fetches the athlete's saved onboarding progress so Step 1 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen opens.
class OnLoadOnboarding extends OnboardingStep1Event {
  const OnLoadOnboarding();
}

/// Fired when the user picks a date in the DOB field, alongside the existing
/// [OnAgeChanged] — carries the raw date needed for the step-1 API payload.
class OnDobSelected extends OnboardingStep1Event {
  final DateTime dob;
  const OnDobSelected(this.dob);

  @override
  List<Object?> get props => [dob];
}
