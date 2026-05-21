import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

// PATH RULE: never start a path with '/'. baseUrl already ends with '/'.
//   'sessions'  → 'https://.../rest/v1/sessions'  ✓
//   '/sessions' → 'https://.../sessions'           ✗  (strips /rest/v1)
//
// TABLE NAMES:
//   'sessions'    → training sessions (session_id, athlete_id, start_time…)
//   'App_Sessions'→ auth token sessions (session_token, user_email, expires_at)
//                   Do NOT write training records to App_Sessions.
class ApiService {
  ApiService._() : _dio = _buildDio();

  static final ApiService instance = ApiService._();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'apikey': ApiConstants.anonKey,
          'Authorization': 'Bearer ${ApiConstants.anonKey}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Route all REST calls to hamsatech schema, not public.
          'Accept-Profile': 'hamsatech',
          'Content-Profile': 'hamsatech',
        },
      ),
    );
    dio.interceptors.add(_ApiLogger());
    return dio;
  }

  // ── Athlete ───────────────────────────────────────────────────────────────

  /// GET /rest/v1/athletes?athlete_id=eq.{id}&select=*,athlete_details(*),athlete_family(*)
  Future<Response<dynamic>> getAthleteProfile(String athleteId) =>
      _dio.get(
        'athletes',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'select': '*,athlete_details(*),athlete_family(*)',
        },
      );

  Future<Response<dynamic>> getAthletes() => _dio.get('athletes');

  /// POST /rest/v1/athletes — create a new athlete row during onboarding.
  /// Called once after the baseline assessment completes.
  /// Returns the inserted row so the caller can extract `athlete_id`.
  ///
  /// [gender] is optional — not collected during onboarding, defaults to ''.
  Future<Response<dynamic>> createAthleteFromProfile({
    required String athleteName,
    required int age,
    required String sport,
    String gender = '',
  }) {
    final body = <String, dynamic>{
      'athlete_name': athleteName,
      'age': age,
      'sport': sport,
      if (gender.isNotEmpty) 'gender': gender,
    };
    debugPrint('[ATHLETE CREATE] POST athletes body=$body');
    return _dio.post(
      'athletes',
      data: body,
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
  }

  // ── Sessions (training) ───────────────────────────────────────────────────
  // Table: sessions (session_id, athlete_id, session_type, start_time, end_time)
  // NOT App_Sessions — that table stores auth tokens, not training records.

  /// POST /rest/v1/sessions — create a new training session.
  /// Returns the inserted row (201 + JSON array) via Prefer: return=representation.
  Future<Response<dynamic>> createSession({
    required String athleteId,
    required String sessionType,
  }) async {
    final response = await _dio.post(
      'sessions',
      data: {
        'athlete_id': athleteId,
        'session_type': sessionType,
        'start_time': DateTime.now().toIso8601String(),
      },
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
    debugPrint('[SESSION CREATE RESPONSE] ${response.data}');
    return response;
  }

  /// PATCH /rest/v1/sessions?session_id=eq.{id} — set end_time when session closes.
  Future<Response<dynamic>> updateSessionEndTime({
    required String sessionId,
    required String endTime,
  }) {
    return _dio.patch(
      'sessions',
      queryParameters: {'session_id': 'eq.$sessionId'},
      data: {'end_time': endTime},
    );
  }

  /// PATCH /rest/v1/sessions?session_id=eq.{id} — set end_time on session close.
  /// Score data (total_score, shots_fired, series_data) goes to shooting_session_log,
  /// not here — those columns don't exist on the sessions table.
  Future<Response<dynamic>> updateSessionComplete({
    required String sessionId,
  }) {
    debugPrint('[SESSION END] PATCH sessions end_time id=$sessionId');
    return _dio.patch(
      'sessions',
      queryParameters: {'session_id': 'eq.$sessionId'},
      data: {'end_time': DateTime.now().toIso8601String()},
    );
  }

  // ── shooting_session_log ──────────────────────────────────────────────────
  // Columns: session_id, athlete_id, session_date, session_type, total_shots,
  //          session_duration_min, avg_score, best_series_score,
  //          consistency_index, technical_rating, stability_rating,
  //          focus_rating, confidence_rating, athlete_notes, coach_notes

  /// POST /rest/v1/shooting_session_log — write score summary after a scoring session.
  Future<Response<dynamic>> createShootingSessionLog({
    required String sessionId,
    required String athleteId,
    required int totalShots,
    required double avgScore,
    required double bestSeriesScore,
    String sessionType = 'scoring',
    int? sessionDurationMin,
    double? consistencyIndex,
  }) {
    final body = <String, dynamic>{
      'session_id': sessionId,
      'athlete_id': athleteId,
      'session_date': DateTime.now().toIso8601String().split('T').first,
      'session_type': sessionType,
      'total_shots': totalShots,
      'avg_score': double.parse(avgScore.toStringAsFixed(2)),
      'best_series_score': double.parse(bestSeriesScore.toStringAsFixed(2)),
      if (sessionDurationMin != null) 'session_duration_min': sessionDurationMin,
      if (consistencyIndex != null) 'consistency_index': double.parse(consistencyIndex.toStringAsFixed(2)),
    };
    debugPrint('[SHOOTING LOG] POST shooting_session_log $body');
    return _dio.post(
      'shooting_session_log',
      data: body,
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
  }

  // ── session_pre_log ───────────────────────────────────────────────────────
  // Columns: session_id, energy_level, readiness_score, mental_state,
  //          feeling_rating, mental_tags (array), morning_routine,
  //          warmup_status, sleep_quality, last_meal_timing,
  //          training_plan, equipment_status

  /// POST or PATCH /rest/v1/session_pre_log
  /// Call after creating the session in the sessions table.
  /// [existingId] is null on first save (POST) and non-null on edit (PATCH).
  Future<Response<dynamic>> savePreSessionLog({
    required String sessionId,
    required int energyLevel,
    required int readinessScore,
    required String mentalState,
    required String feelingRating,
    List<String> mentalTags = const [],
    String? existingId,
  }) {
    final body = {
      'session_id': sessionId,
      'energy_level': energyLevel,
      'readiness_score': readinessScore,
      'mental_state': mentalState,
      'feeling_rating': feelingRating,
      'mental_tags': mentalTags,
    };
    if (existingId == null) {
      return _dio.post(
        'session_pre_log',
        data: body,
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
    }
    return _dio.patch(
      'session_pre_log',
      queryParameters: {'id': 'eq.$existingId'},
      data: body,
    );
  }

  /// GET /rest/v1/session_pre_log?session_id=eq.{id}
  Future<Response<dynamic>> getPreSessionLog(String sessionId) =>
      _dio.get(
        'session_pre_log',
        queryParameters: {'session_id': 'eq.$sessionId'},
      );

  // ── session_post_log ──────────────────────────────────────────────────────
  // Columns: session_id, focus_level, focus_area, session_duration (text),
  //          performance_rating (int 1-10), challenges (array), coach_feedback

  /// POST or PATCH /rest/v1/session_post_log
  /// [existingId] is null on first save (POST) and non-null on edit (PATCH).
  Future<Response<dynamic>> savePostSessionLog({
    required String sessionId,
    required String focusLevel,
    required String focusArea,
    required String sessionDuration,
    required int performanceRating,
    List<String> challenges = const [],
    String coachFeedback = '',
    String? existingId,
  }) {
    final body = {
      'session_id': sessionId,
      'focus_level': focusLevel,
      'focus_area': focusArea,
      'session_duration': sessionDuration,
      'performance_rating': performanceRating,
      'challenges': challenges,
      'coach_feedback': coachFeedback,
    };
    if (existingId == null) {
      return _dio.post(
        'session_post_log',
        data: body,
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
    }
    return _dio.patch(
      'session_post_log',
      queryParameters: {'id': 'eq.$existingId'},
      data: body,
    );
  }

  /// GET /rest/v1/session_post_log?session_id=eq.{id}
  Future<Response<dynamic>> getPostSessionLog(String sessionId) =>
      _dio.get(
        'session_post_log',
        queryParameters: {'session_id': 'eq.$sessionId'},
      );

  // ── Psychology module ─────────────────────────────────────────────────────

  /// GET /rest/v1/psychology_questions?select=*,psychology_question_options(*)
  Future<Response<dynamic>> getPsychologyQuestions() =>
      _dio.get(
        'psychology_questions',
        queryParameters: {
          'select': '*,psychology_question_options(*)',
          'order': 'question_number.asc',
        },
      );

  /// POST /rest/v1/psychology_responses
  Future<Response<dynamic>> submitPsychologyResponse({
    required String athleteId,
    required int questionId,
    required String chosenOption,
    String? answerText,
  }) {
    return _dio.post(
      'psychology_responses',
      data: {
        'athlete_id': athleteId,
        'question_id': questionId,
        'chosen_option': chosenOption,
        if (answerText != null) 'answer_text': answerText,
      },
    );
  }

  /// GET /rest/v1/psychology_scores?athlete_id=eq.{id}
  Future<Response<dynamic>> getPsychologyScores(String athleteId) =>
      _dio.get(
        'psychology_scores',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Athlete chat (Saarthi) ────────────────────────────────────────────────

  /// GET /rest/v1/athlete_chat?athlete_id=eq.{id}&order=created_at.desc
  Future<Response<dynamic>> getChatHistory(String athleteId) =>
      _dio.get(
        'athlete_chat',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'order': 'created_at.desc',
        },
      );

  /// POST /rest/v1/athlete_chat
  Future<Response<dynamic>> saveChat({
    required String athleteId,
    required String sessionId,
    required String userMessage,
    required String aiResponse,
    String? sentiment,
    String? option,
  }) {
    return _dio.post(
      'athlete_chat',
      data: {
        'athlete_id': athleteId,
        'session_id': sessionId,
        'user_message': userMessage,
        'ai_response': aiResponse,
        if (sentiment != null) 'sentiment': sentiment,
        if (option != null) 'option': option,
      },
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
  }

  // ── Physiology ────────────────────────────────────────────────────────────

  /// GET /rest/v1/athlete_physiology?athlete_id=eq.{id}&order=recorded_date.desc
  Future<Response<dynamic>> getAthletePhysiology(String athleteId) =>
      _dio.get(
        'athlete_physiology',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'order': 'recorded_date.desc',
        },
      );

  /// POST /rest/v1/athlete_physiology
  Future<Response<dynamic>> saveAthletePhysiology(
      Map<String, dynamic> data) =>
      _dio.post('athlete_physiology', data: data);

  // ── Performance & AI ──────────────────────────────────────────────────────

  /// GET /rest/v1/performance_summary?athlete_id=eq.{id}&order=created_at.desc
  Future<Response<dynamic>> getPerformanceSummary(String athleteId) =>
      _dio.get(
        'performance_summary',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'order': 'created_at.desc',
        },
      );

  /// GET /rest/v1/ai_insights?athlete_id=eq.{id}
  Future<Response<dynamic>> getAiInsights(String athleteId) =>
      _dio.get(
        'ai_insights',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Tachus / shooting analytics ───────────────────────────────────────────

  /// GET /rest/v1/tachus_reports?athlete_id=eq.{id}
  Future<Response<dynamic>> getTachusReports(String athleteId) =>
      _dio.get(
        'tachus_reports',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Coach ─────────────────────────────────────────────────────────────────

  /// GET /rest/v1/coach_feedback?athlete_id=eq.{id}
  Future<Response<dynamic>> getCoachFeedback(String athleteId) =>
      _dio.get(
        'coach_feedback',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Audio library ─────────────────────────────────────────────────────────

  /// GET /rest/v1/audio_library?is_active=eq.true
  Future<Response<dynamic>> getAudioLibrary() =>
      _dio.get(
        'audio_library',
        queryParameters: {'is_active': 'eq.true'},
      );

  // ── Device streams (bulk write, Polar telemetry) ──────────────────────────

  /// POST /rest/v1/hr_stream — bulk insert heart rate readings.
  Future<Response<dynamic>> bulkInsertHrStream(
      List<Map<String, dynamic>> rows) =>
      _dio.post('hr_stream', data: rows);

  /// POST /rest/v1/ecg_stream — bulk insert ECG readings.
  Future<Response<dynamic>> bulkInsertEcgStream(
      List<Map<String, dynamic>> rows) =>
      _dio.post('ecg_stream', data: rows);

  /// POST /rest/v1/acc_stream — bulk insert accelerometer readings.
  Future<Response<dynamic>> bulkInsertAccStream(
      List<Map<String, dynamic>> rows) =>
      _dio.post('acc_stream', data: rows);

  // ── RPC ───────────────────────────────────────────────────────────────────

  /// POST /rest/v1/rpc/get_dashboard_data
  /// TODO(backend): PostgreSQL function must be created in Supabase first.
  /// Returns: {physiology, latest_session, session_summary, performance, insights}
  Future<Response<dynamic>> getDashboardData(String athleteId) =>
      _dio.post(
        'rpc/get_dashboard_data',
        data: {'p_athlete_id': athleteId},
      );
}

// ── Request / response logger ─────────────────────────────────────────────────

class _ApiLogger extends Interceptor {
  static const _line =
      '──────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint('[API ${options.method}] ${options.uri}');
      // Log schema-routing headers so POST failures are immediately diagnosable.
      debugPrint('  Accept-Profile  : ${options.headers['Accept-Profile']}');
      debugPrint('  Content-Profile : ${options.headers['Content-Profile']}');
      debugPrint('  Content-Type    : ${options.headers['Content-Type']}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('  params  : ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('  body    : ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint(
        '[API RESPONSE ${response.statusCode}] ${response.requestOptions.uri}',
      );
      debugPrint('  data   : ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(_line);
      debugPrint(
        '[API ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint('  type   : ${err.type.name}');
      debugPrint('  status : ${err.response?.statusCode}');
      debugPrint('  body   : ${err.response?.data}');
      debugPrint('  msg    : ${err.message}');
    }
    handler.next(err);
  }
}
