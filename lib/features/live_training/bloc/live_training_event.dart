import 'package:equatable/equatable.dart';

import '../domain/entities/session_mood.dart';

abstract class LiveTrainingEvent extends Equatable {
  const LiveTrainingEvent();

  @override
  List<Object?> get props => [];
}

// ── Session lifecycle ──────────────────────────────────────────────────────────

class LiveTrainingStartRequested extends LiveTrainingEvent {
  const LiveTrainingStartRequested();
}

class LiveTrainingTick extends LiveTrainingEvent {
  const LiveTrainingTick();
}

class LiveTrainingPauseToggled extends LiveTrainingEvent {
  const LiveTrainingPauseToggled();
}

class LiveTrainingSeriesCompleted extends LiveTrainingEvent {
  const LiveTrainingSeriesCompleted();
}

class LiveTrainingEndRequested extends LiveTrainingEvent {
  const LiveTrainingEndRequested();
}

// ── Reflection ────────────────────────────────────────────────────────────────

class ReflectMoodChanged extends LiveTrainingEvent {
  const ReflectMoodChanged(this.mood);

  final SessionMood mood;

  @override
  List<Object?> get props => [mood];
}

class ReflectWhatWorkedChanged extends LiveTrainingEvent {
  const ReflectWhatWorkedChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class ReflectWhatDidntChanged extends LiveTrainingEvent {
  const ReflectWhatDidntChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class ReflectVoiceNoteRequested extends LiveTrainingEvent {
  const ReflectVoiceNoteRequested();
}

class ReflectSaveRequested extends LiveTrainingEvent {
  const ReflectSaveRequested();
}
