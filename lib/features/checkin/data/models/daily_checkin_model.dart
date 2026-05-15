import '../../domain/entities/daily_checkin_entity.dart';

class DailyCheckinModel extends DailyCheckinEntity {
  const DailyCheckinModel({
    required super.id,
    required super.date,
    required super.mood,
    required super.energy,
    required super.sleep,
    required super.emotions,
  });

  factory DailyCheckinModel.fromJson(Map<String, dynamic> json) {
    return DailyCheckinModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodOption.values.firstWhere((e) => e.name == json['mood']),
      energy: json['energy'] as int,
      sleep: SleepOption.values.firstWhere((e) => e.name == json['sleep']),
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => EmotionTag.values.firstWhere((t) => t.name == e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood.name,
        'energy': energy,
        'sleep': sleep.name,
        'emotions': emotions.map((e) => e.name).toList(),
      };
}
