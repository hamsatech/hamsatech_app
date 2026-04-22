import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/services/storage_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardDataEntity> getDashboardData() async {
    final profileJson = StorageService.getAthleteProfile();
    final athleteName = profileJson?['name'] as String? ?? 'Athlete';
    final baselineScores = StorageService.getBaselineScores() ?? {};
    final checkIn = StorageService.getTodayCheckIn();
    final sessions = StorageService.getSessions();

    final readiness = _buildReadiness(baselineScores, checkIn);
    final lastSession = _buildLastSession(sessions);
    final performanceHistory = _buildPerformanceHistory(sessions);
    final insights = _generateInsights(readiness, lastSession, performanceHistory);
    final actionPlan = _generateActionPlan(readiness);

    return DashboardDataEntity(
      athleteName: athleteName,
      readiness: readiness,
      aiInsights: insights,
      lastSession: lastSession,
      performanceHistory: performanceHistory,
      actionPlan: actionPlan,
    );
  }

  ReadinessMetrics _buildReadiness(
    Map<String, double> baseline,
    Map<String, dynamic>? checkIn,
  ) {
    double focus = baseline['focus'] ?? 60;
    double emotional = baseline['emotionalStability'] ?? 60;
    double decision = baseline['decisionStyle'] ?? 60;
    double motivation = baseline['motivation'] ?? 60;

    if (checkIn != null) {
      final energy = (checkIn['energy'] as num).toDouble();
      final checkInFocus = (checkIn['focus'] as num).toDouble();
      final stress = (checkIn['stress'] as num).toDouble();
      final confidence = (checkIn['confidence'] as num).toDouble();

      // Blend baseline with today's check-in
      focus = (focus * 0.4 + checkInFocus * 10 * 0.6).clamp(0, 100);
      emotional = (emotional * 0.4 + confidence * 10 * 0.6).clamp(0, 100);
      final stressLevel = stress * 10;
      final energyLevel = energy * 10;

      return ReadinessMetrics(
        readinessScore: (focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20)
            .clamp(0, 100),
        focusScore: focus,
        stressLevel: stressLevel,
        energyLevel: energyLevel,
        emotionalControl: emotional,
      );
    }

    return ReadinessMetrics(
      readinessScore: (focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20)
          .clamp(0, 100),
      focusScore: focus,
      stressLevel: 100 - emotional, // infer stress from emotional stability
      energyLevel: motivation * 0.8,
      emotionalControl: emotional,
    );
  }

  SessionSummaryData? _buildLastSession(List<Map<String, dynamic>> sessions) {
    final completed = sessions.where((s) => s['status'] == 'completed').toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) =>
        DateTime.parse(b['date'] as String)
            .compareTo(DateTime.parse(a['date'] as String)));
    final s = completed.first;
    final pre = s['preSession'] as Map<String, dynamic>? ?? {};
    final post = s['postSession'] as Map<String, dynamic>? ?? {};
    return SessionSummaryData(
      date: DateTime.parse(s['date'] as String),
      durationMinutes: (s['durationMinutes'] as num?)?.toInt() ?? 0,
      preSessionEnergy: (pre['energy'] as num?)?.toInt() ?? 5,
      preSessionFocus: (pre['focus'] as num?)?.toInt() ?? 5,
      preSessionStress: (pre['stress'] as num?)?.toInt() ?? 5,
      postSessionRating: (post['overallRating'] as num?)?.toInt() ?? 3,
    );
  }

  List<PerformanceDataPoint> _buildPerformanceHistory(
      List<Map<String, dynamic>> sessions) {
    final completed = sessions.where((s) => s['status'] == 'completed').toList();
    completed.sort((a, b) =>
        DateTime.parse(a['date'] as String)
            .compareTo(DateTime.parse(b['date'] as String)));
    final recent = completed.take(5).toList();
    return recent.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final pre = s['preSession'] as Map<String, dynamic>? ?? {};
      final post = s['postSession'] as Map<String, dynamic>? ?? {};
      final rating = (post['overallRating'] as num?)?.toDouble() ?? 3;
      final focus = (pre['focus'] as num?)?.toDouble() ?? 5;
      final stress = (pre['stress'] as num?)?.toDouble() ?? 5;
      return PerformanceDataPoint(
        date: DateTime.parse(s['date'] as String),
        sessionNumber: i + 1,
        overallRating: (rating / 5) * 100,
        focusScore: focus * 10,
        stressScore: stress * 10,
      );
    }).toList();
  }

  List<String> _generateInsights(
    ReadinessMetrics readiness,
    SessionSummaryData? lastSession,
    List<PerformanceDataPoint> history,
  ) {
    final insights = <String>[];

    if (readiness.stressLevel > 70) {
      insights.add(
        'High stress levels detected today. A 5-minute breathing routine before your session could significantly improve your accuracy and hold stability.',
      );
    }

    if (readiness.focusLevel == FocusLevel.low) {
      insights.add(
        'Your focus is below baseline today. Try a 2-minute visualisation of your perfect pre-shot routine before you start.',
      );
    }

    if (lastSession != null && lastSession.postSessionRating <= 2) {
      insights.add(
        'Your last session had a low quality rating. Review your session notes and identify one specific thing to improve today.',
      );
    }

    if (history.length >= 3) {
      final first = history.last.overallRating;
      final third = history[history.length >= 3 ? history.length - 3 : 0].overallRating;
      if (first - third < -10) {
        insights.add(
          'Your session quality shows a declining trend over the last 3 sessions. This often correlates with elevated pre-session stress — check in with your coach.',
        );
      } else if (first - third > 10) {
        insights.add(
          'Strong upward trend detected! Your consistency is improving. Keep trusting your process and stay in your routine.',
        );
      }
    }

    if (readiness.energyLevel < 40) {
      insights.add(
        'Low energy today. Prioritise recovery-based work — avoid high-intensity drills and focus on technical refinement.',
      );
    }

    if (insights.isEmpty) {
      insights.add(
        'You\'re in good shape today! Trust your preparation and stay present — each shot is an independent event.',
      );
      insights.add(
        'Consistency over perfection. Focus on your grouping and breathing pattern, not the score.',
      );
    }

    return insights.take(3).toList();
  }

  List<ActionItem> _generateActionPlan(ReadinessMetrics readiness) {
    final actions = <ActionItem>[];

    if (readiness.stressLevel > 60) {
      actions.add(const ActionItem(
        title: 'Breathing Exercise',
        description:
            '4-7-8 method: Inhale 4 counts, hold 7, exhale 8. Repeat 4 cycles before starting.',
        priority: ActionPriority.high,
        icon: Icons.air_rounded,
      ));
    }

    if (readiness.focusLevel == FocusLevel.low) {
      actions.add(const ActionItem(
        title: 'Focus Activation',
        description:
            'Spend 2 minutes mentally walking through your complete pre-shot routine with your eyes closed.',
        priority: ActionPriority.high,
        icon: Icons.psychology_rounded,
      ));
    }

    if (readiness.energyLevel < 50) {
      actions.add(const ActionItem(
        title: 'Energy Management',
        description:
            'Reduce session intensity to 70%. Avoid complex technical drills — focus on routine and hold.',
        priority: ActionPriority.medium,
        icon: Icons.battery_charging_full_rounded,
      ));
    }

    if (readiness.emotionalControl < 50) {
      actions.add(const ActionItem(
        title: 'Emotional Reset',
        description:
            'Write 3 things you\'re grateful for in your sport before your session begins.',
        priority: ActionPriority.medium,
        icon: Icons.favorite_border_rounded,
      ));
    }

    if (actions.isEmpty) {
      actions.add(const ActionItem(
        title: 'Process Focus Drill',
        description:
            'Complete 10 shots focusing only on hold time and breath timing. Score is irrelevant.',
        priority: ActionPriority.low,
        icon: Icons.gps_fixed_rounded,
      ));
      actions.add(const ActionItem(
        title: 'Consistency Review',
        description:
            'After your session, compare today\'s grouping pattern with your 5-session average.',
        priority: ActionPriority.low,
        icon: Icons.analytics_outlined,
      ));
    }

    return actions;
  }
}
