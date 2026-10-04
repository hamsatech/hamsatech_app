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
    this.errorMessage,
  });

  final MoodOption? mood;
  final int energy;
  final SleepOption? sleep;
  final List<EmotionTag> emotions;
  final String? polarSleepEstimate;
  final bool isSubmitting;
  // Set only on a failed submit attempt; every other field is left exactly
  // as the athlete entered it, so a failure never loses their selections.
  // Cleared on the next field edit or submit attempt.
  final String? errorMessage;

  bool get canSubmit => mood != null && sleep != null && !isSubmitting;

  DailyCheckinEditing copyWith({
    MoodOption? mood,
    int? energy,
    SleepOption? sleep,
    List<EmotionTag>? emotions,
    String? polarSleepEstimate,
    bool? isSubmitting,
    // Deliberately no `?? this.errorMessage` fallback: every call site is
    // either a field edit or a fresh submit attempt, both of which must
    // clear a prior error, or the failed-submit handler itself setting a
    // new one — so "omitted" and "clear it" are the same thing here.
    String? errorMessage,
  }) =>
      DailyCheckinEditing(
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
        sleep: sleep ?? this.sleep,
        emotions: emotions ?? this.emotions,
        polarSleepEstimate: polarSleepEstimate ?? this.polarSleepEstimate,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        mood,
        energy,
        sleep,
        emotions,
        polarSleepEstimate,
        isSubmitting,
        errorMessage,
      ];
}

class DailyCheckinSuccess extends DailyCheckinState {
  const DailyCheckinSuccess();
}
