import 'package:equatable/equatable.dart';

enum BreathingPhase { breatheIn, hold, breatheOut }

extension BreathingPhaseLabel on BreathingPhase {
  String get label => switch (this) {
        BreathingPhase.breatheIn => 'Breathe in',
        BreathingPhase.hold => 'Hold',
        BreathingPhase.breatheOut => 'Breathe out',
      };
}

abstract class RitualState extends Equatable {
  const RitualState();

  @override
  List<Object?> get props => [];
}

class RitualInitial extends RitualState {
  const RitualInitial();
}

// ── Breathing ─────────────────────────────────────────────────────────────────

class RitualBreathingState extends RitualState {
  const RitualBreathingState({
    required this.phase,
    required this.secondsRemaining,
    required this.phaseSecondsRemaining,
    required this.phaseSeconds,
    required this.breathInstruction,
  });

  final BreathingPhase phase;
  final int secondsRemaining;
  final int phaseSecondsRemaining;
  final int phaseSeconds;
  final String breathInstruction; // "4 sec in · 4 sec hold · 4 sec out"

  String get formattedRemaining {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')} remaining';
  }

  RitualBreathingState copyWith({
    BreathingPhase? phase,
    int? secondsRemaining,
    int? phaseSecondsRemaining,
  }) =>
      RitualBreathingState(
        phase: phase ?? this.phase,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        phaseSecondsRemaining:
            phaseSecondsRemaining ?? this.phaseSecondsRemaining,
        phaseSeconds: phaseSeconds,
        breathInstruction: breathInstruction,
      );

  @override
  List<Object?> get props =>
      [phase, secondsRemaining, phaseSecondsRemaining, phaseSeconds];
}

// ── Body scan ─────────────────────────────────────────────────────────────────

class RitualBodyScanState extends RitualState {
  const RitualBodyScanState({
    required this.areaIndex,
    required this.areas,
    required this.areaSecondsRemaining,
    required this.areaDurationSeconds,
  });

  final int areaIndex;
  final List<String> areas;
  final int areaSecondsRemaining;
  final int areaDurationSeconds;

  String get currentArea => areas[areaIndex];
  int get totalAreas => areas.length;

  String get formattedRemaining {
    final m = areaSecondsRemaining ~/ 60;
    final s = areaSecondsRemaining % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')} remaining';
  }

  RitualBodyScanState copyWith({
    int? areaIndex,
    int? areaSecondsRemaining,
  }) =>
      RitualBodyScanState(
        areaIndex: areaIndex ?? this.areaIndex,
        areas: areas,
        areaSecondsRemaining: areaSecondsRemaining ?? this.areaSecondsRemaining,
        areaDurationSeconds: areaDurationSeconds,
      );

  @override
  List<Object?> get props =>
      [areaIndex, areas, areaSecondsRemaining, areaDurationSeconds];
}

// ── Intention ─────────────────────────────────────────────────────────────────

class RitualIntentionState extends RitualState {
  const RitualIntentionState({this.intention = ''});

  final String intention;

  RitualIntentionState copyWith({String? intention}) =>
      RitualIntentionState(intention: intention ?? this.intention);

  @override
  List<Object?> get props => [intention];
}

// ── Visualization ─────────────────────────────────────────────────────────────

class RitualVisualizationState extends RitualState {
  const RitualVisualizationState({
    required this.intention,
    this.visualization = '',
  });

  final String intention;
  final String visualization;

  RitualVisualizationState copyWith({String? visualization}) =>
      RitualVisualizationState(
        intention: intention,
        visualization: visualization ?? this.visualization,
      );

  @override
  List<Object?> get props => [intention, visualization];
}

// ── Complete ──────────────────────────────────────────────────────────────────

class RitualCompleteState extends RitualState {
  const RitualCompleteState({
    required this.intention,
    required this.visualization,
  });

  final String intention;
  final String visualization;

  @override
  List<Object?> get props => [intention, visualization];
}
