import '../../../../core/services/storage_service.dart';
import '../../domain/entities/score_entry_config.dart';
import '../../domain/repositories/score_entry_repository.dart';

class ScoreEntryRepositoryImpl implements ScoreEntryRepository {
  static const _defaultShotsPerSeries = 10;

  @override
  ScoreEntryConfig getConfig() {
    final setup = StorageService.getSessionSetup();
    String title = 'Paper Session';
    int totalSeries = 6;

    if (setup != null) {
      final rangeTypeStr = setup['rangeType'] as String? ?? 'paper';
      final rangeLabel =
          rangeTypeStr == 'electronic' ? 'Electronic' : 'Paper';
      final sessionTypeStr = setup['sessionType'] as String?;
      final typeLabel = switch (sessionTypeStr) {
        'scoring' => ' Scoring',
        'grouping' => ' Grouping',
        'dryFire' => ' Dry Fire',
        _ => '',
      };
      title = '$rangeLabel$typeLabel Session';

      final plannedShots =
          (setup['plannedShots'] as num?)?.toInt() ?? 60;
      totalSeries = (plannedShots / _defaultShotsPerSeries).ceil();
    }

    return ScoreEntryConfig(
      sessionTitle: title,
      totalSeries: totalSeries.clamp(1, 99),
      shotsPerSeries: _defaultShotsPerSeries,
    );
  }

  @override
  Future<void> saveTotals(List<double> totals, int shotsPerSeries) async {
    // Represent each series as synthetic per-shot averages so downstream
    // analytics (variance, avg-per-shot, HR charts) remain meaningful.
    final data = totals.asMap().entries.map((e) {
      final avgShot =
          shotsPerSeries > 0 ? e.value / shotsPerSeries : 0.0;
      final avgStr = avgShot.toStringAsFixed(2);
      return {
        'seriesNumber': e.key + 1,
        'shots': List<String>.filled(shotsPerSeries, avgStr),
        'total': e.value,
      };
    }).toList();

    await StorageService.saveScoreSummary(data);
  }
}
