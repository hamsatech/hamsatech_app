import '../../../../core/services/storage_service.dart';
import '../../domain/entities/score_entry_config.dart';
import '../../domain/entities/session_series_entity.dart';
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
  Future<void> saveScores(List<SessionSeries> series) async {
    final data = series
        .map((s) => {
              'seriesNumber': s.seriesNumber,
              'shots': s.shots.map((v) => v.display).toList(),
              'total': s.total,
            })
        .toList();
    await StorageService.saveScoreSummary(data);
  }
}
