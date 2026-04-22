import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingAthleteDetailsSubmitted extends OnboardingEvent {
  const OnboardingAthleteDetailsSubmitted({
    required this.name,
    required this.age,
    required this.sportDomain,
    required this.experienceLevel,
  });
  final String name;
  final int age;
  final String sportDomain;
  final String experienceLevel;
  @override
  List<Object?> get props => [name, age, sportDomain, experienceLevel];
}

class OnboardingBackgroundContextSubmitted extends OnboardingEvent {
  const OnboardingBackgroundContextSubmitted({
    required this.familySupport,
    required this.pressureSources,
  });
  final String familySupport;
  final List<String> pressureSources;
  @override
  List<Object?> get props => [familySupport, pressureSources];
}

class OnboardingAnswerSelected extends OnboardingEvent {
  const OnboardingAnswerSelected({
    required this.questionId,
    required this.optionIndex,
  });
  final int questionId;
  final int optionIndex;
  @override
  List<Object?> get props => [questionId, optionIndex];
}

class OnboardingNextQuestion extends OnboardingEvent {
  const OnboardingNextQuestion();
}

class OnboardingPreviousQuestion extends OnboardingEvent {
  const OnboardingPreviousQuestion();
}

class OnboardingAssessmentCompleted extends OnboardingEvent {
  const OnboardingAssessmentCompleted();
}
