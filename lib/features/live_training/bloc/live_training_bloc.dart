import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/live_training_repository.dart';
import 'live_training_event.dart';
import 'live_training_state.dart';

class LiveTrainingBloc extends Bloc<LiveTrainingEvent, LiveTrainingState> {
  LiveTrainingBloc(this._repository) : super(const LiveTrainingInitial()) {
    on<LiveTrainingStartRequested>(_onStartRequested);
    on<LiveTrainingTick>(_onTick);
    on<LiveTrainingPauseToggled>(_onPauseToggled);
    on<LiveTrainingSeriesCompleted>(_onSeriesCompleted);
    on<LiveTrainingEndRequested>(_onEndRequested);
    on<ReflectMoodChanged>(_onMoodChanged);
    on<ReflectWhatWorkedChanged>(_onWhatWorkedChanged);
    on<ReflectWhatDidntChanged>(_onWhatDidntChanged);
    on<ReflectVoiceNoteRequested>(_onVoiceNoteRequested);
    on<ReflectSaveRequested>(_onSaveRequested);
  }

  final LiveTrainingRepository _repository;
  StreamSubscription<int>? _timer;
  final _random = Random();

  // ── Start ─────────────────────────────────────────────────────────────────

  Future<void> _onStartRequested(
    LiveTrainingStartRequested event,
    Emitter<LiveTrainingState> emit,
  ) async {
    _cancelTimer();
    final config = _repository.getConfig();
    final sessionId = await _repository.startSession(config.sessionTitle);
    final totalSeries = (config.plannedShots / config.shotsPerSeries).ceil();

    emit(LiveSessionActiveState(
      sessionId: sessionId,
      sessionTitle: config.sessionTitle,
      elapsedSeconds: 0,
      isPaused: false,
      currentSeriesIndex: 0,
      totalSeries: totalSeries.clamp(1, 99),
      shotsPerSeries: config.shotsPerSeries,
      baselineHr: config.baselineHr,
    ));
    _startTimer();
  }

  void _startTimer() {
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .listen((_) => add(const LiveTrainingTick()));
  }

  // ── Tick ──────────────────────────────────────────────────────────────────

  void _onTick(LiveTrainingTick event, Emitter<LiveTrainingState> emit) {
    if (state is! LiveSessionActiveState) return;
    final s = state as LiveSessionActiveState;
    if (s.isPaused) return;

    // Simulated HR: random walk ±2 bpm per second, clamped to a realistic range.
    final prev = s.simulatedHr ?? s.baselineHr;
    final delta = _random.nextInt(5) - 2; // -2..+2
    final newHr = (prev + delta).clamp(s.baselineHr - 10, s.baselineHr + 25);
    final raw = [...s.simulatedHrHistory, newHr];
    final newHistory = raw.length > 30 ? raw.sublist(raw.length - 30) : raw;

    emit(s.copyWith(
      elapsedSeconds: s.elapsedSeconds + 1,
      simulatedHr: newHr,
      simulatedHrHistory: newHistory,
    ));
  }

  // ── Pause / resume ────────────────────────────────────────────────────────

  void _onPauseToggled(
    LiveTrainingPauseToggled event,
    Emitter<LiveTrainingState> emit,
  ) {
    if (state is! LiveSessionActiveState) return;
    final s = state as LiveSessionActiveState;
    emit(s.copyWith(isPaused: !s.isPaused));
  }

  // ── Series completion ─────────────────────────────────────────────────────

  Future<void> _onSeriesCompleted(
    LiveTrainingSeriesCompleted event,
    Emitter<LiveTrainingState> emit,
  ) async {
    if (state is! LiveSessionActiveState) return;
    final s = state as LiveSessionActiveState;
    final nextIndex = s.currentSeriesIndex + 1;
    if (nextIndex >= s.totalSeries) {
      _repository.stopHrTelemetry();
      await _repository.flushHrTelemetry();
      _cancelTimer();
      emit(ReflectingState(
        sessionId: s.sessionId,
        elapsedSeconds: s.elapsedSeconds,
      ));
    } else {
      emit(s.copyWith(currentSeriesIndex: nextIndex));
    }
  }

  // ── End session ───────────────────────────────────────────────────────────

  Future<void> _onEndRequested(
    LiveTrainingEndRequested event,
    Emitter<LiveTrainingState> emit,
  ) async {
    if (state is! LiveSessionActiveState) return;
    final s = state as LiveSessionActiveState;
    _repository.stopHrTelemetry();
    await _repository.flushHrTelemetry();
    _cancelTimer();
    emit(ReflectingState(
      sessionId: s.sessionId,
      elapsedSeconds: s.elapsedSeconds,
    ));
  }

  // ── Reflect ───────────────────────────────────────────────────────────────

  void _onMoodChanged(
    ReflectMoodChanged event,
    Emitter<LiveTrainingState> emit,
  ) {
    if (state is ReflectingState) {
      emit((state as ReflectingState).copyWith(mood: event.mood));
    }
  }

  void _onWhatWorkedChanged(
    ReflectWhatWorkedChanged event,
    Emitter<LiveTrainingState> emit,
  ) {
    if (state is ReflectingState) {
      emit((state as ReflectingState).copyWith(whatWorked: event.text));
    }
  }

  void _onWhatDidntChanged(
    ReflectWhatDidntChanged event,
    Emitter<LiveTrainingState> emit,
  ) {
    if (state is ReflectingState) {
      emit((state as ReflectingState).copyWith(whatDidnt: event.text));
    }
  }

  void _onVoiceNoteRequested(
    ReflectVoiceNoteRequested event,
    Emitter<LiveTrainingState> emit,
  ) {
    // Voice recording is a future capability — no-op placeholder.
  }

  Future<void> _onSaveRequested(
    ReflectSaveRequested event,
    Emitter<LiveTrainingState> emit,
  ) async {
    if (state is! ReflectingState) return;
    final s = state as ReflectingState;
    emit(s.copyWith(isSubmitting: true));
    try {
      await _repository.completeSession(
        sessionId: s.sessionId,
        durationMinutes: (s.elapsedSeconds / 60).ceil(),
        mood: s.mood,
        whatWorked: s.whatWorked,
        whatDidnt: s.whatDidnt,
      );
      emit(const ReflectionSavedState());
    } catch (_) {
      emit(s.copyWith(isSubmitting: false));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
