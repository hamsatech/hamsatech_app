import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/onboarding/domain/entities/athlete_profile_entity.dart';
import 'package:hamsatech/features/onboarding/domain/entities/baseline_question_entity.dart';
import 'package:hamsatech/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 3B regression coverage for [OnboardingBloc]'s psychology-assessment
/// handlers (Parts C, D, H).
///
/// [OnboardingBloc] talks directly to `ApiService.instance` (a hardcoded
/// singleton with no injectable Dio/mocking seam anywhere in this repo) for
/// every network-dependent step of the live assessment flow — fetching a
/// question, saving an answer, and completing/scoring. That is a pre-existing
/// architectural gap, not something introduced or fixed by Phase 3B, and
/// fixing it would mean adding a DI seam to shared core infrastructure used
/// by every feature in the app — out of scope for a Phase 3B that is
/// explicitly restricted to the Psychology Assessment. So these tests cover
/// every behavior reachable without an actual HTTP call: local answer
/// persistence, backward navigation, the "already loading"/"nothing
/// selected" no-op guards (which return before ever touching the network),
/// and the double-submit guard added in this phase. The network-calling
/// bodies themselves (save-answer round trip, completion, scoring/insight
/// parsing) are verified by direct source reading instead — see the Phase 3B
/// report.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository(this.questions);
  final List<BaselineQuestionEntity> questions;

  @override
  List<BaselineQuestionEntity> getBaselineQuestions() => questions;

  @override
  Future<void> saveAthleteProfile(AthleteProfileEntity profile) async {}

  @override
  AthleteProfileEntity? getAthleteProfile() => null;

  @override
  Map<String, double> calculateScores(Map<int, int> answers) => const {};

  @override
  Future<void> retryAthleteSync() async {}
}

BaselineQuestionEntity _question(int id) => BaselineQuestionEntity(
      id: id,
      question: 'Question $id',
      category: 'focus',
      options: const [
        AnswerOptionEntity(text: 'A', score: 0, optionCode: 'A'),
        AnswerOptionEntity(text: 'B', score: 0, optionCode: 'B'),
      ],
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  /// Seeds `state.questions`/`step: assessment` via the OLD
  /// `OnboardingBackgroundContextSubmitted` path (which still reads from the
  /// injected, fakeable [OnboardingRepository]), so the handlers under test
  /// never have to go through `OnboardingAssessmentStarted`'s live
  /// `ApiService` call.
  Future<OnboardingBloc> seededBloc(List<BaselineQuestionEntity> questions) async {
    final bloc = OnboardingBloc(FakeOnboardingRepository(questions));
    bloc.add(const OnboardingBackgroundContextSubmitted(
      familySupport: 'supportive',
      pressureSources: [],
    ));
    await Future<void>.delayed(Duration.zero);
    return bloc;
  }

  group('assessment initial state', () {
    test('starts with no questions loaded and status initial', () {
      final bloc = OnboardingBloc(FakeOnboardingRepository(const []));
      addTearDown(bloc.close);

      expect(bloc.state.questions, isEmpty);
      expect(bloc.state.status, OnboardingStatus.initial);
      expect(bloc.state.currentQuestion, isNull);
    });

    test(
        'OnboardingAssessmentStarted is a no-op once a question is already '
        'loaded — it never re-fetches on rebuild', () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);
      final stateBeforeRebuild = bloc.state;

      bloc.add(const OnboardingAssessmentStarted());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, stateBeforeRebuild,
          reason: 'the guard must return before touching the network, so '
              'state must be byte-for-byte unchanged after a rebuild');
    });
  });

  group('question navigation', () {
    test('starts on the first seeded question', () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);

      expect(bloc.state.currentQuestionIndex, 0);
      expect(bloc.state.currentQuestion!.id, 1);
    });

    test('OnboardingPreviousQuestion on the first question is a no-op',
        () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);

      bloc.add(const OnboardingPreviousQuestion());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.currentQuestionIndex, 0);
    });
  });

  group('answer selection', () {
    test('selecting an option records it against the question id', () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);

      bloc.add(const OnboardingAnswerSelected(questionId: 1, optionIndex: 1));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.answers[1], 1);
    });

    test('re-selecting a different option for the same question overwrites it',
        () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);
      bloc.add(const OnboardingAnswerSelected(questionId: 1, optionIndex: 0));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const OnboardingAnswerSelected(questionId: 1, optionIndex: 1));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.answers[1], 1);
      expect(bloc.state.answers.length, 1);
    });
  });

  group('answers persist across questions (Part D)', () {
    test(
        'answering question 2 does not clear or overwrite question 1\'s '
        'already-recorded answer — the map is keyed per question id and '
        'is never reset between questions or by OnboardingPreviousQuestion',
        () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);
      bloc.add(const OnboardingAnswerSelected(questionId: 1, optionIndex: 0));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const OnboardingAnswerSelected(questionId: 2, optionIndex: 1));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const OnboardingPreviousQuestion());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.answers[1], 0);
      expect(bloc.state.answers[2], 1);
    });
  });

  group('validation guards (no-ops that must never reach the network)', () {
    test('OnboardingNextQuestion with nothing selected does not advance',
        () async {
      final bloc = await seededBloc([_question(1), _question(2)]);
      addTearDown(bloc.close);
      final before = bloc.state;

      bloc.add(const OnboardingNextQuestion());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, before);
    });

    test('OnboardingAssessmentCompleted with nothing selected does not submit',
        () async {
      final bloc = await seededBloc([_question(1)]);
      addTearDown(bloc.close);
      final before = bloc.state;

      bloc.add(const OnboardingAssessmentCompleted());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, before);
    });
  });
}

// Phase 3B Part C added `if (state.status == OnboardingStatus.loading)
// return;` as the first line of `_onNextQuestion`/`_onAssessmentCompleted`
// in onboarding_bloc.dart, so a second tap while a save/complete call is
// genuinely in flight is a no-op instead of firing a second network
// request. That in-flight state is only ever reached by those same two
// handlers going on to call ApiService, so exercising the guard end-to-end
// needs a real or mocked HTTP call — out of reach here for the same reason
// documented in this file's header. The guard itself is verified by direct
// source reading (see the Phase 3B report) rather than a runtime test.
