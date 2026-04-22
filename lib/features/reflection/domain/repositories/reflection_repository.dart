import '../entities/journal_entry_entity.dart';

abstract class ReflectionRepository {
  Future<JournalEntryEntity> addEntry(String content, String? emotion);
  List<JournalEntryEntity> getEntries();
  Future<void> deleteEntry(String id);
}
