import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';

/// Every field on [DashboardDataEntity] is sourced here from a real backend
/// call, or left honestly empty/null when no real source exists — no
/// fabricated fallback values (see the entity's own doc comments for the
/// exact source of each field).
class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardDataEntity> getDashboardData() async {
    final profileJson = StorageService.getAthleteProfile();
    final userProfile = StorageService.getUserProfile();
    final nameFromProfile = (profileJson?['name'] as String? ?? '').trim();
    final nameFromUser = (userProfile?['name'] as String? ?? '').trim();
    final rawName = nameFromProfile.isNotEmpty ? nameFromProfile : nameFromUser;
    var athleteName = rawName.isEmpty ? 'Athlete' : rawName;

    final todayCheckinCompleted = StorageService.getTodayCheckIn() != null;
    final isPolarConnected = StorageService.isPolarEnabled();

    final athleteId = AuthHelper.getCurrentAthleteId();

    var sessionsThisWeek = 0;
    double? weeklyAvgScore;
    int? streakDays;
    var aiInsights = const <String>[];
    CoachFeedbackData? coachFeedback;
    var performanceHistory = const <PerformanceDataPoint>[];
    var assessmentAnsweredCount = 0;
    var assessmentTotalQuestions = 0;
    var assessmentIsComplete = true;

    if (athleteId != null) {
      final assessmentStatus = await _fetchAssessmentStatus();
      if (assessmentStatus != null) {
        assessmentAnsweredCount = assessmentStatus.answeredCount;
        assessmentTotalQuestions = assessmentStatus.totalQuestions;
        assessmentIsComplete = assessmentStatus.isComplete;
      }

      // Mobile backend: real weekly summary (DashboardHomeResponse —
      // athlete_id, athlete_name, sessions_this_week, weekly_avg_score;
      // see app/modules/dashboard/schemas/responses.py). No other field is
      // ever returned by this endpoint — nothing else is read from it.
      final homeData = await _fetchMobileHomeData(athleteId);
      if (homeData != null) {
        final backendName = (homeData['athlete_name'] as String?)?.trim();
        if (backendName != null && backendName.isNotEmpty) {
          athleteName = backendName;
        }
        final weekCount = homeData['sessions_this_week'];
        if (weekCount is num) sessionsThisWeek = weekCount.toInt();
        final avgScore = homeData['weekly_avg_score'];
        if (avgScore is num) weeklyAvgScore = avgScore.toDouble();
      }

      aiInsights = await _fetchApiInsights(athleteId) ?? const [];
      coachFeedback = await _fetchApiCoachFeedback(athleteId, profileJson);
      streakDays = await _fetchStreak(athleteId);
      performanceHistory = await _fetchPerformanceHistory(athleteId);
    } else {
      debugPrint('[DASHBOARD] skipping API augmentation — no athlete_id');
    }

    return DashboardDataEntity(
      athleteName: athleteName,
      greeting: _getGreeting(),
      isPolarConnected: isPolarConnected,
      streakDays: (streakDays != null && streakDays > 0) ? streakDays : null,
      sessionsThisWeek: sessionsThisWeek,
      weeklyAvgScore: weeklyAvgScore,
      todayCheckinCompleted: todayCheckinCompleted,
      coachFeedback: coachFeedback,
      aiInsights: aiInsights,
      performanceHistory: performanceHistory,
      assessmentAnsweredCount: assessmentAnsweredCount,
      assessmentTotalQuestions: assessmentTotalQuestions,
      assessmentIsComplete: assessmentIsComplete,
    );
  }

  // ─── API: Psychology Assessment status ─────────────────────────────────────

  Future<
      ({
        int answeredCount,
        int totalQuestions,
        bool isComplete
      })?> _fetchAssessmentStatus() async {
    try {
      debugPrint('[DASHBOARD] fetching psychology-assessment status');
      final res = await ApiService.instance.getPsychologyAssessmentStatus();
      final data = res.data as Map<String, dynamic>;
      final answeredCount = data['answeredCount'] as int? ?? 0;
      final totalQuestions = data['totalQuestions'] as int? ?? 0;
      final isComplete = data['isComplete'] as bool? ?? true;
      debugPrint(
          '[DASHBOARD] psychology-assessment status answered=$answeredCount '
          'total=$totalQuestions isComplete=$isComplete');
      return (
        answeredCount: answeredCount,
        totalQuestions: totalQuestions,
        isComplete: isComplete,
      );
    } catch (e) {
      debugPrint('[DASHBOARD] psychology-assessment status fetch failed (non-fatal): $e');
      return null;
    }
  }

  // ─── API: AI Insights ──────────────────────────────────────────────────────
  //
  // Real, deterministically-generated rows from hamsatech.ai_insights
  // (populated server-side by hamsatech.generate_deterministic_insights once
  // the athlete's psychology assessment is scored — see the ASTRA-app-backend
  // model docstring for app/models/hamsatech_psychology.py). Returns null
  // (never canned copy) when the athlete has none yet.

  Future<List<String>?> _fetchApiInsights(String athleteId) async {
    try {
      debugPrint('[DASHBOARD] fetching ai_insights athleteId=$athleteId');
      final res = await ApiService.instance.getAiInsights(athleteId);
      final data = res.data;
      if (data is! List || data.isEmpty) return null;
      final texts = data
          .map((e) => (e as Map?)?['insight_text']?.toString())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .take(3)
          .toList();
      debugPrint('[DASHBOARD] ai_insights fetched count=${texts.length}');
      return texts.isEmpty ? null : texts;
    } catch (e) {
      debugPrint('[DASHBOARD] ai_insights fetch failed: $e');
      return null;
    }
  }

  // ─── API: Coach Feedback ───────────────────────────────────────────────────
  //
  // Real, human-authored rows from hamsatech.coach_feedback. Returns null
  // (never a fabricated welcome/rating-based message) when no coach has left
  // feedback yet.

  Future<CoachFeedbackData?> _fetchApiCoachFeedback(
    String athleteId,
    Map<String, dynamic>? profileJson,
  ) async {
    try {
      debugPrint('[DASHBOARD] fetching coach_feedback athleteId=$athleteId');
      final res = await ApiService.instance.getCoachFeedback(athleteId);
      final data = res.data;
      if (data is! List || data.isEmpty) return null;
      final row = data.first as Map<String, dynamic>;
      final notes = row['coach_notes']?.toString() ?? '';
      final plan = row['training_plan']?.toString() ?? '';
      if (notes.isEmpty && plan.isEmpty) return null;
      final coachName = profileJson?['coachName'] as String? ?? 'Coach';
      debugPrint('[DASHBOARD] coach_feedback fetched coachName=$coachName');
      return CoachFeedbackData(
        coachName: coachName,
        message: '"$notes"',
        about: 'Coach feedback',
        assigned: plan.isNotEmpty ? plan : 'Review plan',
        timestamp: DateTime.now(),
        isRead: false,
      );
    } catch (e) {
      debugPrint('[DASHBOARD] coach_feedback fetch failed: $e');
      return null;
    }
  }

  // ─── API: Streak ────────────────────────────────────────────────────────

  /// Real current streak from `GET /api/mobile/athletes/{id}/streak` —
  /// derived server-side from persisted completed sessions. Returns `null`
  /// (never a fabricated/estimated value) on any failure or unexpected
  /// response shape.
  Future<int?> _fetchStreak(String athleteId) async {
    try {
      debugPrint('[DASHBOARD] fetching streak athleteId=$athleteId');
      final res = await ApiService.instance.getStreak(athleteId);
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      final current = data['current_streak'];
      return current is num ? current.toInt() : null;
    } catch (e) {
      debugPrint('[DASHBOARD] streak fetch failed (non-fatal): $e');
      return null;
    }
  }

  // ─── API: Mobile backend home ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchMobileHomeData(String athleteId) async {
    try {
      debugPrint('[DASHBOARD] GET api/mobile/athletes/$athleteId/home');
      final res = await ApiService.instance.getDashboardHome(athleteId);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      // Handle wrapped response: { "data": { ... } }
      if (data is Map && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      debugPrint('[DASHBOARD] home: unexpected response shape: ${data.runtimeType}');
      return null;
    } catch (e) {
      debugPrint('[DASHBOARD] home fetch failed (non-fatal): $e');
      return null;
    }
  }

  // ─── API: Performance history ─────────────────────────────────────────────

  /// Real per-session score history from
  /// `GET /api/mobile/athletes/{id}/sessions` (SessionHistoryItem —
  /// avg_score/end_time, etc.; see app/modules/sessions/schemas/responses.py).
  /// The backend returns newest-first; reversed here to chronological order
  /// for charting. `avgScore` stays null per point when that session never
  /// had a score summary saved — never fabricated. Returns an empty list
  /// (never a demo/sample dataset) on any failure or when the athlete has no
  /// completed sessions yet.
  Future<List<PerformanceDataPoint>> _fetchPerformanceHistory(
    String athleteId,
  ) async {
    try {
      debugPrint('[DASHBOARD] fetching session history athleteId=$athleteId');
      final res = await ApiService.instance.getSessionHistory(
        athleteId: athleteId,
        page: 1,
        pageSize: 10,
      );
      final body = res.data;
      final items = body is Map ? body['data'] : null;
      if (items is! List || items.isEmpty) return const [];

      final chronological = items.reversed.toList();
      final points = <PerformanceDataPoint>[];
      for (var i = 0; i < chronological.length; i++) {
        final item = chronological[i];
        if (item is! Map) continue;
        final endTime = item['end_time']?.toString();
        final date = endTime != null ? DateTime.tryParse(endTime) : null;
        if (date == null) continue;
        final avgScore = item['avg_score'];
        points.add(PerformanceDataPoint(
          date: date,
          sessionNumber: i + 1,
          avgScore: avgScore is num ? avgScore.toDouble() : null,
        ));
      }
      debugPrint('[DASHBOARD] session history points=${points.length}');
      return points;
    } catch (e) {
      debugPrint('[DASHBOARD] session history fetch failed (non-fatal): $e');
      return const [];
    }
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
