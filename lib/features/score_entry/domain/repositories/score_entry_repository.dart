import '../entities/score_entry_config.dart';

abstract class ScoreEntryRepository {
  ScoreEntryConfig getConfig();

  /// Saves one total score per series. Downstream analytics receive synthetic
  /// per-shot averages so existing report screens remain accurate.
  Future<void> saveTotals(List<double> totals, int shotsPerSeries);
}
