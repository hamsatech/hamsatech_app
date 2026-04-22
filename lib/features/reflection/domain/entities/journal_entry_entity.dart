import 'package:equatable/equatable.dart';

class JournalEntryEntity extends Equatable {
  const JournalEntryEntity({
    required this.id,
    required this.timestamp,
    required this.content,
    this.emotion,
  });

  final String id;
  final DateTime timestamp;
  final String content;
  final String? emotion;

  @override
  List<Object?> get props => [id, timestamp, content, emotion];
}

const kEmotions = [
  ('Confident', '💪'),
  ('Focused', '🎯'),
  ('Anxious', '😰'),
  ('Frustrated', '😤'),
  ('Calm', '😌'),
  ('Motivated', '🔥'),
  ('Tired', '😴'),
  ('Neutral', '😐'),
];
