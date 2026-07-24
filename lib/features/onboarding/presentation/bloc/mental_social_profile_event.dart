import 'package:equatable/equatable.dart';

abstract class MentalSocialProfileEvent extends Equatable {
  const MentalSocialProfileEvent();

  @override
  List<Object?> get props => [];
}

class OnFriendCircleChanged extends MentalSocialProfileEvent {
  final String value;
  const OnFriendCircleChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnAngerPatternChanged extends MentalSocialProfileEvent {
  final String value;
  const OnAngerPatternChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnSadnessPatternChanged extends MentalSocialProfileEvent {
  final String value;
  const OnSadnessPatternChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnReasonForShootingChanged extends MentalSocialProfileEvent {
  final String value;
  const OnReasonForShootingChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnAthleteGoalChanged extends MentalSocialProfileEvent {
  final String value;
  const OnAthleteGoalChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Fetches the athlete's saved onboarding progress so Step 6 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen
/// opens, mirroring LifestyleWellnessBloc's OnLoadOnboarding.
class OnLoadOnboarding extends MentalSocialProfileEvent {
  const OnLoadOnboarding();
}

class OnMentalSocialProfileSubmit extends MentalSocialProfileEvent {
  const OnMentalSocialProfileSubmit();
}
