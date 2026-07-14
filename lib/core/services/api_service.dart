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
  ApiService._()
      : _dio = _buildDio(),
        _mobileDio = _buildMobileDio();

  static final ApiService instance = ApiService._();

  final Dio _dio;

  // Separate Dio instance for the custom mobile backend (OTP + registration).
  // Does NOT carry Supabase schema headers — plain JSON REST.
  final Dio _mobileDio;

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

  /// Updates the Bearer token sent with every mobile backend request.
  /// Call immediately after a successful OTP verification and on app startup.
  /// Pass null to clear the token (e.g. after logout).
  static void setMobileAuthToken(String? token) =>
      _MobileAuthInterceptor.setToken(token);

  static Dio _buildMobileDio() {
    debugPrint(
        '[API BASE URL] mobile backend: ${ApiConstants.mobileApiBaseUrl}');
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.mobileApiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    // Auth interceptor must run before the logger so logged requests already
    // carry the Authorization header.
    dio.interceptors.add(_MobileAuthInterceptor());
    dio.interceptors.add(_ApiLogger());
    return dio;
  }

  // ── Mobile backend — Onboarding ───────────────────────────────────────────

  /// POST /api/v1/onboarding/personal-details
  Future<Response<dynamic>> saveOnboardingPersonalDetails({
    required String athleteId,
    required String fullName,
    required int age,
    required String gender,
    required String city,
  }) =>
      _mobileDio.post(
        'api/v1/onboarding/personal-details',
        data: {
          'athlete_id': athleteId,
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'city': city,
        },
      );

  /// POST /api/v1/onboarding/shooting-profile
  Future<Response<dynamic>> saveOnboardingShootingProfile({
    required String athleteId,
    required String discipline,
    required String experienceLevel,
    required int yearsShooting,
    String academyOrClub = '',
  }) =>
      _mobileDio.post(
        'api/v1/onboarding/shooting-profile',
        data: {
          'athlete_id': athleteId,
          'discipline': discipline,
          'experience_level': experienceLevel,
          'years_shooting': yearsShooting,
          if (academyOrClub.isNotEmpty) 'academy_or_club': academyOrClub,
        },
      );

  /// POST /api/v1/onboarding/current-performance
  Future<Response<dynamic>> saveOnboardingCurrentPerformance({
    required String athleteId,
    required String avgPracticeScore,
    required String targetScore,
    List<String> performanceBlockers = const [],
  }) =>
      _mobileDio.post(
        'api/v1/onboarding/current-performance',
        data: {
          'athlete_id': athleteId,
          'avg_practice_score': avgPracticeScore,
          'target_score': targetScore,
          'performance_blockers': performanceBlockers,
        },
      );

  /// POST /api/v1/onboarding/goals — backend also sets onboarding_complete = true.
  Future<Response<dynamic>> saveOnboardingGoals({
    required String athleteId,
    required String goal30d,
    required String goal6m,
  }) =>
      _mobileDio.post(
        'api/v1/onboarding/goals',
        data: {
          'athlete_id': athleteId,
          'goal_30d': goal30d,
          'goal_6m': goal6m,
        },
      );

  /// GET /api/v1/onboarding/summary/{athlete_id}
  Future<Response<dynamic>> getOnboardingSummary(String athleteId) =>
      _mobileDio.get('api/v1/onboarding/summary/$athleteId');

  // ── Mobile backend — Daily check-in ──────────────────────────────────────

  /// POST /api/v1/checkin/daily
  Future<Response<dynamic>> saveDailyCheckin({
    required String athleteId,
    required int mood,
    required int energyLevel,
    required String sleepBand,
    List<String> tags = const [],
    String notes = '',
  }) =>
      _mobileDio.post(
        'api/v1/checkin/daily',
        data: {
          'athlete_id': athleteId,
          'mood': mood,
          'energy_level': energyLevel,
          'sleep_band': sleepBand,
          if (tags.isNotEmpty) 'tags': tags,
          if (notes.isNotEmpty) 'notes': notes,
        },
      );

  // ── Mobile backend — Athlete Registration ────────────────────────────────

  /// POST /api/mobile/athletes/register
  /// Matches MobileAthleteRegistrationInput exactly: fullName, email, age,
  /// gender, phone are required by the live schema; athleteId, sport and
  /// focusArea are optional. Passing an existing [athleteId] attaches to
  /// that row instead of minting a new athlete (confirmed against the live
  /// backend — omitting it creates a duplicate athlete every time).
  Future<Response<dynamic>> registerAthlete({
    required String fullName,
    required String email,
    required int age,
    required String gender,
    required String phone,
    String? athleteId,
    String? sport,
    String? focusArea,
  }) {
    debugPrint('[ATHLETE REGISTER] POST api/mobile/athletes/register athleteId=$athleteId');
    return _mobileDio.post(
      'api/mobile/athletes/register',
      data: {
        if (athleteId != null && athleteId.isNotEmpty) 'athleteId': athleteId,
        'fullName': fullName,
        'email': email,
        'age': age,
        'gender': gender,
        'phone': phone,
        if (sport != null && sport.isNotEmpty) 'sport': sport,
        if (focusArea != null && focusArea.isNotEmpty) 'focusArea': focusArea,
      },
    );
  }

  // ── Mobile backend — OTP auth ─────────────────────────────────────────────

  /// POST https://hamsatech-api.onrender.com/api/v1/auth/phone/send-otp
  /// Triggers Twilio Verify OTP to the given phone number.
  Future<Response<dynamic>> sendOtpToBackend(String phone) async {
    const endpoint = 'api/v1/auth/phone/send-otp';
    final base = _mobileDio.options.baseUrl;
    final fullUrl = '$base$endpoint';
    final body = {'phone': phone};

    debugPrint('──────────────────────────────────────────────');
    debugPrint('[OTP REQUEST]');
    debugPrint('POST $fullUrl');
    debugPrint('BODY: $body');
    debugPrint('──────────────────────────────────────────────');

    final res = await _mobileDio.post(endpoint, data: body);

    debugPrint('──────────────────────────────────────────────');
    debugPrint('[OTP RESPONSE]');
    debugPrint('STATUS: ${res.statusCode}');
    debugPrint('BODY: ${res.data}');
    debugPrint('──────────────────────────────────────────────');

    return res;
  }

  /// POST https://hamsatech-api.onrender.com/api/v1/auth/phone/verify-otp
  /// Matches PhoneOtpVerifyRequest exactly: { phone, otp } only — the live
  /// schema has no fullName/age/gender/sport/focusArea fields.
  /// Returns PhoneOtpVerifyResponse: { athleteId, success }.
  Future<Response<dynamic>> verifyOtpAndRegister({
    required String phone,
    required String otp,
  }) async {
    const endpoint = 'api/v1/auth/phone/verify-otp';
    final base = _mobileDio.options.baseUrl;
    final fullUrl = '$base$endpoint';
    final body = <String, dynamic>{
      'phone': phone,
      'otp': otp,
    };

    debugPrint('══════════════════════════════════════════════');
    debugPrint('[OTP VERIFY — REQUEST]');
    debugPrint('POST $fullUrl');
    debugPrint('BODY (raw)  : $body');
    debugPrint('phone value : "$phone"');
    debugPrint(
        'otp value   : "$otp"  (length=${otp.length}, codeUnits=${otp.codeUnits})');
    debugPrint('══════════════════════════════════════════════');

    // try/catch here is instrumentation only — the exception is rethrown
    // unchanged so calling code sees identical behavior to before.
    try {
      final res = await _mobileDio.post(endpoint, data: body);
      debugPrint('══════════════════════════════════════════════');
      debugPrint('[OTP VERIFY — RESPONSE] SUCCESS');
      debugPrint('STATUS: ${res.statusCode}');
      debugPrint('BODY  : ${res.data}');
      debugPrint('══════════════════════════════════════════════');
      return res;
    } on DioException catch (e) {
      debugPrint('══════════════════════════════════════════════');
      debugPrint('[OTP VERIFY — RESPONSE] ERROR');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('BODY  : ${e.response?.data}');
      debugPrint('══════════════════════════════════════════════');
      rethrow;
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  /// GET /rest/v1/users?phone_number=eq.{phone}&select=uid
  ///
  /// Called once after OTP verification to resolve the canonical uid from
  /// hamsatech.users. This uid is stored locally and passed as athlete_id
  /// in POST /athletes so both tables share the same identifier.
  Future<Response<dynamic>> getUserByPhone(String phone) => _dio.get(
        'users',
        queryParameters: {
          'phone_number': 'eq.$phone',
          'select': 'uid',
        },
      );

  // ── Athlete ───────────────────────────────────────────────────────────────

  /// GET /rest/v1/athletes?athlete_id=eq.{id}&select=*,athlete_details(*),athlete_family(*)
  Future<Response<dynamic>> getAthleteProfile(String athleteId) => _dio.get(
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
  /// Valid columns: athlete_id, athlete_name, age, contact_number, experience_level.
  /// [athleteId] is optional — pass the stored UUID on retry to prevent
  /// duplicate rows; omit on first creation to let the DB auto-generate it.
  Future<Response<dynamic>> createAthleteFromProfile({
    required String athleteName,
    required int age,
    required String contactNumber,
    required String experienceLevel,
    String? athleteId,
  }) {
    final body = <String, dynamic>{
      if (athleteId != null && athleteId.isNotEmpty) 'athlete_id': athleteId,
      'athlete_name': athleteName,
      'age': age,
      'contact_number': contactNumber,
      'experience_level': experienceLevel,
    };
    debugPrint('[ATHLETE CREATE] POST /athletes payload=$body');
    return _dio.post(
      'athletes',
      data: body,
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
  }

  // ── Sessions (training) ───────────────────────────────────────────────────

  /// POST /api/mobile/athletes/{athleteId}/sessions
  /// Creates a training session via the mobile backend (canonical endpoint).
  /// Response: { session_id, athlete_id, session_type, status, start_time, ... }
  Future<Response<dynamic>> createMobileSession({
    required String athleteId,
    required String sessionType,
    required String rangeType,
    required int plannedShots,
    required String discipline,
  }) {
    debugPrint('[SESSION CREATE] POST api/mobile/athletes/$athleteId/sessions');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions',
      data: {
        'range_type': rangeType,
        'session_type': sessionType,
        'planned_shots': plannedShots,
        'discipline': discipline,
      },
    );
  }

  /// POST /api/mobile/athletes/{athleteId}/sessions/{sessionId}/series
  /// Submits one completed series. Called once per series after final confirmation.
  /// Payload: { series_number, total_score, shots_fired }
  Future<Response<dynamic>> saveSeries({
    required String athleteId,
    required String sessionId,
    required int seriesNumber,
    required double totalScore,
    required int shotsFired,
  }) {
    debugPrint(
        '[SERIES] POST api/mobile/athletes/$athleteId/sessions/$sessionId/series #$seriesNumber');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions/$sessionId/series',
      data: {
        'series_number': seriesNumber,
        'total_score': totalScore,
        'shots_fired': shotsFired,
      },
    );
  }

  /// POST /api/mobile/athletes/{athleteId}/sessions/{sessionId}/complete
  /// Signals session completion to the mobile backend with optional score summary.
  /// All fields except athleteId and sessionId are optional — pass what's available.
  Future<Response<dynamic>> completeMobileSession({
    required String athleteId,
    required String sessionId,
    int? durationMinutes,
    int? totalShots,
    double? totalScore,
    double? avgScore,
    double? bestSeriesScore,
    int? performanceRating,
    String? notes,
  }) {
    debugPrint(
        '[SESSION COMPLETE] POST api/mobile/athletes/$athleteId/sessions/$sessionId/complete');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions/$sessionId/complete',
      data: {
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (totalShots != null) 'total_shots': totalShots,
        if (totalScore != null) 'total_score': totalScore,
        if (avgScore != null) 'avg_score': avgScore,
        if (bestSeriesScore != null) 'best_series_score': bestSeriesScore,
        if (performanceRating != null) 'performance_rating': performanceRating,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// POST /rest/v1/sessions — legacy Supabase direct write (kept for fallback).
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
      if (sessionDurationMin != null)
        'session_duration_min': sessionDurationMin,
      if (consistencyIndex != null)
        'consistency_index': double.parse(consistencyIndex.toStringAsFixed(2)),
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
  Future<Response<dynamic>> getPreSessionLog(String sessionId) => _dio.get(
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
  Future<Response<dynamic>> getPostSessionLog(String sessionId) => _dio.get(
        'session_post_log',
        queryParameters: {'session_id': 'eq.$sessionId'},
      );

  // ── Psychology module ─────────────────────────────────────────────────────

  /// POST /rest/v1/psychology_scores — inserts ONE row per category.
  ///
  /// Actual table schema: athlete_id, category, score, calculation_logic,
  ///   input_summary (jsonb), interpretation.
  /// Call once per category: focus, confidence, anxiety, motivation,
  ///   resilience, composite.
  Future<Response<dynamic>> createPsychologyScore({
    required String athleteId,
    required String category,
    required double score,
    int answeredQuestions = 0,
  }) {
    final body = <String, dynamic>{
      'athlete_id': athleteId,
      'category': category,
      'score': double.parse(score.toStringAsFixed(2)),
      'calculation_logic': 'assessment_average',
      'input_summary': {'answered_questions': answeredQuestions},
      'interpretation': 'Generated from assessment',
    };
    debugPrint('[PSYCH SCORES] POST psychology_scores '
        'category=$category score=${body['score']} athleteId=$athleteId');
    return _dio.post(
      'psychology_scores',
      data: body,
      options: Options(headers: {'Prefer': 'return=representation'}),
    );
  }

  /// GET /rest/v1/psychology_questions?select=*,psychology_question_options(*)
  Future<Response<dynamic>> getPsychologyQuestions() => _dio.get(
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
  Future<Response<dynamic>> getPsychologyScores(String athleteId) => _dio.get(
        'psychology_scores',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Athlete chat (Saarthi) ────────────────────────────────────────────────

  /// GET /rest/v1/athlete_chat?athlete_id=eq.{id}&order=created_at.desc
  Future<Response<dynamic>> getChatHistory(String athleteId) => _dio.get(
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
  Future<Response<dynamic>> getAthletePhysiology(String athleteId) => _dio.get(
        'athlete_physiology',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'order': 'recorded_date.desc',
        },
      );

  /// POST /rest/v1/athlete_physiology
  Future<Response<dynamic>> saveAthletePhysiology(Map<String, dynamic> data) =>
      _dio.post('athlete_physiology', data: data);

  // ── Performance & AI ──────────────────────────────────────────────────────

  /// GET /rest/v1/performance_summary?athlete_id=eq.{id}&order=created_at.desc
  Future<Response<dynamic>> getPerformanceSummary(String athleteId) => _dio.get(
        'performance_summary',
        queryParameters: {
          'athlete_id': 'eq.$athleteId',
          'order': 'created_at.desc',
        },
      );

  /// GET /rest/v1/ai_insights?athlete_id=eq.{id}
  Future<Response<dynamic>> getAiInsights(String athleteId) => _dio.get(
        'ai_insights',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Tachus / shooting analytics ───────────────────────────────────────────

  /// GET /rest/v1/tachus_reports?athlete_id=eq.{id}
  Future<Response<dynamic>> getTachusReports(String athleteId) => _dio.get(
        'tachus_reports',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Coach ─────────────────────────────────────────────────────────────────

  /// GET /rest/v1/coach_feedback?athlete_id=eq.{id}
  Future<Response<dynamic>> getCoachFeedback(String athleteId) => _dio.get(
        'coach_feedback',
        queryParameters: {'athlete_id': 'eq.$athleteId'},
      );

  // ── Audio library ─────────────────────────────────────────────────────────

  /// GET /rest/v1/audio_library?is_active=eq.true
  Future<Response<dynamic>> getAudioLibrary() => _dio.get(
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

  // ── Mobile backend — Athlete Profile ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/profile
  Future<Response<dynamic>> getMobileAthleteProfile(String athleteId) {
    debugPrint('[PROFILE] GET api/mobile/athletes/$athleteId/profile');
    return _mobileDio.get('api/mobile/athletes/$athleteId/profile');
  }

  /// PUT /api/mobile/athletes/{athleteId}/profile
  Future<Response<dynamic>> updateMobileAthleteProfile({
    required String athleteId,
    String? name,
    int? age,
    String? sportDomain,
    String? experienceLevel,
    String? familySupport,
    List<String>? pressureSources,
    String? goal30,
    String? goal6Month,
  }) {
    debugPrint('[PROFILE UPDATE] PUT api/mobile/athletes/$athleteId/profile');
    return _mobileDio.put(
      'api/mobile/athletes/$athleteId/profile',
      data: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (age != null) 'age': age,
        if (sportDomain != null && sportDomain.isNotEmpty)
          'sport_domain': sportDomain,
        if (experienceLevel != null && experienceLevel.isNotEmpty)
          'experience_level': experienceLevel,
        if (familySupport != null && familySupport.isNotEmpty)
          'family_support': familySupport,
        if (pressureSources != null && pressureSources.isNotEmpty)
          'pressure_sources': pressureSources,
        if (goal30 != null && goal30.isNotEmpty) 'goal_30': goal30,
        if (goal6Month != null && goal6Month.isNotEmpty)
          'goal_6_month': goal6Month,
      },
    );
  }

  // ── Mobile backend — Baseline HR ─────────────────────────────────────────

  /// POST /api/mobile/athletes/{athleteId}/baseline
  /// Saves the resting HR captured by the Polar sensor during the baseline screen.
  Future<Response<dynamic>> saveBaselineHR({
    required String athleteId,
    required int restingHr,
  }) {
    debugPrint('[BASELINE] POST api/mobile/athletes/$athleteId/baseline resting_hr=$restingHr');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/baseline',
      data: {'resting_hr': restingHr},
    );
  }

  // ── Mobile backend — Intake questions ────────────────────────────────────

  /// GET /api/v1/intake/questions
  /// Fetches the assessment questionnaire from the backend for future use.
  Future<Response<dynamic>> getIntakeQuestions() {
    debugPrint('[INTAKE] GET api/v1/intake/questions');
    return _mobileDio.get('api/v1/intake/questions');
  }

  /// POST /api/v1/intake/submit
  /// Submits completed assessment answers and computed scores to mobile backend.
  Future<Response<dynamic>> submitIntakeAnswers({
    required String athleteId,
    required List<Map<String, dynamic>> answers,
    Map<String, double>? scores,
  }) {
    debugPrint('[INTAKE] POST api/v1/intake/submit answers=${answers.length}');
    return _mobileDio.post(
      'api/v1/intake/submit',
      data: {
        'athlete_id': athleteId,
        'answers': answers,
        if (scores != null && scores.isNotEmpty) 'scores': scores,
      },
    );
  }

  // ── Mobile backend — Session Summary ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/sessions/{sessionId}/summary
  Future<Response<dynamic>> getSessionSummary({
    required String athleteId,
    required String sessionId,
  }) {
    debugPrint('[SESSION SUMMARY] GET api/mobile/athletes/$athleteId/sessions/$sessionId/summary');
    return _mobileDio.get(
        'api/mobile/athletes/$athleteId/sessions/$sessionId/summary');
  }

  // ── Mobile backend — Dashboard Home ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/home
  /// Returns live dashboard summary: athlete name, readiness, streak, insights, weekly stats.
  Future<Response<dynamic>> getDashboardHome(String athleteId) {
    debugPrint('[DASHBOARD] GET api/mobile/athletes/$athleteId/home');
    return _mobileDio.get('api/mobile/athletes/$athleteId/home');
  }

  // ── RPC ───────────────────────────────────────────────────────────────────

  /// POST /rest/v1/rpc/get_dashboard_data
  /// TODO(backend): PostgreSQL function must be created in Supabase first.
  /// Returns: {physiology, latest_session, session_summary, performance, insights}
  Future<Response<dynamic>> getDashboardData(String athleteId) => _dio.post(
        'rpc/get_dashboard_data',
        data: {'p_athlete_id': athleteId},
      );
}

// ── Mobile backend auth token injector ───────────────────────────────────────

class _MobileAuthInterceptor extends Interceptor {
  static String? _token;

  static void setToken(String? token) => _token = token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }
}

// ── Request / response logger ─────────────────────────────────────────────────

class _ApiLogger extends Interceptor {
  static const _line = '──────────────────────────────────────────────────────';

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
