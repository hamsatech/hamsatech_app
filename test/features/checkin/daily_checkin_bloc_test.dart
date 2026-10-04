import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/checkin/domain/entities/daily_checkin_entity.dart';
import 'package:hamsatech/features/checkin/domain/repositories/daily_checkin_repository.dart';
import 'package:hamsatech/features/checkin/presentation/bloc/daily_checkin_bloc.dart';
import 'package:hamsatech/features/checkin/presentation/bloc/daily_checkin_event.dart';
import 'package:hamsatech/features/checkin/presentation/bloc/daily_checkin_state.dart';

class FakeDailyCheckinRepository implements DailyCheckinRepository {
  DailyCheckinEntity? existing;
  String? sleepEstimate;
  Object? saveError;
  var saveCallCount = 0;
  DailyCheckinEntity? lastSaved;

  @override
  DailyCheckinEntity? getTodayCheckin() => existing;

  @override
  String? getPolarSleepEstimate() => sleepEstimate;

  @override
  Future<void> saveCheckin(DailyCheckinEntity checkin) async {
    saveCallCount++;
    lastSaved = checkin;
    if (saveError != null) throw saveError!;
  }
}

void main() {
  late FakeDailyCheckinRepository repository;

  setUp(() {
    repository = FakeDailyCheckinRepository();
  });

  group('initial state (Part E item 7 — already-completed-today behavior)', () {
    test('with no existing check-in, starts blank with energy defaulted to 5',
        () async {
      final bloc = DailyCheckinBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DailyCheckinLoadRequested());
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state as DailyCheckinEditing;
      expect(state.mood, isNull);
      expect(state.sleep, isNull);
      expect(state.energy, 5);
      expect(state.emotions, isEmpty);
      expect(state.canSubmit, isFalse);
    });
  });

  test('pre-fills every field from an existing today check-in', () async {
    final now = DateTime(2026, 1, 1);
    repository.existing = DailyCheckinEntity(
      id: 'existing-id',
      date: now,
      mood: MoodOption.good,
      energy: 7,
      sleep: SleepOption.h6to7,
      emotions: const [EmotionTag.motivated],
    );
    final bloc = DailyCheckinBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const DailyCheckinLoadRequested());
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as DailyCheckinEditing;
    expect(state.mood, MoodOption.good);
    expect(state.energy, 7);
    expect(state.sleep, SleepOption.h6to7);
    expect(state.emotions, [EmotionTag.motivated]);
  });

  group('submission', () {
    Future<DailyCheckinBloc> readyToSubmitBloc() async {
      final bloc = DailyCheckinBloc(repository);
      bloc.add(const DailyCheckinLoadRequested());
      bloc.add(const DailyCheckinMoodChanged(MoodOption.good));
      bloc.add(const DailyCheckinSleepChanged(SleepOption.h6to7));
      await Future<void>.delayed(Duration.zero);
      return bloc;
    }

    test('success emits DailyCheckinSuccess', () async {
      final bloc = await readyToSubmitBloc();
      addTearDown(bloc.close);

      bloc.add(const DailyCheckinSubmitRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<DailyCheckinSuccess>());
      expect(repository.saveCallCount, 1);
    });

    test(
        'failure preserves every field the athlete already entered — stays '
        'in DailyCheckinEditing, not a separate blank state', () async {
      repository.saveError = DioException(
        requestOptions: RequestOptions(path: 'api/v1/checkin/daily'),
        type: DioExceptionType.connectionError,
      );
      final bloc = await readyToSubmitBloc();
      addTearDown(bloc.close);
      bloc.add(const DailyCheckinEmotionToggled(EmotionTag.focused));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const DailyCheckinSubmitRequested());
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state;
      expect(state, isA<DailyCheckinEditing>());
      final editing = state as DailyCheckinEditing;
      expect(editing.mood, MoodOption.good,
          reason: 'mood must survive a failed submit');
      expect(editing.sleep, SleepOption.h6to7,
          reason: 'sleep must survive a failed submit');
      expect(editing.emotions, [EmotionTag.focused],
          reason: 'emotions must survive a failed submit');
      expect(editing.isSubmitting, isFalse);
      expect(editing.errorMessage, isNotNull);
    });

    test('failure never shows the raw exception/DioException text to the athlete',
        () async {
      repository.saveError = DioException(
        requestOptions: RequestOptions(path: 'api/v1/checkin/daily'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: 'api/v1/checkin/daily'),
          statusCode: 500,
          data: {'error': 'INTERNAL_SERVER_ERROR', 'trace': 'raw stack...'},
        ),
      );
      final bloc = await readyToSubmitBloc();
      addTearDown(bloc.close);

      bloc.add(const DailyCheckinSubmitRequested());
      await Future<void>.delayed(Duration.zero);

      final editing = bloc.state as DailyCheckinEditing;
      expect(editing.errorMessage, isNot(contains('DioException')));
      expect(editing.errorMessage, isNot(contains('INTERNAL_SERVER_ERROR')));
      expect(editing.errorMessage, isNot(contains('raw stack')));
    });

    test('a new field edit after a failure clears the error message', () async {
      repository.saveError = StateError('no athlete_id');
      final bloc = await readyToSubmitBloc();
      addTearDown(bloc.close);
      bloc.add(const DailyCheckinSubmitRequested());
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state as DailyCheckinEditing).errorMessage, isNotNull);

      bloc.add(const DailyCheckinEnergyChanged(8));
      await Future<void>.delayed(Duration.zero);

      expect((bloc.state as DailyCheckinEditing).errorMessage, isNull);
    });

    test(
        'duplicate-submit protection: a fresh submit dispatch while already '
        'submitting does not trigger a second backend call', () async {
      // Never resolves on its own — lets us dispatch a second submit while
      // the first is still genuinely in flight, not just "fast enough to
      // look concurrent".
      repository.saveError = null;
      final bloc = DailyCheckinBloc(_SlowRepository(repository));
      addTearDown(bloc.close);
      bloc.add(const DailyCheckinLoadRequested());
      bloc.add(const DailyCheckinMoodChanged(MoodOption.good));
      bloc.add(const DailyCheckinSleepChanged(SleepOption.h6to7));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const DailyCheckinSubmitRequested());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((bloc.state as DailyCheckinEditing).isSubmitting, isTrue);

      // Second tap while the first save is still pending.
      bloc.add(const DailyCheckinSubmitRequested());
      // Longer than _SlowRepository's own 100ms delay, so the first
      // (allowed) save has definitely completed by the time we assert —
      // a second, blocked dispatch would never reach the inner repository
      // at all, regardless of how long we wait.
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(repository.saveCallCount, 1,
          reason: 'canSubmit is false while isSubmitting, so a second '
              'dispatch must be a no-op, matching the same pattern already '
              'validated for ScoreEntryBloc');
    });
  });
}

/// Wraps a real fake but delays saveCheckin so a duplicate-submit test can
/// dispatch a second event while the first is still genuinely in flight.
class _SlowRepository implements DailyCheckinRepository {
  _SlowRepository(this._inner);
  final FakeDailyCheckinRepository _inner;

  @override
  DailyCheckinEntity? getTodayCheckin() => _inner.getTodayCheckin();

  @override
  String? getPolarSleepEstimate() => _inner.getPolarSleepEstimate();

  @override
  Future<void> saveCheckin(DailyCheckinEntity checkin) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _inner.saveCheckin(checkin);
  }
}
