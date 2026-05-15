import 'package:equatable/equatable.dart';

enum MoodOption {
  trouble,
  poor,
  okay,
  good,
  great;

  String get label => switch (this) {
        MoodOption.trouble => 'Trouble',
        MoodOption.poor => 'Poor',
        MoodOption.okay => 'Okay',
        MoodOption.good => 'Good',
        MoodOption.great => 'Great',
      };

  String get emoji => switch (this) {
        MoodOption.trouble => '😤',
        MoodOption.poor => '😵',
        MoodOption.okay => '😑',
        MoodOption.good => '🙂',
        MoodOption.great => '😁',
      };
}

enum SleepOption {
  under5h,
  h5to6,
  h6to7,
  h7to8,
  over8h;

  String get label => switch (this) {
        SleepOption.under5h => '<5h',
        SleepOption.h5to6 => '5-6h',
        SleepOption.h6to7 => '6-7h',
        SleepOption.h7to8 => '7-8h',
        SleepOption.over8h => '8h+',
      };
}

enum EmotionTag {
  anxious,
  confident,
  focused,
  distracted,
  motivated,
  calm;

  String get label => switch (this) {
        EmotionTag.anxious => 'Anxious',
        EmotionTag.confident => 'Confident',
        EmotionTag.focused => 'Focused',
        EmotionTag.distracted => 'Distracted',
        EmotionTag.motivated => 'Motivated',
        EmotionTag.calm => 'Calm',
      };
}

class DailyCheckinEntity extends Equatable {
  const DailyCheckinEntity({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.sleep,
    required this.emotions,
  });

  final String id;
  final DateTime date;
  final MoodOption mood;
  final int energy; // 1–10
  final SleepOption sleep;
  final List<EmotionTag> emotions;

  @override
  List<Object?> get props => [id, date, mood, energy, sleep, emotions];
}
