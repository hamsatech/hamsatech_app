import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardDataEntity extends Equatable {
  const DashboardDataEntity({
    required this.athleteName,
    required this.greeting,
    required this.readiness,
    required this.sleep,
    required this.restingHR,
    required this.hrStatus,
    required this.hrv,
    required this.isPolarConnected,
    this.streakDays,
    this.coachFeedback,
    required this.weeklyStats,
    required this.todayCheckinCompleted,
    required this.aiInsights,
    this.lastSession,
    required this.performanceHistory,
    required this.actionPlan,
  });

  final String athleteName;
  final String greeting;
  final ReadinessMetrics readiness;
  final SleepData sleep;
  final int restingHR;
  final String hrStatus;
  final HrvData hrv;
  final bool isPolarConnected;
  final int? streakDays;
  final CoachFeedbackData? coachFeedback;
  final WeeklyStats weeklyStats;
  final bool todayCheckinCompleted;
  final List<String> aiInsights;
  final SessionSummaryData? lastSession;
  final List<PerformanceDataPoint> performanceHistory;
  final List<ActionItem> actionPlan;

  DashboardDataEntity copyWith({
    bool? isPolarConnected,
    CoachFeedbackData? coachFeedback,
    bool? todayCheckinCompleted,
  }) {
    return DashboardDataEntity(
      athleteName: athleteName,
      greeting: greeting,
      readiness: readiness,
      sleep: sleep,
      restingHR: restingHR,
      hrStatus: hrStatus,
      hrv: hrv,
      isPolarConnected: isPolarConnected ?? this.isPolarConnected,
      streakDays: streakDays,
      coachFeedback: coachFeedback ?? this.coachFeedback,
      weeklyStats: weeklyStats,
      todayCheckinCompleted: todayCheckinCompleted ?? this.todayCheckinCompleted,
      aiInsights: aiInsights,
      lastSession: lastSession,
      performanceHistory: performanceHistory,
      actionPlan: actionPlan,
    );
  }

  @override
  List<Object?> get props => [
        athleteName,
        greeting,
        readiness,
        sleep,
        restingHR,
        hrStatus,
        hrv,
        isPolarConnected,
        streakDays,
        coachFeedback,
        weeklyStats,
        todayCheckinCompleted,
        aiInsights,
        lastSession,
        performanceHistory,
        actionPlan,
      ];
}

// ─── New entities for Figma design ──────────────────────────────────────────

class SleepData extends Equatable {
  const SleepData({
    required this.duration,
    required this.quality,
    required this.score,
  });

  final String duration; // e.g. "7h 20m"
  final String quality; // e.g. "Good"
  final double score; // 0.0–1.0 for progress indicator

  @override
  List<Object?> get props => [duration, quality, score];
}

class HrvData extends Equatable {
  const HrvData({
    required this.value,
    required this.status,
    required this.normalizedScore,
  });

  final int value; // ms
  final String status; // "Typical", "Above typical", "Below typical"
  final double normalizedScore; // 0.0–1.0 for progress indicator

  @override
  List<Object?> get props => [value, status, normalizedScore];
}

class CoachFeedbackData extends Equatable {
  const CoachFeedbackData({
    required this.coachName,
    required this.message,
    required this.about,
    required this.assigned,
    required this.timestamp,
    this.isRead = false,
  });

  final String coachName;
  final String message;
  final String about;
  final String assigned;
  final DateTime timestamp;
  final bool isRead;

  CoachFeedbackData copyWith({bool? isRead}) {
    return CoachFeedbackData(
      coachName: coachName,
      message: message,
      about: about,
      assigned: assigned,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        coachName,
        message,
        about,
        assigned,
        timestamp,
        isRead,
      ];
}

class WeeklyStats extends Equatable {
  const WeeklyStats({
    required this.averageScore,
    required this.sessionCount,
  });

  final double averageScore;
  final int sessionCount;

  @override
  List<Object?> get props => [averageScore, sessionCount];
}

// ─── Existing metrics/entities (kept for full compatibility) ─────────────────

class ReadinessMetrics extends Equatable {
  const ReadinessMetrics({
    required this.readinessScore,
    required this.focusScore,
    required this.stressLevel,
    required this.energyLevel,
    required this.emotionalControl,
  });

  final double readinessScore;
  final double focusScore;
  final double stressLevel;
  final double energyLevel;
  final double emotionalControl;

  ReadinessLevel get readinessLevel {
    if (readinessScore >= 70) return ReadinessLevel.ready;
    if (readinessScore >= 40) return ReadinessLevel.moderate;
    return ReadinessLevel.needsRecovery;
  }

  FocusLevel get focusLevel {
    if (focusScore >= 70) return FocusLevel.high;
    if (focusScore >= 40) return FocusLevel.medium;
    return FocusLevel.low;
  }

  @override
  List<Object?> get props => [
        readinessScore,
        focusScore,
        stressLevel,
        energyLevel,
        emotionalControl,
      ];
}

enum ReadinessLevel {
  ready('Ready', AppColors.readyGreen),
  moderate('Moderate', AppColors.moderateAmber),
  needsRecovery('Needs Recovery', AppColors.needsRecoveryRed);

  const ReadinessLevel(this.label, this.color);
  final String label;
  final Color color;
}

enum FocusLevel {
  high('High', DSColors.info),
  medium('Medium', DSColors.warning),
  low('Low', DSColors.error);

  const FocusLevel(this.label, this.color);
  final String label;
  final Color color;
}

class SessionSummaryData extends Equatable {
  const SessionSummaryData({
    required this.date,
    required this.durationMinutes,
    required this.preSessionEnergy,
    required this.preSessionFocus,
    required this.preSessionStress,
    required this.postSessionRating,
  });

  final DateTime date;
  final int durationMinutes;
  final int preSessionEnergy;
  final int preSessionFocus;
  final int preSessionStress;
  final int postSessionRating; // 1–5

  @override
  List<Object?> get props => [
        date,
        durationMinutes,
        preSessionEnergy,
        preSessionFocus,
        preSessionStress,
        postSessionRating,
      ];
}

class PerformanceDataPoint extends Equatable {
  const PerformanceDataPoint({
    required this.date,
    required this.sessionNumber,
    required this.overallRating,
    required this.focusScore,
    required this.stressScore,
  });

  final DateTime date;
  final int sessionNumber;
  final double overallRating; // 0–100
  final double focusScore;
  final double stressScore;

  @override
  List<Object?> get props =>
      [date, sessionNumber, overallRating, focusScore, stressScore];
}

class ActionItem extends Equatable {
  const ActionItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
  });

  final String title;
  final String description;
  final ActionPriority priority;
  final IconData icon;

  @override
  List<Object?> get props => [title, description, priority];
}

enum ActionPriority {
  high('High Priority', DSColors.error),
  medium('Recommended', DSColors.warning),
  low('Optional', DSColors.textSecondary);

  const ActionPriority(this.label, this.color);
  final String label;
  final Color color;
}
