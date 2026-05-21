import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> saveAuthToken(String token) =>
      _prefs.setString('auth_token', token);

  static String? getAuthToken() => _prefs.getString('auth_token');

  static Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_profile');
    await _prefs.remove('profile_setup_complete');
    await _prefs.remove('onboarding_complete');
    await _prefs.remove('onboarding_step');
    await _prefs.remove('questionnaire_progress');
    await _prefs.remove('last_route');
  }

  // ── Last active route ─────────────────────────────────────────────────────

  // Only persist stable shell-tab destinations — deep/modal routes are
  // intentionally excluded because they require extra navigation state.
  static const _restorable = {'/home', '/sessions', '/insight', '/profile'};

  static Future<void> saveLastRoute(String route) {
    if (!_restorable.contains(route)) return Future.value();
    return _prefs.setString('last_route', route);
  }

  static String getLastRoute() =>
      _prefs.getString('last_route') ?? '/home';

  // ── User profile ──────────────────────────────────────────────────────────

  static Future<void> saveUserProfile(Map<String, dynamic> profile) =>
      _prefs.setString('user_profile', jsonEncode(profile));

  static Map<String, dynamic>? getUserProfile() {
    final str = _prefs.getString('user_profile');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  static Future<void> setProfileSetupComplete(bool value) =>
      _prefs.setBool('profile_setup_complete', value);

  static bool isProfileSetupComplete() =>
      _prefs.getBool('profile_setup_complete') ?? false;

  static Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool('onboarding_complete', value);

  static bool isOnboardingComplete() =>
      _prefs.getBool('onboarding_complete') ?? false;

  // Route of the last onboarding screen the user reached (for resume on cold start).
  static Future<void> saveOnboardingStep(String route) =>
      _prefs.setString('onboarding_step', route);

  static String getOnboardingStep() =>
      _prefs.getString('onboarding_step') ?? '';

  // ── Polar mode ────────────────────────────────────────────────────────────

  static Future<void> setPolarEnabled(bool value) =>
      _prefs.setBool('polar_enabled', value);

  // Returns true when the user completed Polar setup, false when explicitly
  // skipped ("I don't have Polar yet" / "Continue without Polar").
  static bool isPolarEnabled() => _prefs.getBool('polar_enabled') ?? false;

  // 'connected' = real Polar device; 'demo' = simulated demo device; '' = not set.
  static Future<void> setPolarConnectionMode(String mode) =>
      _prefs.setString('polar_connection_mode', mode);

  static String getPolarConnectionMode() =>
      _prefs.getString('polar_connection_mode') ?? '';

  // ── Questionnaire progress ────────────────────────────────────────────────

  static Future<void> saveQuestionnaireProgress(
      int questionIndex, Map<int, int> answers) {
    debugPrint('[Assessment] SAVE: index=$questionIndex, answered=${answers.length}');
    return _prefs.setString(
      'questionnaire_progress',
      jsonEncode({
        'index': questionIndex,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      }),
    );
  }

  // Returns {'index': int, 'answers': Map<int,int>} or null.
  static Map<String, dynamic>? getQuestionnaireProgress() {
    final str = _prefs.getString('questionnaire_progress');
    debugPrint('[Assessment] READ: ${str == null ? "null (no progress)" : "found, raw=${str.length}chars"}');
    if (str == null) return null;
    final data = jsonDecode(str) as Map<String, dynamic>;
    final answers = (data['answers'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(int.parse(k), v as int));
    return {'index': data['index'] as int, 'answers': answers};
  }

  static Future<void> clearQuestionnaireProgress() {
    debugPrint('[Assessment] CLEAR called\n${StackTrace.current}');
    return _prefs.remove('questionnaire_progress');
  }

  static bool hasIncompleteAssessment() => getQuestionnaireProgress() != null;

  static int getAssessmentRemainingCount(int totalQuestions) {
    final progress = getQuestionnaireProgress();
    if (progress == null) return 0;
    final answers = progress['answers'] as Map<int, int>;
    return totalQuestions - answers.length;
  }

  static Future<void> saveAssessmentSkippedFlag() =>
      _prefs.setBool('assessment_skipped_flag', true);

  static bool wasAssessmentJustSkipped() =>
      _prefs.getBool('assessment_skipped_flag') ?? false;

  static Future<void> clearAssessmentSkippedFlag() =>
      _prefs.remove('assessment_skipped_flag');

  // ── Athlete profile ───────────────────────────────────────────────────────

  static Future<void> saveAthleteProfile(Map<String, dynamic> profile) =>
      _prefs.setString('athlete_profile', jsonEncode(profile));

  static Map<String, dynamic>? getAthleteProfile() {
    final str = _prefs.getString('athlete_profile');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Supabase athlete_id (UUID returned after POST /athletes) ─────────────
  // This is the single source of truth for the current user's Supabase ID.
  // Written once after onboarding completes the athletes POST.
  // All session, log, and chat writes read from here via AuthHelper.

  static Future<void> saveAthleteId(String id) =>
      _prefs.setString('supabase_athlete_id', id);

  static String? getAthleteId() => _prefs.getString('supabase_athlete_id');

  // ── Baseline scores ───────────────────────────────────────────────────────

  static Future<void> saveBaselineScores(Map<String, double> scores) =>
      _prefs.setString('baseline_scores', jsonEncode(scores));

  static Map<String, double>? getBaselineScores() {
    final str = _prefs.getString('baseline_scores');
    if (str == null) return null;
    final decoded = jsonDecode(str) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0));
  }

  // ── Active session ID (current Supabase session UUID) ────────────────────
  // Written after POST /sessions returns a session_id.
  // Survives app restart so PATCH /sessions can close sessions opened offline.

  static Future<void> saveSessionId(String id) =>
      _prefs.setString('current_session_id', id);

  static String? getSessionId() => _prefs.getString('current_session_id');

  static Future<void> clearSessionId() => _prefs.remove('current_session_id');

  // ── Sessions ──────────────────────────────────────────────────────────────

  static Future<void> saveSessions(List<Map<String, dynamic>> sessions) =>
      _prefs.setString('sessions', jsonEncode(sessions));

  static List<Map<String, dynamic>> getSessions() {
    final str = _prefs.getString('sessions');
    if (str == null) return [];
    return (jsonDecode(str) as List).cast<Map<String, dynamic>>();
  }

  // ── Journal entries ───────────────────────────────────────────────────────

  static Future<void> saveJournalEntries(
      List<Map<String, dynamic>> entries) =>
      _prefs.setString('journal_entries', jsonEncode(entries));

  static List<Map<String, dynamic>> getJournalEntries() {
    final str = _prefs.getString('journal_entries');
    if (str == null) return [];
    return (jsonDecode(str) as List).cast<Map<String, dynamic>>();
  }

  // ── Today's pre-session check-in ──────────────────────────────────────────

  static Future<void> saveTodayCheckIn(Map<String, dynamic> checkIn) =>
      _prefs.setString('today_checkin', jsonEncode(checkIn));

  static Map<String, dynamic>? getTodayCheckIn() {
    final str = _prefs.getString('today_checkin');
    if (str == null) return null;
    final data = jsonDecode(str) as Map<String, dynamic>;
    final date = DateTime.parse(data['date'] as String);
    final isToday = DateTimeHelper.isToday(date);
    return isToday ? data : null;
  }

  // ── Session setup ─────────────────────────────────────────────────────────

  static Future<void> saveSessionSetup(Map<String, dynamic> setup) =>
      _prefs.setString('session_setup', jsonEncode(setup));

  static Map<String, dynamic>? getSessionSetup() {
    final str = _prefs.getString('session_setup');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Pre-session ritual ────────────────────────────────────────────────────

  static Future<void> saveRitualResult(Map<String, dynamic> result) =>
      _prefs.setString('last_ritual_result', jsonEncode(result));

  static Map<String, dynamic>? getLastRitualResult() {
    final str = _prefs.getString('last_ritual_result');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Score summary ─────────────────────────────────────────────────────────

  static Future<void> saveScoreSummary(
          List<Map<String, dynamic>> summary) =>
      _prefs.setString('score_summary', jsonEncode(summary));

  static List<Map<String, dynamic>>? getScoreSummary() {
    final str = _prefs.getString('score_summary');
    if (str == null) return null;
    return (jsonDecode(str) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> clearAll() => _prefs.clear();
}

class DateTimeHelper {
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
