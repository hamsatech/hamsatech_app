import 'package:equatable/equatable.dart';

abstract class RitualEvent extends Equatable {
  const RitualEvent();

  @override
  List<Object?> get props => [];
}

// ── Breathing ─────────────────────────────────────────────────────────────────

class RitualStartBreathing extends RitualEvent {
  const RitualStartBreathing();
}

class RitualBreathingTick extends RitualEvent {
  const RitualBreathingTick();
}

class RitualSkipBreathing extends RitualEvent {
  const RitualSkipBreathing();
}

// ── Body scan ─────────────────────────────────────────────────────────────────

class RitualBodyScanTick extends RitualEvent {
  const RitualBodyScanTick();
}

class RitualSkipBodyScan extends RitualEvent {
  const RitualSkipBodyScan();
}

// ── Intention ─────────────────────────────────────────────────────────────────

class RitualIntentionChanged extends RitualEvent {
  const RitualIntentionChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class RitualProceedToVisualization extends RitualEvent {
  const RitualProceedToVisualization();
}

// ── Visualization ─────────────────────────────────────────────────────────────

class RitualVisualizationChanged extends RitualEvent {
  const RitualVisualizationChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class RitualComplete extends RitualEvent {
  const RitualComplete();
}
