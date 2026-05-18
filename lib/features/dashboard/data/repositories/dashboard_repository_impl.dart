import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/services/storage_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardDataEntity> getDashboardData() async {
    final profileJson = StorageService.getAthleteProfile();
    final userProfile = StorageService.getUserProfile();
    final nameFromProfile = (profileJson?['name'] as String? ?? '').trim();
    final nameFromUser = (userProfile?['name'] as String? ?? '').trim();
    final rawName = nameFromProfile.isNotEmpty ? nameFromProfile : nameFromUser;
    final athleteName = rawName.isEmpty ? 'Athlete' : rawName;
    final baselineScores = StorageService.getBaselineScores() ?? {};
    final checkIn = StorageService.getTodayCheckIn();
    final sessions = StorageService.getSessions();

    final readiness = _buildReadiness(baselineScores, checkIn);
    final sleep = _buildSleepData(checkIn, baselineScores);
    final (restingHR, hrStatus) = _buildRestingHR(checkIn, readiness);
    final hrv = _buildHrvData(baselineScores, readiness);
    final lastSession = _buildLastSession(sessions);
    final performanceHistory = _buildPerformanceHistory(sessions);
    final insights = _generateInsights(readiness, lastSession, performanceHistory);
    final actionPlan = _generateActionPlan(readiness);
    final weeklyStats = _buildWeeklyStats(sessions);
    final coachFeedback = _buildCoachFeedback(lastSession);
    final streakDays = _calculateStreak(sessions);
    final isPolarConnected = StorageService.isPolarEnabled();
    final todayCheckinCompleted = checkIn != null;

    return DashboardDataEntity(
      athleteName: athleteName,
      greeting: _getGreeting(),
      readiness: readiness,
      sleep: sleep,
      restingHR: restingHR,
      hrStatus: hrStatus,
      hrv: hrv,
      isPolarConnected: isPolarConnected,
      streakDays: streakDays > 0 ? streakDays : null,
      coachFeedback: coachFeedback,
      weeklyStats: weeklyStats,
      todayCheckinCompleted: todayCheckinCompleted,
      aiInsights: insights,
      lastSession: lastSession,
      performanceHistory: performanceHistory,
      actionPlan: actionPlan,
    );
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ─── Readiness ────────────────────────────────────────────────────────────

  ReadinessMetrics _buildReadiness(
    Map<String, double> baseline,
    Map<String, dynamic>? checkIn,
  ) {
    double focus = baseline['focus'] ?? 60;
    double emotional = baseline['emotionalStability'] ?? 60;
    double decision = baseline['decisionStyle'] ?? 60;
    double motivation = baseline['motivation'] ?? 60;

    if (checkIn != null) {
      final energy = (checkIn['energy'] as num?)?.toDouble() ?? 5.0;
      final checkInFocus = (checkIn['focus'] as num?)?.toDouble() ?? 5.0;
      final stress = (checkIn['stress'] as num?)?.toDouble() ?? 5.0;
      final confidence = (checkIn['confidence'] as num?)?.toDouble() ?? 5.0;

      focus = (focus * 0.4 + checkInFocus * 10 * 0.6).clamp(0, 100);
      emotional = (emotional * 0.4 + confidence * 10 * 0.6).clamp(0, 100);
      final stressLevel = stress * 10;
      final energyLevel = energy * 10;

      return ReadinessMetrics(
        readinessScore: (focus * 0.30 +
                emotional * 0.25 +
                decision * 0.25 +
                motivation * 0.20)
            .clamp(0, 100),
        focusScore: focus,
        stressLevel: stressLevel,
        energyLevel: energyLevel,
        emotionalControl: emotional,
      );
    }

    return ReadinessMetrics(
      readinessScore:
          (focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20)
              .clamp(0, 100),
      focusScore: focus,
      stressLevel: 100 - emotional,
      energyLevel: motivation * 0.8,
      emotionalControl: emotional,
    );
  }

  // ─── Sleep ────────────────────────────────────────────────────────────────

  SleepData _buildSleepData(
    Map<String, dynamic>? checkIn,
    Map<String, double> baseline,
  ) {
    // Derive sleep quality from energy level (higher energy = better sleep)
    final energy = checkIn != null
        ? (checkIn['energy'] as num?)?.toDouble() ?? 5.0
        : (baseline['motivation'] ?? 5) / 10;

    final energyNorm = energy.clamp(0.0, 10.0);
    // Map energy 0-10 to sleep hours 5h-9h
    final totalMinutes = (300 + (energyNorm / 10) * 240).round();
    final hours = totalMinutes ~/ 60;
    final minutes = (totalMinutes % 60 ~/ 10) * 10; // round to nearest 10m
    final score = (energyNorm / 10).clamp(0.0, 1.0);

    String quality;
    if (score >= 0.75) {
      quality = 'Good';
    } else if (score >= 0.5) {
      quality = 'Fair';
    } else {
      quality = 'Poor';
    }

    return SleepData(
      duration: minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h',
      quality: quality,
      score: score,
    );
  }

  // ─── Resting HR ───────────────────────────────────────────────────────────

  (int hr, String status) _buildRestingHR(
    Map<String, dynamic>? checkIn,
    ReadinessMetrics readiness,
  ) {
    final energyLevel = readiness.energyLevel;
    // Higher energy/recovery → lower resting HR (60–80 bpm range)
    final hr = (80 - (energyLevel / 100) * 20).round().clamp(55, 90);

    String status;
    if (hr < 60) {
      status = 'Athletic';
    } else if (hr < 70) {
      status = 'Stable';
    } else if (hr < 80) {
      status = 'Elevated';
    } else {
      status = 'High';
    }

    return (hr, status);
  }

  // ─── HRV ──────────────────────────────────────────────────────────────────

  HrvData _buildHrvData(
    Map<String, double> baseline,
    ReadinessMetrics readiness,
  ) {
    // HRV correlates with recovery and stress: higher recovery = higher HRV
    final recoveryFactor = (readiness.readinessScore / 100);
    final value = (30 + recoveryFactor * 60).round().clamp(20, 100);

    final normalizedScore = ((value - 20) / 80).clamp(0.0, 1.0);

    String status;
    if (normalizedScore >= 0.65) {
      status = 'Above typical';
    } else if (normalizedScore >= 0.35) {
      status = 'Typical';
    } else {
      status = 'Below typical';
    }

    return HrvData(
      value: value,
      status: status,
      normalizedScore: normalizedScore,
    );
  }

  // ─── Sessions ─────────────────────────────────────────────────────────────

  SessionSummaryData? _buildLastSession(List<Map<String, dynamic>> sessions) {
    final completed =
        sessions.where((s) => s['status'] == 'completed').toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => DateTime.parse(b['date'] as String)
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
    final completed =
        sessions.where((s) => s['status'] == 'completed').toList();
    completed.sort((a, b) => DateTime.parse(a['date'] as String)
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

  // ─── Weekly Stats ─────────────────────────────────────────────────────────

  WeeklyStats _buildWeeklyStats(List<Map<String, dynamic>> sessions) {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));

    final thisWeek = sessions.where((s) {
      if (s['status'] != 'completed') return false;
      final date = DateTime.parse(s['date'] as String);
      return !date.isBefore(startOfWeek);
    }).toList();

    if (thisWeek.isEmpty) {
      return const WeeklyStats(averageScore: 0, sessionCount: 0);
    }

    final scores = thisWeek.map((s) {
      final post = s['postSession'] as Map<String, dynamic>? ?? {};
      final pre = s['preSession'] as Map<String, dynamic>? ?? {};
      final rating = (post['overallRating'] as num?)?.toDouble() ?? 3.0;
      final focus = (pre['focus'] as num?)?.toDouble() ?? 5.0;
      final energy = (pre['energy'] as num?)?.toDouble() ?? 5.0;
      final stress = (pre['stress'] as num?)?.toDouble() ?? 5.0;
      return (rating * 100 + focus * 20 + energy * 20 - stress * 10)
          .clamp(0.0, 1000.0);
    }).toList();

    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return WeeklyStats(averageScore: avg, sessionCount: thisWeek.length);
  }

  // ─── Streak ───────────────────────────────────────────────────────────────

  int _calculateStreak(List<Map<String, dynamic>> sessions) {
    final completed =
        sessions.where((s) => s['status'] == 'completed').toList();
    if (completed.isEmpty) return 0;

    final dates = completed
        .map((s) {
          final d = DateTime.parse(s['date'] as String);
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    var expected = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final date in dates) {
      if (date == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (date.isBefore(expected)) {
        break;
      }
    }

    return streak;
  }

  // ─── Coach Feedback ───────────────────────────────────────────────────────

  CoachFeedbackData _buildCoachFeedback(SessionSummaryData? lastSession) {
    final profileJson = StorageService.getAthleteProfile();
    final coachName = profileJson?['coachName'] as String? ?? 'Coach Babu Rao';

    if (lastSession == null) {
      // No sessions yet — coach welcomes the athlete and assigns first drill
      return CoachFeedbackData(
        coachName: coachName,
        message:
            '"Welcome to your training programme. Complete your first session today and I\'ll give you personalised feedback on your mental performance."',
        about: 'Getting started',
        assigned: 'Pre-Shot Breathing',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      );
    }

    // Derive message tone from last session quality
    final rating = lastSession.postSessionRating;
    final String message;
    final String assigned;

    if (rating >= 4) {
      message =
          '"Excellent session yesterday. Your HR was steady through series 1–2. Keep trusting your process — your consistency is showing."';
      assigned = 'Consistency Drill';
    } else if (rating >= 3) {
      message =
          '"Good session yesterday. Your HR was steady through series 1–2. Try the pre-shot breathing routine today."';
      assigned = 'Pre-Shot Breath';
    } else {
      message =
          '"Review yesterday\'s session. Focus on your pre-shot routine — breathing and hold time. Quality over quantity today."';
      assigned = 'Focus Reset Drill';
    }

    return CoachFeedbackData(
      coachName: coachName,
      message: message,
      about: 'Yesterday\'s session',
      assigned: assigned,
      timestamp: lastSession.date,
      isRead: false,
    );
  }

  // ─── AI Insights ──────────────────────────────────────────────────────────

  List<String> _generateInsights(
    ReadinessMetrics readiness,
    SessionSummaryData? lastSession,
    List<PerformanceDataPoint> history,
  ) {
    final insights = <String>[];

    if (readiness.stressLevel > 70) {
      insights.add(
        'High stress detected. A 5-minute breathing routine before your session could improve accuracy and hold stability.',
      );
    }

    if (readiness.focusLevel == FocusLevel.low) {
      insights.add(
        'Focus is below baseline today. Try a 2-minute visualisation of your perfect pre-shot routine before you start.',
      );
    }

    if (lastSession != null && lastSession.postSessionRating <= 2) {
      insights.add(
        'Your last session had a low quality rating. Review your notes and identify one specific thing to improve today.',
      );
    }

    if (history.length >= 3) {
      final newest = history.last.overallRating;
      final older = history[history.length - 3].overallRating;
      if (newest - older < -10) {
        insights.add(
          'Declining trend over last 3 sessions. This often correlates with elevated pre-session stress — check in with your coach.',
        );
      } else if (newest - older > 10) {
        insights.add(
          'Strong upward trend! Your consistency is improving. Keep trusting your process.',
        );
      }
    }

    if (readiness.energyLevel < 40) {
      insights.add(
        'Low energy today. Focus on recovery-based work and technical refinement rather than high-intensity drills.',
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

  // ─── Action Plan ──────────────────────────────────────────────────────────

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
            'Reduce session intensity to 70%. Focus on routine and hold over complex technical drills.',
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
