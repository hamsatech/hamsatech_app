import 'package:equatable/equatable.dart';

import 'onboarding_step2_state.dart';

abstract class OnboardingStep2Event extends Equatable {
  const OnboardingStep2Event();

  @override
  List<Object?> get props => [];
}

class OnDisciplineChanged extends OnboardingStep2Event {
  final String discipline;
  const OnDisciplineChanged(this.discipline);

  @override
  List<Object?> get props => [discipline];
}

class OnExperienceChanged extends OnboardingStep2Event {
  final String experience;
  const OnExperienceChanged(this.experience);

  @override
  List<Object?> get props => [experience];
}

class OnYearsIncrement extends OnboardingStep2Event {
  const OnYearsIncrement();
}

class OnYearsDecrement extends OnboardingStep2Event {
  const OnYearsDecrement();
}

class OnAcademySelected extends OnboardingStep2Event {
  final AcademyOption academy;
  const OnAcademySelected(this.academy);

  @override
  List<Object?> get props => [academy];
}

/// Fetches the academy list so the Step 2 picker can be populated
/// (GET /api/v2/academies). Dispatched once when the screen opens.
class OnLoadAcademies extends OnboardingStep2Event {
  const OnLoadAcademies();
}

/// Fetches the athlete's saved onboarding progress so Step 2 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen
/// opens, mirroring OnboardingStep1Bloc's OnLoadOnboarding.
class OnLoadOnboarding extends OnboardingStep2Event {
  const OnLoadOnboarding();
}

class OnStep2Submit extends OnboardingStep2Event {
  const OnStep2Submit();
}
