import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';


class DashboardDataEntity extends Equatable {
  const DashboardDataEntity({
    required this.athleteName,
    required this.readiness,
    required this.aiInsights,
    this.lastSession,
    required this.performanceHistory,
    required this.actionPlan,
  });

  final String athleteName;
  final ReadinessMetrics readiness;
  final List<String> aiInsights;
  final SessionSummaryData? lastSession;
  final List<PerformanceDataPoint> performanceHistory;
  final List<ActionItem> actionPlan;

  @override
  List<Object?> get props => [
        athleteName,
        readiness,
        aiInsights,
        lastSession,
        performanceHistory,
        actionPlan,
      ];
}

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
  List<Object?> get props =>
      [readinessScore, focusScore, stressLevel, energyLevel, emotionalControl];
}

enum ReadinessLevel {
  ready('Ready', DSColors.success),
  moderate('Moderate', DSColors.warning),
  needsRecovery('Needs Recovery', DSColors.error);

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
  final double overallRating; // 1–5 mapped to 0–100
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
