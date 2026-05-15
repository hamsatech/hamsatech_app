import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_checkin_entity.dart';

abstract class DailyCheckinEvent extends Equatable {
  const DailyCheckinEvent();

  @override
  List<Object?> get props => [];
}

class DailyCheckinLoadRequested extends DailyCheckinEvent {
  const DailyCheckinLoadRequested();
}

class DailyCheckinMoodChanged extends DailyCheckinEvent {
  const DailyCheckinMoodChanged(this.mood);

  final MoodOption mood;

  @override
  List<Object?> get props => [mood];
}

class DailyCheckinEnergyChanged extends DailyCheckinEvent {
  const DailyCheckinEnergyChanged(this.energy);

  final int energy;

  @override
  List<Object?> get props => [energy];
}

class DailyCheckinSleepChanged extends DailyCheckinEvent {
  const DailyCheckinSleepChanged(this.sleep);

  final SleepOption sleep;

  @override
  List<Object?> get props => [sleep];
}

class DailyCheckinEmotionToggled extends DailyCheckinEvent {
  const DailyCheckinEmotionToggled(this.emotion);

  final EmotionTag emotion;

  @override
  List<Object?> get props => [emotion];
}

class DailyCheckinSubmitRequested extends DailyCheckinEvent {
  const DailyCheckinSubmitRequested();
}
