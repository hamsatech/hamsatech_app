import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/live_training/bloc/live_training_bloc.dart';
import 'package:hamsatech/features/live_training/bloc/live_training_event.dart';
import 'package:hamsatech/features/live_training/bloc/live_training_state.dart';
import 'package:hamsatech/features/live_training/domain/entities/live_training_config.dart';
import 'package:hamsatech/features/live_training/domain/entities/session_mood.dart';
import 'package:hamsatech/features/live_training/domain/repositories/live_training_repository.dart';

/// Records call order and lets the test control exactly when
/// flushHrTelemetry()/saveReflection() resolve, so the await-ordering and
/// failure-propagation requirements can be verified without any platform
/// channel or network dependency.
class _FakeLiveTrainingRepository implements LiveTrainingRepository {
  final calls = <String>[];
  final flushCompleter = Completer<void>();

  /// When set, saveReflection() throws this instead of succeeding.
  Object? reflectionError;

  @override
  LiveTrainingConfig getConfig() => const LiveTrainingConfig(
        sessionTitle: 'Test Session',
        plannedShots: 10,
        shotsPerSeries: 10,
        baselineHr: 65,
      );

  @override
  Future<String> startSession(String title) async {
    calls.add('startSession');
    return 'session-1';
  }

  @override
  Future<void> saveReflection({
    required String sessionId,
    required SessionMood? mood,
    required String whatWorked,
    required String whatDidnt,
  }) async {
    calls.add('saveReflection');
    final error = reflectionError;
    if (error != null) throw error;
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required int durationMinutes,
    required SessionMood? mood,
    required String whatWorked,
    required String whatDidnt,
  }) async {
    calls.add('completeSession');
  }

  @override
  void stopHrTelemetry() {
    calls.add('stopHrTelemetry');
  }

  @override
  Future<void> flushHrTelemetry() {
    calls.add('flushHrTelemetry');
    return flushCompleter.future;
  }
}

void main() {
  group('LiveTrainingBloc HR flush ordering', () {
    test(
        '_onEndRequested stops HR telemetry, awaits the flush, '
        'then transitions to ReflectingState only once it resolves', () async {
      final repo = _FakeLiveTrainingRepository();
      final bloc = LiveTrainingBloc(repo);
      addTearDown(bloc.close);

      bloc.add(const LiveTrainingStartRequested());
      await bloc.stream.firstWhere((s) => s is LiveSessionActiveState);

      final reflectingFuture = bloc.stream.firstWhere((s) => s is ReflectingState);

      bloc.add(const LiveTrainingEndRequested());

      // Let the handler run up to (and block on) the flush await — the
      // fake's flush never resolves on its own, so ReflectingState must
      // not appear yet.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isNot(isA<ReflectingState>()));
      expect(repo.calls, ['startSession', 'stopHrTelemetry', 'flushHrTelemetry']);

      repo.flushCompleter.complete();
      final reflecting = await reflectingFuture;
      expect(reflecting, isA<ReflectingState>());
    });

    test(
        '_onSeriesCompleted (final series) stops HR telemetry, awaits the '
        'flush, then transitions to ReflectingState only once it resolves',
        () async {
      final repo = _FakeLiveTrainingRepository();
      final bloc = LiveTrainingBloc(repo);
      addTearDown(bloc.close);

      // plannedShots / shotsPerSeries = 1 total series, so the first
      // LiveTrainingSeriesCompleted is already the final one.
      bloc.add(const LiveTrainingStartRequested());
      await bloc.stream.firstWhere((s) => s is LiveSessionActiveState);

      final reflectingFuture = bloc.stream.firstWhere((s) => s is ReflectingState);

      bloc.add(const LiveTrainingSeriesCompleted());

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isNot(isA<ReflectingState>()));
      expect(repo.calls, ['startSession', 'stopHrTelemetry', 'flushHrTelemetry']);

      repo.flushCompleter.complete();
      final reflecting = await reflectingFuture;
      expect(reflecting, isA<ReflectingState>());
    });
  });

  group('LiveTrainingBloc reflection save ordering', () {
    Future<LiveTrainingBloc> bootstrapToReflecting(_FakeLiveTrainingRepository repo) async {
      final bloc = LiveTrainingBloc(repo);
      bloc.add(const LiveTrainingStartRequested());
      await bloc.stream.firstWhere((s) => s is LiveSessionActiveState);
      final reflectingFuture = bloc.stream.firstWhere((s) => s is ReflectingState);
      bloc.add(const LiveTrainingEndRequested());
      repo.flushCompleter.complete();
      await reflectingFuture;
      return bloc;
    }

    test(
        '_onSaveRequested saves the reflection before completing the '
        'session, then emits ReflectionSavedState on success', () async {
      final repo = _FakeLiveTrainingRepository();
      final bloc = await bootstrapToReflecting(repo);
      addTearDown(bloc.close);
      repo.calls.clear();

      final savedFuture = bloc.stream.firstWhere((s) => s is ReflectionSavedState);
      bloc.add(const ReflectSaveRequested());
      final saved = await savedFuture;

      expect(saved, isA<ReflectionSavedState>());
      expect(repo.calls, ['saveReflection', 'completeSession']);
    });

    test(
        '_onSaveRequested does NOT emit ReflectionSavedState and does NOT '
        'call completeSession when saveReflection fails — the failure must '
        'not be silently treated as a successful save', () async {
      final repo = _FakeLiveTrainingRepository()..reflectionError = Exception('network error');
      final bloc = await bootstrapToReflecting(repo);
      addTearDown(bloc.close);
      repo.calls.clear();

      bloc.add(const ReflectSaveRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isNot(isA<ReflectionSavedState>()));
      expect(bloc.state, isA<ReflectingState>());
      expect((bloc.state as ReflectingState).isSubmitting, isFalse);
      expect(repo.calls, ['saveReflection']); // completeSession must never run
    });
  });
}
