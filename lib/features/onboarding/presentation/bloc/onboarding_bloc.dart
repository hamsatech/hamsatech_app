import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/athlete_profile_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._repository) : super(OnboardingState(
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

  void _onAssessmentStarted(
    OnboardingAssessmentStarted event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.questions.isNotEmpty) return;
    final questions = _repository.getBaselineQuestions();
    emit(state.copyWith(
      questions: questions,
      step: OnboardingStep.assessment,
      currentQuestionIndex: 0,
    ));
  }

  void _onAssessmentStarted(
    OnboardingAssessmentStarted event,
    Emitter<OnboardingState> emit,
  ) {
    // Within the same session the bloc already holds questions — don't reset.
    if (state.questions.isNotEmpty) return;
    final questions = _repository.getBaselineQuestions();
    // Restore saved progress from a previous cold-start session if present.
    final saved = StorageService.getQuestionnaireProgress();
    final savedIndex = saved != null ? saved['index'] as int : 0;
    final savedAnswers =
        saved != null ? saved['answers'] as Map<int, int> : <int, int>{};
    emit(state.copyWith(
      questions: questions,
      step: OnboardingStep.assessment,
      currentQuestionIndex: savedIndex.clamp(0, questions.length - 1),
      answers: savedAnswers,
    ));
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
    if (!state.isLastQuestion) {
      final newIndex = state.currentQuestionIndex + 1;
      emit(state.copyWith(currentQuestionIndex: newIndex));
      await StorageService.saveQuestionnaireProgress(newIndex, state.answers);
    }
  }

  void _onPreviousQuestion(
    OnboardingPreviousQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  Future<void> _onAssessmentCompleted(
    OnboardingAssessmentCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final scores = _repository.calculateScores(state.answers);
      final profile = AthleteProfileEntity(
        name: state.name,
        age: state.age,
        sportDomain: state.sportDomain,
        experienceLevel: state.experienceLevel,
        familySupport: state.familySupport,
        pressureSources: state.pressureSources,
        baselineScores: scores,
      );
      await _repository.saveAthleteProfile(profile);
      await StorageService.clearQuestionnaireProgress();
      emit(state.copyWith(
        baselineScores: scores,
        step: OnboardingStep.complete,
        status: OnboardingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
