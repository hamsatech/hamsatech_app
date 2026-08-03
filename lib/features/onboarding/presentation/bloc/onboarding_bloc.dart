import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/assessment_result_entity.dart';
import '../../domain/entities/baseline_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._repository)
      : super(OnboardingState(
          questions: [],
        )) {
    on<OnboardingAthleteDetailsSubmitted>(_onAthleteDetails);
    on<OnboardingBackgroundContextSubmitted>(_onBackgroundContext);
    on<OnboardingAssessmentStarted>(_onAssessmentStarted);
    on<OnboardingAnswerSelected>(_onAnswerSelected);
    on<OnboardingNextQuestion>(_onNextQuestion);
    on<OnboardingPreviousQuestion>(_onPreviousQuestion);
    on<OnboardingAssessmentCompleted>(_onAssessmentCompleted);
  }

  final OnboardingRepository _repository;

  void _onAthleteDetails(
    OnboardingAthleteDetailsSubmitted event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      name: event.name,
      age: event.age,
      sportDomain: event.sportDomain,
      experienceLevel: event.experienceLevel,
      step: OnboardingStep.backgroundContext,
    ));
  }

  void _onBackgroundContext(
    OnboardingBackgroundContextSubmitted event,
    Emitter<OnboardingState> emit,
  ) {
    final questions = _repository.getBaselineQuestions();
    emit(state.copyWith(
      familySupport: event.familySupport,
      pressureSources: event.pressureSources,
      questions: questions,
      step: OnboardingStep.assessment,
      currentQuestionIndex: 0,
    ));
  }

  Future<void> _onAssessmentStarted(
    OnboardingAssessmentStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    // Session already has a question loaded (e.g. rebuild) — don't re-fetch.
    if (state.questions.isNotEmpty) return;
    try {
      final res = await ApiService.instance.getPsychologyAssessmentStatus();
      final data = res.data as Map<String, dynamic>;
      final total = data['totalQuestions'] as int;
      final answered = data['answeredCount'] as int;
      final isComplete = data['isComplete'] as bool;
      final nextQuestionJson = data['nextQuestion'] as Map<String, dynamic>?;

      if (isComplete || nextQuestionJson == null) {
        await _completeAssessment(emit, total: total, answered: answered);
        return;
      }

      final question = _mapQuestion(nextQuestionJson);
      emit(state.copyWith(
        questions: [question],
        currentQuestionIndex: 0,
        totalQuestions: total,
        answeredCount: answered,
        step: OnboardingStep.assessment,
      ));
      debugPrint(
          '[Assessment] loaded question ${question.id} ($answered/$total answered)');
    } catch (e) {
      debugPrint('[Assessment] GET psychology-assessment failed: $e');
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  /// Maps a QuestionResponse JSON object (GET /api/v2/psychology-assessment)
  /// onto the existing BaselineQuestionEntity/AnswerOptionEntity shape.
  /// [AnswerOptionEntity.score] has no server equivalent (never exposed to
  /// the client) and is set to 0 — it is only ever read by the now-unused
  /// local OnboardingRepository.calculateScores() path.
  BaselineQuestionEntity _mapQuestion(Map<String, dynamic> json) {
    final options = (json['options'] as List)
        .map((raw) => raw as Map<String, dynamic>)
        .map((o) => AnswerOptionEntity(
              text: o['optionText'] as String? ?? '',
              score: 0,
              optionCode: o['optionCode'] as String,
            ))
        .toList();
    return BaselineQuestionEntity(
      id: json['questionNumber'] as int,
      question: json['questionText'] as String? ?? '',
      category: json['category'] as String? ?? '',
      options: options,
    );
  }

  Future<void> _onAnswerSelected(
    OnboardingAnswerSelected event,
    Emitter<OnboardingState> emit,
  ) async {
    final updated = Map<int, int>.from(state.answers)
      ..[event.questionId] = event.optionIndex;
    emit(state.copyWith(answers: updated));
    await StorageService.saveQuestionnaireProgress(
        state.currentQuestionIndex, updated);
  }

  Future<void> _onNextQuestion(
    OnboardingNextQuestion event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.isLastQuestion) return;
    final question = state.currentQuestion;
    final selectedIndex = question != null ? state.answers[question.id] : null;
    if (question == null || selectedIndex == null) return;
    final optionCode = question.options[selectedIndex].optionCode;
    if (optionCode == null) return;

    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final res = await ApiService.instance.saveAssessmentAnswer(
        questionNumber: question.id,
        optionCode: optionCode,
      );
      final progress = res.data as Map<String, dynamic>;
      final answered = progress['answeredCount'] as int;
      final total = progress['totalQuestions'] as int;
      final isComplete = progress['isComplete'] as bool;

      if (isComplete) {
        await _completeAssessment(emit, total: total, answered: answered);
        return;
      }

      final newIndex = state.currentQuestionIndex + 1;
      if (newIndex < state.questions.length) {
        // Already cached from an earlier forward pass (user went Back then
        // Next again) — no need to re-fetch.
        emit(state.copyWith(
          currentQuestionIndex: newIndex,
          answeredCount: answered,
          totalQuestions: total,
          status: OnboardingStatus.initial,
        ));
        return;
      }

      final statusRes = await ApiService.instance.getPsychologyAssessmentStatus();
      final data = statusRes.data as Map<String, dynamic>;
      final nextQuestionJson = data['nextQuestion'] as Map<String, dynamic>?;
      if (nextQuestionJson == null) {
        await _completeAssessment(emit, total: total, answered: answered);
        return;
      }

      final nextQuestion = _mapQuestion(nextQuestionJson);
      emit(state.copyWith(
        questions: [...state.questions, nextQuestion],
        currentQuestionIndex: newIndex,
        answeredCount: answered,
        totalQuestions: total,
        status: OnboardingStatus.initial,
      ));
    } catch (e) {
      debugPrint('[Assessment] answer submit failed: $e');
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onPreviousQuestion(
    OnboardingPreviousQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentQuestionIndex > 0) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  Future<void> _onAssessmentCompleted(
    OnboardingAssessmentCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final question = state.currentQuestion;
    final selectedIndex = question != null ? state.answers[question.id] : null;
    if (question == null || selectedIndex == null) return;
    final optionCode = question.options[selectedIndex].optionCode;
    if (optionCode == null) return;

    debugPrint(
        '[Assessment] AssessmentCompleted: answered=${state.answeredCount + 1}');
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final res = await ApiService.instance.saveAssessmentAnswer(
        questionNumber: question.id,
        optionCode: optionCode,
      );
      final progress = res.data as Map<String, dynamic>;
      final answered = progress['answeredCount'] as int;
      final total = progress['totalQuestions'] as int;
      await _completeAssessment(emit, total: total, answered: answered);
    } catch (e) {
      debugPrint('[Assessment] final answer submit failed: $e');
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  /// Calls POST /api/v2/psychology-assessment/complete, stores the resulting
  /// category scores/insights in state, and marks onboarding complete
  /// locally — this is the same flag [StorageService.isOnboardingComplete]
  /// that the (locked) splash/resume flow and this screen's own listener
  /// already depend on, so it must keep being set here.
  Future<void> _completeAssessment(
    Emitter<OnboardingState> emit, {
    required int total,
    required int answered,
  }) async {
    try {
      final res = await ApiService.instance.completeAssessment();
      final data = res.data as Map<String, dynamic>;
      final categoryScores = (data['categoryScores'] as List)
          .map((raw) => raw as Map<String, dynamic>)
          .map((c) => CategoryScoreEntity(
                category: c['category'] as String,
                displayName: c['displayName'] as String,
                childDescription: c['childDescription'] as String?,
                iconSlug: c['iconSlug'] as String?,
                score: c['score'] as num?,
                interpretation: c['interpretation'] as String?,
              ))
          .toList();
      final insights = (data['insights'] as List)
          .map((raw) => raw as Map<String, dynamic>)
          .map((i) => AssessmentInsightEntity(
                category: i['category'] as String,
                score: i['score'] as num?,
                title: i['title'] as String?,
                insightText: i['insightText'] as String?,
              ))
          .toList();

      await StorageService.setOnboardingComplete(true);

      emit(state.copyWith(
        step: OnboardingStep.complete,
        status: OnboardingStatus.success,
        totalQuestions: total,
        answeredCount: answered,
        categoryScores: categoryScores,
        insights: insights,
      ));
    } catch (e) {
      debugPrint('[Assessment] POST complete failed: $e');
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
