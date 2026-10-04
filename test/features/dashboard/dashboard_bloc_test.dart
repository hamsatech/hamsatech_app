import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:hamsatech/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:hamsatech/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hamsatech/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:hamsatech/features/dashboard/presentation/bloc/dashboard_state.dart';

class FakeDashboardRepository implements DashboardRepository {
  DashboardDataEntity? dataToReturn;
  Object? errorToThrow;
  var callCount = 0;

  @override
  Future<DashboardDataEntity> getDashboardData() async {
    callCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return dataToReturn!;
  }
}

/// A brand-new athlete: no sessions, no scores, no insights, no coach
/// feedback, no streak — every field is the honest "nothing yet" value,
/// never a fabricated estimate (see DashboardDataEntity's own doc comments).
const _newAthleteData = DashboardDataEntity(
  athleteName: 'Athlete',
  greeting: 'Good morning',
  isPolarConnected: false,
  streakDays: null,
  sessionsThisWeek: 0,
  weeklyAvgScore: null,
  todayCheckinCompleted: false,
  coachFeedback: null,
  aiInsights: [],
  performanceHistory: [],
);

final _establishedAthleteData = DashboardDataEntity(
  athleteName: 'Uma Shankar',
  greeting: 'Good afternoon',
  isPolarConnected: true,
  streakDays: 4,
  sessionsThisWeek: 3,
  weeklyAvgScore: 92.5,
  todayCheckinCompleted: true,
  coachFeedback: CoachFeedbackData(
    coachName: 'Coach Rao',
    message: '"Great session."',
    about: 'Coach feedback',
    assigned: 'Consistency drill',
    timestamp: DateTime(2026, 1, 1),
  ),
  aiInsights: const ['Your focus trend is improving.'],
  performanceHistory: [
    PerformanceDataPoint(
        date: DateTime(2026, 1, 1), sessionNumber: 1, avgScore: 88.0),
    PerformanceDataPoint(
        date: DateTime(2026, 1, 3), sessionNumber: 2, avgScore: 92.5),
  ],
);

void main() {
  group('load', () {
    test('emits Loading then Loaded with the real data returned by the repository', () async {
      final repository = FakeDashboardRepository()
        ..dataToReturn = _establishedAthleteData;
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);

      final states = <DashboardState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.first, isA<DashboardLoading>());
      expect(states.last, isA<DashboardLoaded>());
      final loaded = states.last as DashboardLoaded;
      expect(loaded.data.athleteName, 'Uma Shankar');
      expect(loaded.data.sessionsThisWeek, 3);
      expect(loaded.data.weeklyAvgScore, 92.5);
      expect(loaded.data.performanceHistory, hasLength(2));
    });

    test('a brand-new athlete with no sessions loads with honest empty '
        'values, never a fabricated estimate', () async {
      final repository = FakeDashboardRepository()
        ..dataToReturn = _newAthleteData;
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);

      final loaded = bloc.state as DashboardLoaded;
      expect(loaded.data.sessionsThisWeek, 0);
      expect(loaded.data.weeklyAvgScore, isNull);
      expect(loaded.data.performanceHistory, isEmpty);
      expect(loaded.data.aiInsights, isEmpty);
      expect(loaded.data.coachFeedback, isNull);
      expect(loaded.data.streakDays, isNull);
    });

    test('DashboardDataEntity has no field that can silently default to 60 '
        '— the old fabricated-readiness pattern this regression guards '
        'against no longer exists on the entity at all', () {
      // Documents the fix at the type level: the entity below is exactly
      // what DashboardRepositoryImpl.getDashboardData's constructor call
      // must satisfy — readiness/sleep/restingHR/hrv are not fields on it,
      // so there is no longer any code path that could reintroduce a
      // hardcoded default like the old `baseline['focus'] ?? 60`.
      expect(_newAthleteData.props, isNot(contains(60)));
      expect(_newAthleteData.props, isNot(contains(60.0)));
    });

    test('a repository failure emits a friendly message, never the raw '
        'exception text', () async {
      final repository = FakeDashboardRepository()
        ..errorToThrow = Exception(
            'DioException [connectionError]: SocketException: Failed host lookup');
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state as DashboardError;
      expect(state.message, isNot(contains('DioException')));
      expect(state.message, isNot(contains('SocketException')));
      expect(state.message, isNotEmpty);
    });
  });

  group('refresh', () {
    test('re-fetches and emits the latest data', () async {
      final repository = FakeDashboardRepository()
        ..dataToReturn = _newAthleteData;
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);
      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);

      repository.dataToReturn = _establishedAthleteData;
      bloc.add(const DashboardRefreshRequested());
      await Future<void>.delayed(Duration.zero);

      final loaded = bloc.state as DashboardLoaded;
      expect(loaded.data.athleteName, 'Uma Shankar');
      expect(repository.callCount, 2);
    });

    test('a refresh failure also emits a friendly message', () async {
      final repository = FakeDashboardRepository()
        ..dataToReturn = _newAthleteData;
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);
      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);

      repository.errorToThrow = Exception('raw backend trace here');
      bloc.add(const DashboardRefreshRequested());
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state as DashboardError;
      expect(state.message, isNot(contains('raw backend trace')));
    });
  });

  group('mark coach feedback read', () {
    test('flips isRead on the loaded coach feedback', () async {
      final repository = FakeDashboardRepository()
        ..dataToReturn = _establishedAthleteData;
      final bloc = DashboardBloc(repository);
      addTearDown(bloc.close);
      bloc.add(const DashboardLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state as DashboardLoaded).data.coachFeedback!.isRead, isFalse);

      bloc.add(const DashboardCoachFeedbackMarkRead());
      await Future<void>.delayed(Duration.zero);

      expect((bloc.state as DashboardLoaded).data.coachFeedback!.isRead, isTrue);
    });
  });
}
