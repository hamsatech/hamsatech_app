import 'package:equatable/equatable.dart';

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

class OnAcademyChanged extends OnboardingStep2Event {
  final String academy;
  const OnAcademyChanged(this.academy);

  @override
  List<Object?> get props => [academy];
}

class OnStep2Submit extends OnboardingStep2Event {
  const OnStep2Submit();
}
