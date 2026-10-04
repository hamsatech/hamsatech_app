import 'package:equatable/equatable.dart';

/// Everything on this entity is either a real backend value, a value
/// genuinely derived from real backend/athlete data, or an honest "not
/// available" signal (null / empty list) — never a fabricated fallback.
/// See DashboardRepositoryImpl for the exact source of each field.
class DashboardDataEntity extends Equatable {
  const DashboardDataEntity({
    required this.athleteName,
    required this.greeting,
    required this.isPolarConnected,
    this.streakDays,
    required this.sessionsThisWeek,
    this.weeklyAvgScore,
    required this.todayCheckinCompleted,
    this.coachFeedback,
    required this.aiInsights,
    required this.performanceHistory,
    this.assessmentAnsweredCount = 0,
    this.assessmentTotalQuestions = 0,
    this.assessmentIsComplete = true,
  });

  final String athleteName;
  final String greeting;
  final bool isPolarConnected;

  // Real, from GET /api/mobile/athletes/{id}/streak. Null means "not
  // available yet" (fetch failed, or genuinely zero — the UI already hides
  // the streak badge for both), never a fabricated/estimated value.
  final int? streakDays;

  // Real, from GET /api/mobile/athletes/{id}/home (DashboardHomeResponse).
  final int sessionsThisWeek;
  final double? weeklyAvgScore; // null = no scored sessions yet this week

  final bool todayCheckinCompleted;

  // Real human coach feedback, from GET /rest/v1/coach_feedback — null when
  // no coach has left feedback yet. Never a locally-fabricated message.
  final CoachFeedbackData? coachFeedback;

  // Real, deterministically-generated insight text from
  // GET /rest/v1/ai_insights (hamsatech.ai_insights, populated server-side
  // by hamsatech.generate_deterministic_insights once the athlete's
  // psychology assessment is scored). Empty list — never canned copy —
  // when none exist yet.
  final List<String> aiInsights;

  // Real per-session score history, from
  // GET /api/mobile/athletes/{id}/sessions. Empty when the athlete has no
  // completed sessions yet.
  final List<PerformanceDataPoint> performanceHistory;

  // Populated from GET /api/v2/psychology-assessment (non-fatal on failure —
  // defaults leave the Assessment Reminder card hidden).
  final int assessmentAnsweredCount;
  final int assessmentTotalQuestions;
  final bool assessmentIsComplete;

  DashboardDataEntity copyWith({
    bool? isPolarConnected,
    CoachFeedbackData? coachFeedback,
    bool? todayCheckinCompleted,
  }) {
    return DashboardDataEntity(
      athleteName: athleteName,
      greeting: greeting,
      isPolarConnected: isPolarConnected ?? this.isPolarConnected,
      streakDays: streakDays,
      sessionsThisWeek: sessionsThisWeek,
      weeklyAvgScore: weeklyAvgScore,
      todayCheckinCompleted:
          todayCheckinCompleted ?? this.todayCheckinCompleted,
      coachFeedback: coachFeedback ?? this.coachFeedback,
      aiInsights: aiInsights,
      performanceHistory: performanceHistory,
      assessmentAnsweredCount: assessmentAnsweredCount,
      assessmentTotalQuestions: assessmentTotalQuestions,
      assessmentIsComplete: assessmentIsComplete,
    );
  }

  @override
  List<Object?> get props => [
        athleteName,
        greeting,
        isPolarConnected,
        streakDays,
        sessionsThisWeek,
        weeklyAvgScore,
        todayCheckinCompleted,
        coachFeedback,
        aiInsights,
        performanceHistory,
        assessmentAnsweredCount,
        assessmentTotalQuestions,
        assessmentIsComplete,
      ];
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

/// One completed session's real score, for the performance-history chart.
/// [avgScore] is null when the session was completed but no score summary
/// was ever saved for it — plotted as a gap, never a fabricated value.
class PerformanceDataPoint extends Equatable {
  const PerformanceDataPoint({
    required this.date,
    required this.sessionNumber,
    required this.avgScore,
  });

  final DateTime date;
  final int sessionNumber;
  final double? avgScore;

  @override
  List<Object?> get props => [date, sessionNumber, avgScore];
}
