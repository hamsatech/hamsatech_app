import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _onAnswerSelected(
    OnboardingAnswerSelected event,
    Emitter<OnboardingState> emit,
  ) {
    final updated = Map<int, int>.from(state.answers)
      ..[event.questionId] = event.optionIndex;
    emit(state.copyWith(answers: updated));
  }

  void _onNextQuestion(
    OnboardingNextQuestion event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.isLastQuestion) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1));
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
