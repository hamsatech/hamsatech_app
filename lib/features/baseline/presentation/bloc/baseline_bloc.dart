import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'baseline_event.dart';
import 'baseline_state.dart';

class BaselineBloc extends Bloc<BaselineEvent, BaselineState> {
  Timer? _timer;
  final _random = Random();

  static const int _totalSeconds = 60;

  BaselineBloc() : super(const BaselineState()) {
    on<OnStartPressed>(_onStartPressed);
    on<OnTick>(_onTick);
    on<OnCaptureCompleted>(_onCaptureCompleted);
    on<OnContinuePressed>(_onContinuePressed);
  }

  // ── Phase 1 → Phase 2 ────────────────────────────────────────────────────

  void _onStartPressed(
    OnStartPressed event,
    Emitter<BaselineState> emit,
  ) {
    if (state.status == BaselineStatus.capturing) return;

    _timer?.cancel();

    emit(state.copyWith(
      status: BaselineStatus.capturing,
      bpm: _simulateBpm(),
      remainingSeconds: _totalSeconds,
      progress: 0.0,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const OnTick());
    });
  }

  // ── Phase 2: each tick ───────────────────────────────────────────────────

  void _onTick(
    OnTick event,
    Emitter<BaselineState> emit,
  ) {
    final remaining = state.remainingSeconds - 1;

    if (remaining <= 0) {
      // Stop timer and lock the final BPM reading before transitioning
      _timer?.cancel();
      _timer = null;
      emit(state.copyWith(
        remainingSeconds: 0,
        progress: 1.0,
        bpm: _simulateBpm(),
      ));
      add(const OnCaptureCompleted());
      return;
    }

    emit(state.copyWith(
      remainingSeconds: remaining,
      progress: (_totalSeconds - remaining) / _totalSeconds,
      bpm: _simulateBpm(),
    ));
  }

  // ── Phase 2 → Phase 3 ────────────────────────────────────────────────────

  void _onCaptureCompleted(
    OnCaptureCompleted event,
    Emitter<BaselineState> emit,
  ) {
    emit(state.copyWith(status: BaselineStatus.success));
  }

  // ── Phase 3: continue pressed ─────────────────────────────────────────────

  void _onContinuePressed(
    OnContinuePressed event,
    Emitter<BaselineState> emit,
  ) {
    // Signal the view's BlocConsumer listener to navigate
    emit(state.copyWith(navigateToNext: true));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _simulateBpm() => 70 + _random.nextInt(21);

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
