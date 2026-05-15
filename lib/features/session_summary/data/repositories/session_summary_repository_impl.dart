import 'dart:math';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_summary_entity.dart';
import '../../domain/repositories/session_summary_repository.dart';

class SessionSummaryRepositoryImpl implements SessionSummaryRepository {
  @override
  Future<SessionSummaryEntity> getSummary() async {
    final rawSummary = StorageService.getScoreSummary();
    if (rawSummary == null || rawSummary.isEmpty) {
      return SessionSummaryEntity.empty;
    }

    // ── Parse series ────────────────────────────────────────────────────────

    final seriesList = rawSummary.map((s) {
      final shots = (s['shots'] as List)
          .cast<String>()
          .map(_parseScore)
          .toList();
      final total = (s['total'] as num).toDouble();
      final number = (s['seriesNumber'] as num).toInt();
      return _SeriesData(number: number, shots: shots, total: total);
    }).toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    final allShots = seriesList.expand((s) => s.shots).toList();
    final totalShots = allShots.length;
    if (totalShots == 0) return SessionSummaryEntity.empty;

    final grandTotal = seriesList.fold(0.0, (sum, s) => sum + s.total);
    final maxPossible = totalShots * 10.0;
    final avg = grandTotal / totalShots;
    final efficiency = (grandTotal / maxPossible) * 100;

    final validShots = allShots.where((v) => v > 0).toList();
    final bestShot = validShots.isEmpty ? 0.0 : validShots.reduce(max);
    final worstShot = validShots.isEmpty ? 0.0 : validShots.reduce(min);

    final bestSeries =
        seriesList.reduce((a, b) => a.total > b.total ? a : b);
    final worstSeries =
        seriesList.reduce((a, b) => a.total < b.total ? a : b);

    final avgSeriesTotal = grandTotal / seriesList.length;
    final shotsPerSeries = seriesList.first.shots.length;
    final maxSeriesTotal = shotsPerSeries * 10.0;

    final breakdown = seriesList.map((s) => SeriesBreakdownEntity(
          seriesNumber: s.number,
          total: s.total,
          maxTotal: maxSeriesTotal,
          isBest: s.number == bestSeries.number,
        )).toList();

    final scorePoints = seriesList.map((s) => ScorePointEntity(
          index: s.number - 1,
          value: s.total,
          isSpike: s.total > avgSeriesTotal * 1.12,
        )).toList();

    // ── Session metadata ─────────────────────────────────────────────────────

    final setup = StorageService.getSessionSetup();
    final sessionTitle =
        setup != null ? _buildTitle(setup) : 'Session';

    final sessions = StorageService.getSessions();
    final completed =
        sessions.where((s) => s['status'] == 'completed').toList();
    final last = completed.isNotEmpty ? completed.last : null;
    final durationMins =
        last != null ? (last['durationMinutes'] as num?)?.toInt() ?? 0 : 0;

    // ── Mood ─────────────────────────────────────────────────────────────────

    MoodCorrelationEntity? mood;
    if (last != null) {
      final post = last['postSession'] as Map<String, dynamic>?;
      if (post != null) {
        final rating = (post['overallRating'] as num?)?.toInt() ?? 3;
        mood = _buildMood(rating, avg);
      }
    }

    return SessionSummaryEntity(
      sessionTitle: sessionTitle,
      totalShots: totalShots,
      duration: _formatDuration(durationMins),
      total: grandTotal,
      maxPossible: maxPossible,
      averagePerShot: avg,
      efficiency: efficiency,
      bestShot: bestShot,
      worstShot: worstShot,
      bestSeriesLabel: 'S${bestSeries.number}: ${_fmt(bestSeries.total)}',
      worstSeriesLabel: 'S${worstSeries.number}: ${_fmt(worstSeries.total)}',
      seriesBreakdown: breakdown,
      scorePoints: scorePoints,
      moodCorrelation: mood,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _parseScore(String display) {
    if (display == 'X') return 0.0;
    if (display == '<5') return 4.5;
    return double.tryParse(display) ?? 0.0;
  }

  static String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}' : '$m:00';
  }

  static String _buildTitle(Map<String, dynamic> setup) {
    final rangeType = setup['rangeType'] as String? ?? 'paper';
    final sessionType = setup['sessionType'] as String?;
    final rangeLabel = rangeType == 'electronic' ? 'Electronic' : 'Paper';
    final typeLabel = switch (sessionType) {
      'scoring' => ' Scoring',
      'grouping' => ' Grouping',
      'dryFire' => ' Dry Fire',
      _ => '',
    };
    return '$rangeLabel$typeLabel Session';
  }

  static MoodCorrelationEntity _buildMood(int rating, double avg) {
    final (label, state, emoji) = switch (rating) {
      5 => ('Felt Peak', 'Peak state', '🔥'),
      4 => ('Felt Great', 'High state', '😊'),
      3 => ('Felt Okay', 'Normal state', '😑'),
      2 => ('Felt Poor', 'Low state', '😕'),
      _ => ('Felt Trouble', 'Trouble state', '😤'),
    };
    return MoodCorrelationEntity(
      moodLabel: '$label ($rating/5)',
      moodState: state,
      moodEmoji: emoji,
      sessionAvg: avg,
      moodRating: rating,
    );
  }
}

class _SeriesData {
  _SeriesData({
    required this.number,
    required this.shots,
    required this.total,
  });

  final int number;
  final List<double> shots;
  final double total;
}
