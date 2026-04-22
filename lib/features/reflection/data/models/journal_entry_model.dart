import '../../domain/entities/journal_entry_entity.dart';

class JournalEntryModel extends JournalEntryEntity {
  const JournalEntryModel({
    required super.id,
    required super.timestamp,
    required super.content,
    super.emotion,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) =>
      JournalEntryModel(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        content: json['content'] as String,
        emotion: json['emotion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'content': content,
        'emotion': emotion,
      };
}
