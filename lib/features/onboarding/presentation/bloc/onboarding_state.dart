import 'package:equatable/equatable.dart';
import '../../domain/entities/baseline_question_entity.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.athleteDetails,
    this.name = '',
    this.age = 0,
    this.sportDomain = '',
    this.experienceLevel = '',
    this.familySupport = '',
    this.pressureSources = const [],
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.baselineScores = const {},
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  final OnboardingStep step;
  final String name;
  final int age;
  final String sportDomain;
  final String experienceLevel;
  final String familySupport;
  final List<String> pressureSources;
  final List<BaselineQuestionEntity> questions;
  final int currentQuestionIndex;
  final Map<int, int> answers; // questionId -> optionIndex
  final Map<String, double> baselineScores;
  final OnboardingStatus status;
  final String? errorMessage;

  BaselineQuestionEntity? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  bool get isLastQuestion =>
      currentQuestionIndex == questions.length - 1;

  double get assessmentProgress =>
      questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? name,
    int? age,
    String? sportDomain,
    String? experienceLevel,
    String? familySupport,
    List<String>? pressureSources,
    List<BaselineQuestionEntity>? questions,
    int? currentQuestionIndex,
    Map<int, int>? answers,
    Map<String, double>? baselineScores,
    OnboardingStatus? status,
    String? errorMessage,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        name: name ?? this.name,
        age: age ?? this.age,
        sportDomain: sportDomain ?? this.sportDomain,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        familySupport: familySupport ?? this.familySupport,
        pressureSources: pressureSources ?? this.pressureSources,
        questions: questions ?? this.questions,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        answers: answers ?? this.answers,
        baselineScores: baselineScores ?? this.baselineScores,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        step,
        name,
        age,
        sportDomain,
        experienceLevel,
        familySupport,
        pressureSources,
        currentQuestionIndex,
        answers,
        baselineScores,
        status,
        errorMessage,
      ];
}

enum OnboardingStep { athleteDetails, backgroundContext, assessment, complete }

enum OnboardingStatus { initial, loading, success, failure }
