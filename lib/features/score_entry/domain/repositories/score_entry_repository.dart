import '../entities/score_entry_config.dart';
import '../entities/session_series_entity.dart';

abstract class ScoreEntryRepository {
  ScoreEntryConfig getConfig();
  Future<void> saveScores(List<SessionSeries> series);
}
