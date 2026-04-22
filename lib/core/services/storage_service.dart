import 'dart:convert';
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
  }

  // ── User profile ──────────────────────────────────────────────────────────

  static Future<void> saveUserProfile(Map<String, dynamic> profile) =>
      _prefs.setString('user_profile', jsonEncode(profile));

  static Map<String, dynamic>? getUserProfile() {
    final str = _prefs.getString('user_profile');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  static Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool('onboarding_complete', value);

  static bool isOnboardingComplete() =>
      _prefs.getBool('onboarding_complete') ?? false;

  // ── Athlete profile ───────────────────────────────────────────────────────

  static Future<void> saveAthleteProfile(Map<String, dynamic> profile) =>
      _prefs.setString('athlete_profile', jsonEncode(profile));

  static Map<String, dynamic>? getAthleteProfile() {
    final str = _prefs.getString('athlete_profile');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Baseline scores ───────────────────────────────────────────────────────

  static Future<void> saveBaselineScores(Map<String, double> scores) =>
      _prefs.setString('baseline_scores', jsonEncode(scores));

  static Map<String, double>? getBaselineScores() {
    final str = _prefs.getString('baseline_scores');
    if (str == null) return null;
    final decoded = jsonDecode(str) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

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
