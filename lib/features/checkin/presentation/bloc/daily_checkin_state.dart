import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_checkin_entity.dart';

abstract class DailyCheckinState extends Equatable {
  const DailyCheckinState();

  @override
  List<Object?> get props => [];
}

class DailyCheckinInitial extends DailyCheckinState {
  const DailyCheckinInitial();
}

class DailyCheckinEditing extends DailyCheckinState {
  const DailyCheckinEditing({
    this.mood,
    this.energy = 5,
    this.sleep,
    this.emotions = const [],
    this.polarSleepEstimate,
    this.isSubmitting = false,
  });

  final MoodOption? mood;
  final int energy;
  final SleepOption? sleep;
  final List<EmotionTag> emotions;
  final String? polarSleepEstimate;
  final bool isSubmitting;

  bool get canSubmit => mood != null && sleep != null && !isSubmitting;

  DailyCheckinEditing copyWith({
    MoodOption? mood,
    int? energy,
    SleepOption? sleep,
    List<EmotionTag>? emotions,
    String? polarSleepEstimate,
    bool? isSubmitting,
  }) =>
      DailyCheckinEditing(
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
        sleep: sleep ?? this.sleep,
        emotions: emotions ?? this.emotions,
        polarSleepEstimate: polarSleepEstimate ?? this.polarSleepEstimate,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props =>
      [mood, energy, sleep, emotions, polarSleepEstimate, isSubmitting];
}

class DailyCheckinSuccess extends DailyCheckinState {
  const DailyCheckinSuccess();
}

class DailyCheckinError extends DailyCheckinState {
  const DailyCheckinError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
