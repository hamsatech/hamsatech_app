import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/models/ritual_result.dart';
import '../domain/repositories/ritual_repository.dart';
import 'ritual_event.dart';
import 'ritual_state.dart';

class RitualBloc extends Bloc<RitualEvent, RitualState> {
  RitualBloc(this._repository) : super(const RitualInitial()) {
    on<RitualStartBreathing>(_onStartBreathing);
    on<RitualBreathingTick>(_onBreathingTick);
    on<RitualSkipBreathing>(_onSkipBreathing);
    on<RitualBodyScanTick>(_onBodyScanTick);
    on<RitualSkipBodyScan>(_onSkipBodyScan);
    on<RitualIntentionChanged>(_onIntentionChanged);
    on<RitualProceedToVisualization>(_onProceedToVisualization);
    on<RitualVisualizationChanged>(_onVisualizationChanged);
    on<RitualComplete>(_onComplete);
  }

  final RitualRepository _repository;
  StreamSubscription<int>? _breathingTimer;
  StreamSubscription<int>? _bodyScanTimer;

  // ── Breathing ───────────────────────────────────────────────────────────────

  void _onStartBreathing(
      RitualStartBreathing event, Emitter<RitualState> emit) {
    _cancelAllTimers();
    final config = _repository.getConfig();
    final p = config.breathPhaseSeconds;
    final instruction = '${p}s in · ${p}s hold · ${p}s out';
    emit(RitualBreathingState(
      phase: BreathingPhase.breatheIn,
      secondsRemaining: config.breathingDurationSeconds,
      phaseSecondsRemaining: config.breathPhaseSeconds,
      phaseSeconds: config.breathPhaseSeconds,
      breathInstruction: instruction,
    ));
    _breathingTimer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .listen((_) => add(const RitualBreathingTick()));
  }

  void _onBreathingTick(RitualBreathingTick event, Emitter<RitualState> emit) {
    if (state is! RitualBreathingState) return;
    final s = state as RitualBreathingState;

    if (s.secondsRemaining <= 1) {
      _cancelBreathingTimer();
      _beginBodyScan(emit);
      return;
    }

    final newPhaseRemaining = s.phaseSecondsRemaining - 1;
    if (newPhaseRemaining <= 0) {
      emit(s.copyWith(
        secondsRemaining: s.secondsRemaining - 1,
        phase: _nextBreathPhase(s.phase),
        phaseSecondsRemaining: s.phaseSeconds,
      ));
    } else {
      emit(s.copyWith(
        secondsRemaining: s.secondsRemaining - 1,
        phaseSecondsRemaining: newPhaseRemaining,
      ));
    }
  }

  void _onSkipBreathing(RitualSkipBreathing event, Emitter<RitualState> emit) {
    _cancelBreathingTimer();
    _beginBodyScan(emit);
  }

  BreathingPhase _nextBreathPhase(BreathingPhase p) => switch (p) {
        BreathingPhase.breatheIn => BreathingPhase.hold,
        BreathingPhase.hold => BreathingPhase.breatheOut,
        BreathingPhase.breatheOut => BreathingPhase.breatheIn,
      };

  // ── Body scan ───────────────────────────────────────────────────────────────

  void _beginBodyScan(Emitter<RitualState> emit) {
    final config = _repository.getConfig();
    emit(RitualBodyScanState(
      areaIndex: 0,
      areas: config.bodyScanAreas,
      areaSecondsRemaining: config.bodyScanAreaDurationSeconds,
      areaDurationSeconds: config.bodyScanAreaDurationSeconds,
    ));
    _bodyScanTimer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .listen((_) => add(const RitualBodyScanTick()));
  }

  void _onBodyScanTick(RitualBodyScanTick event, Emitter<RitualState> emit) {
    if (state is! RitualBodyScanState) return;
    final s = state as RitualBodyScanState;

    if (s.areaSecondsRemaining <= 1) {
      if (s.areaIndex >= s.areas.length - 1) {
        _cancelBodyScanTimer();
        emit(const RitualIntentionState());
      } else {
        emit(s.copyWith(
          areaIndex: s.areaIndex + 1,
          areaSecondsRemaining: s.areaDurationSeconds,
        ));
      }
    } else {
      emit(s.copyWith(areaSecondsRemaining: s.areaSecondsRemaining - 1));
    }
  }

  void _onSkipBodyScan(RitualSkipBodyScan event, Emitter<RitualState> emit) {
    _cancelBodyScanTimer();
    emit(const RitualIntentionState());
  }

  // ── Intention ───────────────────────────────────────────────────────────────

  void _onIntentionChanged(
    RitualIntentionChanged event,
    Emitter<RitualState> emit,
  ) {
    if (state is RitualIntentionState) {
      emit((state as RitualIntentionState).copyWith(intention: event.text));
    }
  }

  void _onProceedToVisualization(
    RitualProceedToVisualization event,
    Emitter<RitualState> emit,
  ) {
    final intention = state is RitualIntentionState
        ? (state as RitualIntentionState).intention
        : '';
    emit(RitualVisualizationState(intention: intention));
  }

  // ── Visualization ────────────────────────────────────────────────────────────

  void _onVisualizationChanged(
    RitualVisualizationChanged event,
    Emitter<RitualState> emit,
  ) {
    if (state is RitualVisualizationState) {
      emit(
        (state as RitualVisualizationState).copyWith(visualization: event.text),
      );
    }
  }

  Future<void> _onComplete(
    RitualComplete event,
    Emitter<RitualState> emit,
  ) async {
    if (state is! RitualVisualizationState) return;
    final s = state as RitualVisualizationState;
    await _repository.saveResult(RitualResult(
      intention: s.intention,
      visualization: s.visualization,
      completedAt: DateTime.now(),
    ));
    emit(RitualCompleteState(
      intention: s.intention,
      visualization: s.visualization,
    ));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _cancelBreathingTimer() {
    _breathingTimer?.cancel();
    _breathingTimer = null;
  }

  void _cancelBodyScanTimer() {
    _bodyScanTimer?.cancel();
    _bodyScanTimer = null;
  }

  void _cancelAllTimers() {
    _cancelBreathingTimer();
    _cancelBodyScanTimer();
  }

  @override
  Future<void> close() {
    _cancelAllTimers();
    return super.close();
  }
}
