import 'package:equatable/equatable.dart';

import '../domain/entities/session_mood.dart';

abstract class LiveTrainingState extends Equatable {
  const LiveTrainingState();

  @override
  List<Object?> get props => [];
}

class LiveTrainingInitial extends LiveTrainingState {
  const LiveTrainingInitial();
}

// ── Active session ────────────────────────────────────────────────────────────

class LiveSessionActiveState extends LiveTrainingState {
  const LiveSessionActiveState({
    required this.sessionId,
    required this.sessionTitle,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.currentSeriesIndex,
    required this.totalSeries,
    required this.shotsPerSeries,
    required this.baselineHr,
    this.simulatedHr,
    this.simulatedHrHistory = const [],
  });

  final String sessionId;
  final String sessionTitle;
  final int elapsedSeconds;
  final bool isPaused;
  final int currentSeriesIndex; // 0-based
  final int totalSeries;
  final int shotsPerSeries;
  final int baselineHr;

  // Simulated HR used when no Polar device is connected.
  // Driven by LiveTrainingBloc on each tick.
  final int? simulatedHr;
  final List<int> simulatedHrHistory; // capped at 30 samples

  String get formattedElapsed {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  int get seriesNumber => currentSeriesIndex + 1;
  int get seriesRemaining => totalSeries - currentSeriesIndex - 1;

  LiveSessionActiveState copyWith({
    int? elapsedSeconds,
    bool? isPaused,
    int? currentSeriesIndex,
    int? simulatedHr,
    List<int>? simulatedHrHistory,
  }) =>
      LiveSessionActiveState(
        sessionId: sessionId,
        sessionTitle: sessionTitle,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        isPaused: isPaused ?? this.isPaused,
        currentSeriesIndex: currentSeriesIndex ?? this.currentSeriesIndex,
        totalSeries: totalSeries,
        shotsPerSeries: shotsPerSeries,
        baselineHr: baselineHr,
        simulatedHr: simulatedHr ?? this.simulatedHr,
        simulatedHrHistory: simulatedHrHistory ?? this.simulatedHrHistory,
      );

  @override
  List<Object?> get props => [
        sessionId,
        sessionTitle,
        elapsedSeconds,
        isPaused,
        currentSeriesIndex,
        totalSeries,
        shotsPerSeries,
        baselineHr,
        simulatedHr,
        simulatedHrHistory,
      ];
}

// ── Reflecting ────────────────────────────────────────────────────────────────

class ReflectingState extends LiveTrainingState {
  const ReflectingState({
    required this.sessionId,
    required this.elapsedSeconds,
    this.mood,
    this.whatWorked = '',
    this.whatDidnt = '',
    this.isSubmitting = false,
  });

  final String sessionId;
  final int elapsedSeconds;
  final SessionMood? mood;
  final String whatWorked;
  final String whatDidnt;
  final bool isSubmitting;

  ReflectingState copyWith({
    SessionMood? mood,
    String? whatWorked,
    String? whatDidnt,
    bool? isSubmitting,
  }) =>
      ReflectingState(
        sessionId: sessionId,
        elapsedSeconds: elapsedSeconds,
        mood: mood ?? this.mood,
        whatWorked: whatWorked ?? this.whatWorked,
        whatDidnt: whatDidnt ?? this.whatDidnt,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props =>
      [sessionId, elapsedSeconds, mood, whatWorked, whatDidnt, isSubmitting];
}

// ── Saved ─────────────────────────────────────────────────────────────────────

class ReflectionSavedState extends LiveTrainingState {
  const ReflectionSavedState();
}

// ── Error ─────────────────────────────────────────────────────────────────────

class LiveTrainingError extends LiveTrainingState {
  const LiveTrainingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
