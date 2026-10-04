import 'package:equatable/equatable.dart';
import '../../domain/entities/assessment_result_entity.dart';
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
    this.totalQuestions = 0,
    this.answeredCount = 0,
    this.categoryScores = const [],
    this.insights = const [],
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

  // Populated from GET/POST /api/v2/psychology-assessment* — [questions] only
  // holds the questions fetched so far this session (server serves one at a
  // time), so "last question"/"progress" must be derived from these server
  // counts rather than questions.length.
  final int totalQuestions;
  final int answeredCount;
  final List<CategoryScoreEntity> categoryScores;
  final List<AssessmentInsightEntity> insights;

  BaselineQuestionEntity? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  bool get isLastQuestion =>
      questions.isNotEmpty &&
      currentQuestionIndex == questions.length - 1 &&
      totalQuestions > 0 &&
      answeredCount == totalQuestions - 1;

  double get assessmentProgress =>
      totalQuestions == 0 ? 0 : (currentQuestionIndex + 1) / totalQuestions;

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
    int? totalQuestions,
    int? answeredCount,
    List<CategoryScoreEntity>? categoryScores,
    List<AssessmentInsightEntity>? insights,
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
        totalQuestions: totalQuestions ?? this.totalQuestions,
        answeredCount: answeredCount ?? this.answeredCount,
        categoryScores: categoryScores ?? this.categoryScores,
        insights: insights ?? this.insights,
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
        totalQuestions,
        answeredCount,
        categoryScores,
        insights,
      ];
}

enum OnboardingStep { athleteDetails, backgroundContext, assessment, complete }

enum OnboardingStatus { initial, loading, success, failure }
