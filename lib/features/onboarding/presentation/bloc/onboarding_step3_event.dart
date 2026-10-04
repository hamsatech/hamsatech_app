import 'package:equatable/equatable.dart';

abstract class OnboardingStep3Event extends Equatable {
  const OnboardingStep3Event();

  @override
  List<Object?> get props => [];
}

class OnAvgScoreChanged extends OnboardingStep3Event {
  final String value;
  const OnAvgScoreChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnTargetScoreChanged extends OnboardingStep3Event {
  final String value;
  const OnTargetScoreChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnFactorToggled extends OnboardingStep3Event {
  final String factorId;
  const OnFactorToggled(this.factorId);

  @override
  List<Object?> get props => [factorId];
}

/// Fetches the athlete's saved onboarding progress so Step 3 fields can be
/// prefilled (GET /api/v2/onboarding). Dispatched once when the screen
/// opens, mirroring OnboardingStep2Bloc's OnLoadOnboarding.
class OnLoadOnboarding extends OnboardingStep3Event {
  const OnLoadOnboarding();
}

/// [goal30Day]/[goal6Month] come from the sibling OnboardingStep4Bloc (the
/// goals fields reused on this screen) — OnboardingStep3Request requires
/// them alongside the score/blocker fields in a single PUT call.
class OnStep3Submit extends OnboardingStep3Event {
  final String goal30Day;
  final String goal6Month;
  const OnStep3Submit({required this.goal30Day, required this.goal6Month});

  @override
  List<Object?> get props => [goal30Day, goal6Month];
}
