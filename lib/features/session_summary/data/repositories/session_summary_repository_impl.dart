import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/services/storage_service.dart';
import '../../../session_report/data/models/session_report_model.dart';
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
      final shots =
          (s['shots'] as List).cast<String>().map(_parseScore).toList();
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

    final bestSeries = seriesList.reduce((a, b) => a.total > b.total ? a : b);
    final worstSeries = seriesList.reduce((a, b) => a.total < b.total ? a : b);

    final avgSeriesTotal = grandTotal / seriesList.length;
    final shotsPerSeries = seriesList.first.shots.length;
    final maxSeriesTotal = shotsPerSeries * 10.0;

    final breakdown = seriesList
        .map((s) => SeriesBreakdownEntity(
              seriesNumber: s.number,
              total: s.total,
              maxTotal: maxSeriesTotal,
              isBest: s.number == bestSeries.number,
            ))
        .toList();

    final scorePoints = seriesList
        .map((s) => ScorePointEntity(
              index: s.number - 1,
              value: s.total,
              isSpike: s.total > avgSeriesTotal * 1.12,
            ))
        .toList();

    // ── Session metadata ─────────────────────────────────────────────────────

    final setup = StorageService.getSessionSetup();
    final sessionTitle = setup != null ? _buildTitle(setup) : 'Session';

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

    // ── Augment with real, persisted backend data (non-blocking) ─────────────
    // `bestShot`/`worstShot` are deliberately never touched here — the
    // backend only ever stores per-series totals, never individual shot
    // values, so there is no real data to replace them with.
    var finalTotal = grandTotal;
    var finalDurationMins = durationMins;
    var finalTitle = sessionTitle;
    var finalTotalShots = totalShots;
    var finalBestSeriesLabel =
        'S${bestSeries.number}: ${_fmt(bestSeries.total)}';
    var finalWorstSeriesLabel =
        'S${worstSeries.number}: ${_fmt(worstSeries.total)}';
    var finalBreakdown = breakdown;
    var finalScorePoints = scorePoints;
    var finalMood = mood;
    double? backendAvgScore;

    final report = await _fetchSessionReport();
    if (report != null) {
      final scores = report.scores;
      if (scores != null) {
        if (scores.totalScore != null) finalTotal = scores.totalScore!;
        if (scores.totalShots != null) finalTotalShots = scores.totalShots!;
        backendAvgScore = scores.averageScore ?? scores.avgScore;
      }

      final durationSeconds = report.summary.durationSeconds;
      if (durationSeconds != null) {
        finalDurationMins = (durationSeconds / 60).round();
      }

      // Only backend `session_type` is real here — `rangeType` (Electronic
      // vs Paper) is a local-only setup choice never sent to the backend,
      // so the locally-built title is kept whenever local setup exists.
      if (setup == null && report.summary.sessionType != null) {
        finalTitle = _buildTitle({'sessionType': report.summary.sessionType});
      }

      if (report.series.isNotEmpty) {
        final backendSeries = [...report.series]
          ..sort((a, b) => a.seriesNumber.compareTo(b.seriesNumber));
        final bestBackend = backendSeries.reduce(
            (a, b) => (a.totalScore ?? 0) > (b.totalScore ?? 0) ? a : b);
        final worstBackend = backendSeries.reduce(
            (a, b) => (a.totalScore ?? 0) < (b.totalScore ?? 0) ? a : b);
        finalBestSeriesLabel =
            'S${bestBackend.seriesNumber}: ${_fmt(bestBackend.totalScore ?? 0)}';
        finalWorstSeriesLabel =
            'S${worstBackend.seriesNumber}: ${_fmt(worstBackend.totalScore ?? 0)}';

        final avgBackendSeriesTotal =
            backendSeries.fold(0.0, (sum, s) => sum + (s.totalScore ?? 0)) /
                backendSeries.length;
        finalBreakdown = backendSeries
            .map((s) => SeriesBreakdownEntity(
                  seriesNumber: s.seriesNumber,
                  total: s.totalScore ?? 0,
                  maxTotal: (s.shotsFired ?? shotsPerSeries) * 10.0,
                  isBest: s.seriesNumber == bestBackend.seriesNumber,
                ))
            .toList();
        finalScorePoints = backendSeries
            .map((s) => ScorePointEntity(
                  index: s.seriesNumber - 1,
                  value: s.totalScore ?? 0,
                  isSpike: (s.totalScore ?? 0) > avgBackendSeriesTotal * 1.12,
                ))
            .toList();
      }

      final reflectionMood = report.reflection?.mood;
      if (reflectionMood != null) {
        finalMood = _buildMood(reflectionMood, backendAvgScore ?? avg);
      }

      debugPrint('[SESSION SUMMARY] augmented from /report');
    }

    final finalAveragePerShot = backendAvgScore ??
        (finalTotalShots > 0 ? finalTotal / finalTotalShots : avg);
    final finalMaxPossible = finalTotalShots > 0
        ? finalTotalShots * 10.0
        : (maxPossible > 0 ? maxPossible : finalTotal);
    final finalEfficiency = finalMaxPossible > 0
        ? (finalTotal / finalMaxPossible) * 100
        : efficiency;

    return SessionSummaryEntity(
      sessionTitle: finalTitle,
      totalShots: finalTotalShots,
      duration: _formatDuration(finalDurationMins),
      total: finalTotal,
      maxPossible: finalMaxPossible,
      averagePerShot: finalAveragePerShot,
      efficiency: finalEfficiency,
      bestShot: bestShot,
      worstShot: worstShot,
      bestSeriesLabel: finalBestSeriesLabel,
      worstSeriesLabel: finalWorstSeriesLabel,
      seriesBreakdown: finalBreakdown,
      scorePoints: finalScorePoints,
      moodCorrelation: finalMood,
    );
  }

  // ── Real session report fetch ───────────────────────────────────────────

  /// Fetches the real, persisted session report from the backend
  /// (`GET .../sessions/{sessionId}/report`). Returns `null` on any
  /// failure or when no session/athlete id is available — callers must
  /// treat `null` as "no backend data available" and keep their
  /// locally-computed values.
  static Future<SessionReportModel?> _fetchSessionReport() async {
    final sessionId = SessionMemory.sessionId ?? StorageService.getSessionId();
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (sessionId == null || athleteId == null) return null;

    try {
      final res = await ApiService.instance.getSessionReport(
        athleteId: athleteId,
        sessionId: sessionId,
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      return SessionReportModel.fromJson(data);
    } catch (e) {
      debugPrint('[SESSION SUMMARY] /report fetch failed (non-fatal): $e');
      return null;
    }
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
