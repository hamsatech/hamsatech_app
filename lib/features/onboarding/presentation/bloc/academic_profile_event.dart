import 'package:equatable/equatable.dart';

abstract class AcademicProfileEvent extends Equatable {
  const AcademicProfileEvent();

  @override
  List<Object?> get props => [];
}

class OnClassChanged extends AcademicProfileEvent {
  final String value;
  const OnClassChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnSchoolNameChanged extends AcademicProfileEvent {
  final String value;
  const OnSchoolNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnAcademicPerformanceChanged extends AcademicProfileEvent {
  final String value;
  const OnAcademicPerformanceChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Fetches the athlete's saved onboarding progress so Step 4 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen
/// opens, mirroring OnboardingStep3Bloc's OnLoadOnboarding.
class OnLoadOnboarding extends AcademicProfileEvent {
  const OnLoadOnboarding();
}

class OnAcademicProfileSubmit extends AcademicProfileEvent {
  const OnAcademicProfileSubmit();
}
