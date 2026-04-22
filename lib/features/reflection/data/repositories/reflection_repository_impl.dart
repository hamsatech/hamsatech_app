import 'package:uuid/uuid.dart';
import '../../domain/entities/journal_entry_entity.dart';
import '../../domain/repositories/reflection_repository.dart';
import '../models/journal_entry_model.dart';
import '../../../../core/services/storage_service.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  @override
  Future<JournalEntryEntity> addEntry(String content, String? emotion) async {
    final entry = JournalEntryModel(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      content: content,
      emotion: emotion,
    );
    final entries = _loadModels();
    entries.insert(0, entry);
    await _save(entries);
    return entry;
  }

  @override
  List<JournalEntryEntity> getEntries() => _loadModels();

  @override
  Future<void> deleteEntry(String id) async {
    final entries = _loadModels()..removeWhere((e) => e.id == id);
    await _save(entries);
  }

  List<JournalEntryModel> _loadModels() => StorageService.getJournalEntries()
      .map((j) => JournalEntryModel.fromJson(j))
      .toList();

  Future<void> _save(List<JournalEntryModel> entries) =>
      StorageService.saveJournalEntries(
          entries.map((e) => e.toJson()).toList());
}
