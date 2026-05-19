import 'dart:math';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_report_entity.dart';
import '../../domain/repositories/session_report_repository.dart';

class SessionReportRepositoryImpl implements SessionReportRepository {
  static const _spikeThreshold = 84;

  @override
  Future<SessionReportEntity> getReport() async {
    final rawSummary = StorageService.getScoreSummary();
    if (rawSummary == null || rawSummary.isEmpty) {
      return SessionReportEntity.empty;
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
    if (allShots.isEmpty) return SessionReportEntity.empty;

    final grandTotal = seriesList.fold(0.0, (sum, s) => sum + s.total);
    final shotsPerSeries = seriesList.first.shots.length;
    final maxSeriesTotal = shotsPerSeries * 10.0;
    final isPolarConnected = StorageService.isPolarEnabled();

    final bestSeries = seriesList.reduce((a, b) => a.total > b.total ? a : b);

    // ── Session metadata ─────────────────────────────────────────────────────

    final setup = StorageService.getSessionSetup();
    final sessionTitle = setup != null ? _buildTitle(setup) : 'Session Report';

    final sessions = StorageService.getSessions();
    final completed =
        sessions.where((s) => s['status'] == 'completed').toList();
    final last = completed.isNotEmpty ? completed.last : null;

    final now = DateTime.now();
    final dateLabel = _formatDate(now);
    final timeLabel = _formatTime(now);

    // ── Physiology ────────────────────────────────────────────────────────────

    final avgScore = grandTotal / allShots.length;
    final variance = allShots
            .map((v) => (v - avgScore) * (v - avgScore))
            .reduce((a, b) => a + b) /
        allShots.length;
    final generatedAvgHr = 60 + (avgScore * 2.5).round();
    final generatedPeakHr =
        generatedAvgHr + 15 + (variance * 0.5).round().clamp(0, 20);
    final avgHr = isPolarConnected ? generatedAvgHr : 0;
    final peakHr = isPolarConnected ? generatedPeakHr : 0;

    final (fatigueLabel, fatigueColor) = _fatigueLevel(variance);
    final (recoveryLabel, recoveryColor) = _recoveryLevel(last, avgScore);

    final physiology = PhysiologyMetricsEntity(
      avgHr: avgHr,
      peakHr: peakHr,
      fatigueLabel: fatigueLabel,
      fatigueColor: fatigueColor,
      recoveryLabel: recoveryLabel,
      recoveryColor: recoveryColor,
    );

    // ── Series rows ───────────────────────────────────────────────────────────

    final rng = Random(42);
    final seriesHrMap = <int, int>{};
    final seriesRows = seriesList.map((s) {
      final seriesHr = isPolarConnected
          ? (generatedAvgHr + rng.nextInt(10) - 5).clamp(50, 130)
          : 0;
      seriesHrMap[s.number] = seriesHr;
      return ReportSeriesRowEntity(
        seriesNumber: s.number,
        total: s.total,
        maxTotal: maxSeriesTotal,
        avgHr: seriesHr,
        isBest: s.number == bestSeries.number,
      );
    }).toList();

    // ── HR chart (simulated with spike + boundary markers) ────────────────────

    final totalPoints = seriesList.length * shotsPerSeries;
    int spikeCount = 0;
    final hrPoints = isPolarConnected
        ? List.generate(totalPoints, (i) {
            final seriesIdx = i ~/ shotsPerSeries;
            final shotInSeries = i % shotsPerSeries;
            final seriesHr =
                seriesHrMap[seriesList[seriesIdx].number] ?? generatedAvgHr;
            final noise = (rng.nextDouble() - 0.5) * 14;
            final bpm = (seriesHr + noise).clamp(50.0, 145.0);
            final isSpike = bpm > _spikeThreshold;
            if (isSpike) spikeCount++;
            return HrChartPoint(
              index: i,
              bpm: bpm,
              isSpike: isSpike,
              isSeriesBoundary: shotInSeries == shotsPerSeries - 1 &&
                  seriesIdx < seriesList.length - 1,
            );
          })
        : <HrChartPoint>[];

    final hrMin =
        isPolarConnected ? hrPoints.map((p) => p.bpm).reduce(min).round() : 0;
    final hrPeak =
        isPolarConnected ? hrPoints.map((p) => p.bpm).reduce(max).round() : 0;
    final hrAvg = isPolarConnected
        ? (hrPoints.map((p) => p.bpm).reduce((a, b) => a + b) / hrPoints.length)
            .round()
        : 0;
    final avgPreShotHr =
        isPolarConnected ? (generatedAvgHr - 3).clamp(50, 130) : 0;

    final hrMetrics = HrMetricsEntity(
      avgHr: hrAvg,
      peakHr: hrPeak,
      minHr: hrMin,
      hrZoneLabel: _hrZoneLabel(hrAvg),
      hrZoneColor: _hrZoneColor(hrAvg),
      avgPreShotHr: avgPreShotHr,
      spikeCount: spikeCount,
      spikeThreshold: _spikeThreshold,
    );

    // ── Mental state ──────────────────────────────────────────────────────────

    final checkin = StorageService.getTodayCheckIn();
    final mentalState = _buildMentalState(checkin, last, avgScore);

    // ── Insight ───────────────────────────────────────────────────────────────

    final insight = _buildInsight(
      avgScore: avgScore,
      variance: variance,
      spikeCount: spikeCount,
      avgPreShotHr: avgPreShotHr,
      seriesRows: seriesRows,
    );

    // ── Recommendations ───────────────────────────────────────────────────────

    final recs = _buildRecommendations(fatigueColor, avgScore);

    // ── Coach feedback ────────────────────────────────────────────────────────

    final coach = CoachFeedbackEntity(
      avatarInitial: 'B',
      coachName: 'Coach Ben',
      timestampLabel: 'Coach feedback · just now',
      message:
          'Good session. Focus on your follow-through in the next training. '
          'Your consistency between series is improving.',
      planLabel: 'View Assigned Plan',
    );

    return SessionReportEntity(
      sessionTitle: sessionTitle,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      physiology: physiology,
      seriesRows: seriesRows,
      hrMetrics: hrMetrics,
      hrPoints: hrPoints,
      mentalState: mentalState,
      insight: insight,
      recommendations: recs,
      coachFeedback: coach,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static double _parseScore(String display) {
    if (display == 'X') return 0.0;
    if (display == '<5') return 4.5;
    return double.tryParse(display) ?? 0.0;
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

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  static (String, MetricColor) _fatigueLevel(double variance) {
    if (variance < 3) return ('Low', MetricColor.good);
    if (variance < 6) return ('Medium', MetricColor.warning);
    return ('High', MetricColor.bad);
  }

  static (String, MetricColor) _recoveryLevel(
      Map<String, dynamic>? last, double avgScore) {
    if (last == null) return ('Good', MetricColor.good);
    final post = last['postSession'] as Map<String, dynamic>?;
    final rating = (post?['overallRating'] as num?)?.toInt() ?? 3;
    if (rating >= 4) return ('Good', MetricColor.good);
    if (rating == 3) return ('Fair', MetricColor.warning);
    return ('Poor', MetricColor.bad);
  }

  static String _hrZoneLabel(int avgHr) {
    if (avgHr < 60) return 'Zone 1';
    if (avgHr < 75) return 'Zone 2';
    if (avgHr < 90) return 'Zone 3';
    return 'Zone 4';
  }

  static MetricColor _hrZoneColor(int avgHr) {
    if (avgHr < 75) return MetricColor.good;
    if (avgHr < 90) return MetricColor.warning;
    return MetricColor.bad;
  }

  static MentalStateComparisonEntity _buildMentalState(
    Map<String, dynamic>? checkin,
    Map<String, dynamic>? last,
    double avgScore,
  ) {
    // Pre-session values from check-in (scale 1-5 → /10 by *2)
    final preStressRaw = (checkin?['stressLevel'] as num?)?.toInt() ?? 3;
    final preFocusRaw = (checkin?['focusLevel'] as num?)?.toInt() ?? 3;
    final preMoodRaw = (checkin?['moodRating'] as num?)?.toInt() ?? 3;
    final preEnergy = (preFocusRaw * 2).clamp(1, 10);
    final preStress = (preStressRaw * 2).clamp(1, 10);

    // Post-session values from stored session
    final post = last?['postSession'] as Map<String, dynamic>?;
    final postRating = (post?['overallRating'] as num?)?.toInt() ?? 3;
    final scoreFactor = (avgScore / 10).clamp(0.0, 1.0);
    final postMoodRaw = (preMoodRaw + (postRating >= 4 ? 0 : -1)).clamp(1, 5);
    final postFatigue = (10 - (scoreFactor * 4).round()).clamp(3, 9);
    final postSelfRating = (postRating * 2).clamp(2, 10);

    // Mood label mapping
    String moodLabel(int raw) => switch (raw) {
          5 => '🔥 Peak',
          4 => '😊 Good',
          3 => '😊 Okay',
          2 => '😕 Low',
          _ => '😤 Poor',
        };

    MetricColor moodColor(int raw) => raw >= 4
        ? MetricColor.good
        : raw == 3
            ? MetricColor.warning
            : MetricColor.bad;

    return MentalStateComparisonEntity(rows: [
      // Row 1: Mood before vs Mood after
      MentalStateRowEntity(
        before: MentalStateCellEntity(
          label: 'Mood',
          value: moodLabel(preMoodRaw),
          color: moodColor(preMoodRaw),
        ),
        after: MentalStateCellEntity(
          label: 'Mood',
          value: moodLabel(postMoodRaw),
          color: moodColor(postMoodRaw),
        ),
      ),
      // Row 2: Energy (pre) vs Fatigue (post)
      MentalStateRowEntity(
        before: MentalStateCellEntity(
          label: 'Energy',
          value: '$preEnergy / 10',
          color: preEnergy >= 6 ? MetricColor.good : MetricColor.warning,
        ),
        after: MentalStateCellEntity(
          label: 'Fatigue',
          value: '$postFatigue / 10',
          color: postFatigue <= 5 ? MetricColor.good : MetricColor.warning,
        ),
      ),
      // Row 3: Stress (pre) vs Self-rating (post)
      MentalStateRowEntity(
        before: MentalStateCellEntity(
          label: 'Stress',
          value: '$preStress / 10',
          color: preStress <= 4 ? MetricColor.good : MetricColor.warning,
        ),
        after: MentalStateCellEntity(
          label: 'Self-rating',
          value: '$postSelfRating / 10',
          color: postSelfRating >= 6 ? MetricColor.good : MetricColor.warning,
        ),
      ),
    ]);
  }

  static InsightEntity _buildInsight({
    required double avgScore,
    required double variance,
    required int spikeCount,
    required int avgPreShotHr,
    required List<ReportSeriesRowEntity> seriesRows,
  }) {
    if (spikeCount > 2 && seriesRows.isNotEmpty) {
      final worstSeries =
          seriesRows.reduce((a, b) => a.total < b.total ? a : b);
      return InsightEntity(
        headline:
            'Your HR spiked $spikeCount times and score dipped in S${worstSeries.seriesNumber}.',
        body: 'Stress-driven arousal broke your stability mid-session. '
            'When HR exceeds ~${avgPreShotHr + 8} bpm pre-shot, '
            'your grouping tends to open by 15–20%.',
      );
    }
    if (variance < 3 && avgScore >= 8) {
      return const InsightEntity(
        headline: 'Exceptional consistency',
        body: 'Your shot variance was minimal this session. You maintained '
            'tight groupings across all series — a sign of strong mental '
            'control under pressure.',
      );
    }
    if (avgScore >= 8) {
      return InsightEntity(
        headline: 'High scoring session',
        body: 'You scored ${avgScore.toStringAsFixed(1)} average per shot. '
            "Keep reinforcing this pre-shot routine — it's clearly working. "
            'Watch for slight drops in the final series.',
      );
    }
    return const InsightEntity(
      headline: 'Solid baseline performance',
      body: 'Your scores reflect a consistent baseline. Continue applying '
          'your pre-shot routine and look to increase shot scores '
          'in the 7–8 range toward 9–10.',
    );
  }

  static List<RecommendationItemEntity> _buildRecommendations(
      MetricColor fatigue, double avgScore) {
    return [
      RecommendationItemEntity(
        text: 'Complete a 5-minute breathing cool-down',
        isChecked: fatigue == MetricColor.good,
      ),
      RecommendationItemEntity(
        text: 'Review your shot sequence for series with lowest scores',
        isChecked: avgScore >= 8.5,
      ),
      const RecommendationItemEntity(
        text: 'Log your session reflection in journal',
        isChecked: false,
      ),
      if (fatigue == MetricColor.bad)
        const RecommendationItemEntity(
          text: 'Rest at least 24 hours before next high-intensity session',
          isChecked: false,
        ),
    ];
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
