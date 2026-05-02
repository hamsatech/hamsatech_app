import 'package:equatable/equatable.dart';

abstract class OnboardingStep4Event extends Equatable {
  const OnboardingStep4Event();

  @override
  List<Object?> get props => [];
}

class OnGoal30Changed extends OnboardingStep4Event {
  final String value;
  const OnGoal30Changed(this.value);

  @override
  List<Object?> get props => [value];
}

class OnGoal6MonthChanged extends OnboardingStep4Event {
  final String value;
  const OnGoal6MonthChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnStep4Submit extends OnboardingStep4Event {
  const OnStep4Submit();
}
