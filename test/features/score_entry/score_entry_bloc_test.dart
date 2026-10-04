import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/services/session_memory.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/score_entry/bloc/score_entry_bloc.dart';
import 'package:hamsatech/features/score_entry/bloc/score_entry_event.dart';
import 'package:hamsatech/features/score_entry/bloc/score_entry_state.dart';
import 'package:hamsatech/features/score_entry/domain/entities/score_entry_config.dart';
import 'package:hamsatech/features/score_entry/domain/repositories/score_entry_repository.dart';
import 'package:hamsatech/features/session_report/presentation/screens/session_reflection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pure-Dart fake — no network, no platform channels.
class _FakeScoreEntryRepository implements ScoreEntryRepository {
  bool saveTotalsCalled = false;
  int saveTotalsInvocationCount = 0;

  @override
  ScoreEntryConfig getConfig() => const ScoreEntryConfig(
        sessionTitle: 'Test Session',
        totalSeries: 1,
        shotsPerSeries: 10,
      );

  @override
  Future<void> saveTotals(List<double> totals, int shotsPerSeries) async {
    saveTotalsCalled = true;
    saveTotalsInvocationCount++;
  }
}

void main() {
  setUp(() async {
    // Standard shared_preferences test setup — StorageService.init() would
    // otherwise throw (LateInitializationError) the moment AuthHelper reads
    // from it. Empty store means AuthHelper.getCurrentAthleteId() returns
    // null, so _syncSeries/_syncSessionEnd take their early-return
    // "skipped" branch and never attempt a real network call.
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test(
      'ScoreEntryFinalConfirmed leaves SessionMemory.sessionId set after a '
      'successful save — SessionReflectionScreen is reached right after '
      'this on the non-Polar path and needs it to still resolve '
      '(StorageService\'s copy is already gone by this point, consumed by '
      'LiveTrainingRepositoryImpl.startSession() earlier in the flow), so '
      'clearing it here left the reflection screen with no session to save '
      'against', () async {
    SessionMemory.sessionId = 'existing-session-id';

    final repository = _FakeScoreEntryRepository();
    final bloc = ScoreEntryBloc(repository: repository);
    addTearDown(bloc.close);

    bloc.add(const ScoreEntryStartRequested());
    bloc.add(const SeriesTotalSubmitted(
        92.5)); // totalSeries=1, so this completes it

    final savedFuture =
        bloc.stream.firstWhere((s) => s is ScoreEntrySavedState);
    bloc.add(const ScoreEntryFinalConfirmed());
    final saved = await savedFuture;

    expect(saved, isA<ScoreEntrySavedState>());
    expect(repository.saveTotalsCalled, isTrue);
    expect(SessionMemory.sessionId, 'existing-session-id');
  });

  test(
    'ScoreEntryFinalConfirmed awaits the series/score/completion calls '
    'before reporting success — the active state visibly flips to '
    'isSubmitting before ScoreEntrySavedState is ever emitted, instead of '
    'success being reported the instant the button is tapped',
    () async {
      SessionMemory.sessionId = 'existing-session-id';

      final repository = _FakeScoreEntryRepository();
      final bloc = ScoreEntryBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const ScoreEntryStartRequested());
      bloc.add(const SeriesTotalSubmitted(92.5));

      final states = <ScoreEntryState>[];
      final subscription = bloc.stream.listen(states.add);
      final savedFuture =
          bloc.stream.firstWhere((s) => s is ScoreEntrySavedState);

      bloc.add(const ScoreEntryFinalConfirmed());
      await savedFuture;
      await subscription.cancel();

      final submittingIndex = states.indexWhere(
        (s) => s is ScoreEntryActiveState && s.isSubmitting,
      );
      final savedIndex = states.indexWhere((s) => s is ScoreEntrySavedState);

      expect(submittingIndex, isNonNegative,
          reason: 'an isSubmitting state must be emitted while the '
              'series/score/completion calls are in flight');
      expect(savedIndex, greaterThan(submittingIndex),
          reason: 'ScoreEntrySavedState must only follow the awaited calls, '
              'never precede or race them');
    },
  );

  test(
    'a fresh ScoreEntryFinalConfirmed dispatch while already submitting is '
    'ignored, so double-tapping Continue cannot fire the save twice',
    () async {
      SessionMemory.sessionId = 'existing-session-id';

      final repository = _FakeScoreEntryRepository();
      final bloc = ScoreEntryBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const ScoreEntryStartRequested());
      bloc.add(const SeriesTotalSubmitted(92.5));

      final savedFuture =
          bloc.stream.firstWhere((s) => s is ScoreEntrySavedState);

      bloc.add(const ScoreEntryFinalConfirmed());
      bloc.add(const ScoreEntryFinalConfirmed());
      await savedFuture;

      expect(repository.saveTotalsInvocationCount, 1);
    },
  );

  test(
    'regression: the exact reported bug — after LiveTrainingRepositoryImpl.'
    'startSession() has already consumed StorageService\'s session_id '
    '(the Polar/live-training telemetry path), a completed score entry '
    'must still leave enough for the following reflection screen to '
    'resolve a session to save against',
    () async {
      // Mirrors LiveTrainingRepositoryImpl.startSession(): reads then
      // clears the persisted copy, leaving only SessionMemory behind.
      await StorageService.saveSessionId('existing-session-id');
      await StorageService.clearSessionId();
      SessionMemory.sessionId = 'existing-session-id';
      // No athlete_id yet — matches every other test in this file: with
      // AuthHelper.getCurrentAthleteId() null, _syncSeries/_syncSessionEnd
      // take their early-return "skipped" branch instead of making a real
      // network call the test environment can't serve.

      final repository = _FakeScoreEntryRepository();
      final bloc = ScoreEntryBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const ScoreEntryStartRequested());
      bloc.add(const SeriesTotalSubmitted(92.5));
      final savedFuture =
          bloc.stream.firstWhere((s) => s is ScoreEntrySavedState);
      bloc.add(const ScoreEntryFinalConfirmed());
      await savedFuture;

      // The athlete_id becomes available once the reflection screen reads
      // it (it's already resolved from auth by then in production) —
      // seeded only now so the assertion below exercises the real
      // resolveReflectionIdentity() path.
      await StorageService.saveAthleteId('ASA001');

      // Previously threw StateError("No active session...") here — both
      // sources were empty by this point.
      final identity = resolveReflectionIdentity();
      expect(identity.sessionId, 'existing-session-id');
    },
  );
}
