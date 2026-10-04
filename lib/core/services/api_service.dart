import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';
import 'storage_service.dart';

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

  /// Invoked exactly once when a session can no longer be recovered (no
  /// refresh token available, or the refresh call itself failed) — after
  /// local auth state has already been cleared. Kept as a plain callback,
  /// not a direct import of the router, so this core service never depends
  /// on `core/router`; wired in `main.dart` to navigate to `/login`.
  static void Function()? onSessionExpired;

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
    dio.interceptors.add(_MobileAuthInterceptor(dio));
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
    debugPrint(
        '[ATHLETE REGISTER] POST api/mobile/athletes/register athleteId=$athleteId');
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

  /// POST https://hamsatech-api.onrender.com/api/v2/auth/phone/send-otp
  /// Triggers Twilio Verify OTP to the given phone number.
  /// Never logs the phone number or the raw response — both are sensitive.
  Future<Response<dynamic>> sendOtpToBackend(String phone) =>
      _mobileDio.post('api/v2/auth/phone/send-otp', data: {'phone': phone});

  /// POST https://hamsatech-api.onrender.com/api/v2/auth/phone/verify-otp
  /// Matches VerifyOTPRequest exactly: { phone_number, otp_code }.
  /// Returns AuthResponse: { access_token, refresh_token, token_type,
  /// expires_in, user_id, is_new_user, next_step }.
  /// Never logs the phone number, OTP code, or the raw response — the
  /// response carries live access/refresh tokens.
  Future<Response<dynamic>> verifyOtpAndRegister({
    required String phone,
    required String otp,
  }) =>
      _mobileDio.post(
        'api/v2/auth/phone/verify-otp',
        data: {'phone_number': phone, 'otp_code': otp},
      );

  // ── Mobile backend — Onboarding (V2) ───────────────────────────────────────

  /// GET api/v2/onboarding
  /// Returns the authenticated athlete's onboarding status
  /// (OnboardingStatusResponse) — current step, completion flag, and
  /// whichever Steps 1-6 fields have already been saved. Requires the
  /// Bearer token set via [setMobileAuthToken].
  Future<Response<dynamic>> getOnboardingStatus() =>
      _mobileDio.get('api/v2/onboarding');

  /// PUT api/v2/onboarding/step-1
  /// Matches OnboardingStep1Request exactly: { fullName, dateOfBirth,
  /// gender, city }. [dateOfBirth] must be an ISO 8601 date ("YYYY-MM-DD").
  /// Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep1({
    required String fullName,
    required String dateOfBirth,
    required String gender,
    required String city,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-1',
        data: {
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'city': city,
        },
      );

  /// GET api/v2/academies
  /// Returns every academy the athlete can choose from during onboarding
  /// Step 2 (a list of AcademyResponse: { academyId, academyName,
  /// location }). Never 404s — an empty list means none exist yet.
  /// Uses a longer per-call receive timeout: this endpoint has been
  /// observed to exceed the default 30s under Render.com cold starts,
  /// which silently emptied the picker (request aborted before the
  /// response arrived, not a parsing bug).
  Future<Response<dynamic>> getAcademies() => _mobileDio.get(
        'api/v2/academies',
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );

  /// PUT api/v2/onboarding/step-2
  /// Matches OnboardingStep2Request exactly: { discipline, experienceLevel,
  /// yearsShooting, academyId }. Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep2({
    required String discipline,
    required String experienceLevel,
    required int yearsShooting,
    required String academyId,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-2',
        data: {
          'discipline': discipline,
          'experienceLevel': experienceLevel,
          'yearsShooting': yearsShooting,
          'academyId': academyId,
        },
      );

  /// PUT api/v2/onboarding/step-3
  /// Matches OnboardingStep3Request exactly: { averagePracticeScore,
  /// targetScore, performanceBlockers, goal30Day, goal6Month }.
  /// Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep3({
    required num averagePracticeScore,
    required num targetScore,
    required List<String> performanceBlockers,
    required String goal30Day,
    required String goal6Month,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-3',
        data: {
          'averagePracticeScore': averagePracticeScore,
          'targetScore': targetScore,
          'performanceBlockers': performanceBlockers,
          'goal30Day': goal30Day,
          'goal6Month': goal6Month,
        },
      );

  /// PUT api/v2/onboarding/step-4
  /// Matches OnboardingStep4Request exactly: { class, schoolName,
  /// academicPerformance }. [schoolClass] maps to the JSON key `class`
  /// (a reserved word in Dart). Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep4({
    required String schoolClass,
    required String schoolName,
    required String academicPerformance,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-4',
        data: {
          'class': schoolClass,
          'schoolName': schoolName,
          'academicPerformance': academicPerformance,
        },
      );

  /// PUT api/v2/onboarding/step-5
  /// Matches OnboardingStep5Request exactly: { dietType,
  /// outsideFoodFrequency, sleepTime, wakeTime }.
  /// Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep5({
    required String dietType,
    required String outsideFoodFrequency,
    required String sleepTime,
    required String wakeTime,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-5',
        data: {
          'dietType': dietType,
          'outsideFoodFrequency': outsideFoodFrequency,
          'sleepTime': sleepTime,
          'wakeTime': wakeTime,
        },
      );

  /// PUT api/v2/onboarding/step-6
  /// Matches OnboardingStep6Request exactly: { friendCircle, angerPattern,
  /// sadnessPattern, reasonForShooting, athleteGoal }.
  /// Returns OnboardingStatusResponse.
  Future<Response<dynamic>> saveOnboardingStep6({
    required String friendCircle,
    required String angerPattern,
    required String sadnessPattern,
    required String reasonForShooting,
    required String athleteGoal,
  }) =>
      _mobileDio.put(
        'api/v2/onboarding/step-6',
        data: {
          'friendCircle': friendCircle,
          'angerPattern': angerPattern,
          'sadnessPattern': sadnessPattern,
          'reasonForShooting': reasonForShooting,
          'athleteGoal': athleteGoal,
        },
      );

  // ── Mobile backend — Psychology Assessment (V2) ─────────────────────────────

  /// GET api/v2/psychology-assessment
  /// Returns AssessmentStatusResponse — totalQuestions, answeredCount,
  /// isComplete, and nextQuestion (the next unanswered question, or null
  /// once complete). Serves Start, Get Progress, Get Next Question, and
  /// Resume — all the same derived read server-side.
  Future<Response<dynamic>> getPsychologyAssessmentStatus() =>
      _mobileDio.get('api/v2/psychology-assessment');

  /// POST api/v2/psychology-assessment/answers
  /// Matches SaveAnswerRequest exactly: { questionNumber, optionCode,
  /// answerText }. Creates or updates the answer for [questionNumber] in
  /// place. Returns AssessmentProgressResponse (totalQuestions,
  /// answeredCount, isComplete only — fetch the next question via
  /// [getPsychologyAssessmentStatus]).
  Future<Response<dynamic>> saveAssessmentAnswer({
    required int questionNumber,
    required String optionCode,
    String? answerText,
  }) =>
      _mobileDio.post(
        'api/v2/psychology-assessment/answers',
        data: {
          'questionNumber': questionNumber,
          'optionCode': optionCode,
          if (answerText != null) 'answerText': answerText,
        },
      );

  /// POST api/v2/psychology-assessment/complete
  /// Requires all 25 questions to already be answered. Returns
  /// AssessmentCompletionResponse — isComplete, categoryScores, insights.
  Future<Response<dynamic>> completeAssessment() =>
      _mobileDio.post('api/v2/psychology-assessment/complete');

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

  /// POST /api/mobile/athletes/{athleteId}/sessions/{sessionId}/score
  /// Persists the session-level score summary (hamsatech.shooting_session_log)
  /// through the authenticated backend — upsert, safe to retry.
  Future<Response<dynamic>> saveScore({
    required String athleteId,
    required String sessionId,
    required int totalShots,
    required double avgScore,
    required double bestSeriesScore,
  }) {
    debugPrint(
        '[SCORE SAVE] POST api/mobile/athletes/$athleteId/sessions/$sessionId/score');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions/$sessionId/score',
      data: {
        'total_shots': totalShots,
        'avg_score': avgScore,
        'best_series_score': bestSeriesScore,
      },
    );
  }

  /// POST /api/mobile/athletes/{athleteId}/sessions/{sessionId}/reflection
  /// Persists the post-session reflection (hamsatech.session_post_log:
  /// mood, what_worked, what_didnt) through the authenticated backend —
  /// upsert, safe to retry.
  Future<Response<dynamic>> saveReflection({
    required String athleteId,
    required String sessionId,
    int? mood,
    String? whatWorked,
    String? whatDidnt,
  }) {
    debugPrint(
        '[REFLECTION SAVE] POST api/mobile/athletes/$athleteId/sessions/$sessionId/reflection');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions/$sessionId/reflection',
      data: {
        'mood': mood,
        'what_worked': whatWorked,
        'what_didnt': whatDidnt,
      },
    );
  }

  /// POST /api/mobile/athletes/{athleteId}/sessions/{sessionId}/complete
  /// Signals session completion to the mobile backend with optional score summary.
  /// All fields except athleteId and sessionId are optional — pass what's available.
  ///
  /// Does NOT accept totalScore or performanceRating (SESSION-2, verified
  /// against the current backend source): neither has a column anywhere —
  /// `total_score` has no destination on hamsatech.sessions or
  /// shooting_session_log (see CompleteSessionRequest's docstring), and the
  /// real hamsatech.session_post_log.performance_rating column carries a
  /// different, already-in-use meaning (see SessionPostLog's docstring), so
  /// writing a client-computed rating into it would silently corrupt
  /// unrelated data rather than just being ignored. Both were previously
  /// sent and always silently dropped server-side — removed rather than
  /// given real columns, since the underlying values are either already
  /// persisted elsewhere (totalShots/avgScore/bestSeriesScore via
  /// saveScore(), individual series via saveSeries()) or, for the mood-based
  /// performanceRating, via saveReflection()'s own `mood` field.
  Future<Response<dynamic>> completeMobileSession({
    required String athleteId,
    required String sessionId,
    int? durationMinutes,
    int? totalShots,
    double? avgScore,
    double? bestSeriesScore,
    String? notes,
  }) {
    debugPrint(
        '[SESSION COMPLETE] POST api/mobile/athletes/$athleteId/sessions/$sessionId/complete');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/sessions/$sessionId/complete',
      data: {
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (totalShots != null) 'total_shots': totalShots,
        if (avgScore != null) 'avg_score': avgScore,
        if (bestSeriesScore != null) 'best_series_score': bestSeriesScore,
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

  /// POST /api/v2/heart-rate/samples — batch upload of buffered live-training
  /// HR samples. Payload: { samples: [{ sessionId, recordedAt, heartRate,
  /// rrInterval }] }.
  Future<Response<dynamic>> uploadHrSamples(Map<String, dynamic> payload) {
    debugPrint('[HR UPLOAD] POST api/v2/heart-rate/samples');
    return _mobileDio.post('api/v2/heart-rate/samples', data: payload);
  }

  // ── Mobile backend — Athlete Profile ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/profile
  Future<Response<dynamic>> getMobileAthleteProfile(String athleteId) {
    debugPrint('[PROFILE] GET api/mobile/athletes/$athleteId/profile');
    return _mobileDio.get('api/mobile/athletes/$athleteId/profile');
  }

  /// PUT /api/mobile/athletes/{athleteId}/profile
  /// Wire payload matches the live `MobileAthleteProfileUpsertInput` schema —
  /// fullName/discipline/experienceLevel/goal30Days/goal6Months, camelCase.
  /// [familySupport] and [pressureSources] have no server-side field under
  /// any name and are intentionally not sent; the parameters are kept so
  /// existing callers (profile screen, onboarding repository) don't break.
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
        if (name != null && name.isNotEmpty) 'fullName': name,
        if (age != null) 'age': age,
        if (sportDomain != null && sportDomain.isNotEmpty)
          'discipline': sportDomain,
        if (experienceLevel != null && experienceLevel.isNotEmpty)
          'experienceLevel': experienceLevel,
        if (goal30 != null && goal30.isNotEmpty) 'goal30Days': goal30,
        if (goal6Month != null && goal6Month.isNotEmpty)
          'goal6Months': goal6Month,
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
    debugPrint(
        '[BASELINE] POST api/mobile/athletes/$athleteId/baseline resting_hr=$restingHr');
    return _mobileDio.post(
      'api/mobile/athletes/$athleteId/baseline',
      data: {'resting_hr': restingHr},
    );
  }

  /// GET /api/mobile/athletes/{athleteId}/baseline
  /// Reads back the athlete's most recently captured physiological baseline.
  Future<Response<dynamic>> getBaselineHR(String athleteId) {
    debugPrint('[BASELINE] GET api/mobile/athletes/$athleteId/baseline');
    return _mobileDio.get('api/mobile/athletes/$athleteId/baseline');
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

  // ── Mobile backend — Session Report ──────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/sessions/{sessionId}/report
  /// Returns the full aggregated report for one session: session metadata
  /// (type/started_at/completed_at/duration_seconds), a heart-rate summary,
  /// a score summary, the saved series list, and the reflection — each
  /// category null/empty when nothing was saved for it. Replaces the old
  /// `/summary` path, which never existed server-side.
  Future<Response<dynamic>> getSessionReport({
    required String athleteId,
    required String sessionId,
  }) {
    debugPrint(
        '[SESSION REPORT] GET api/mobile/athletes/$athleteId/sessions/$sessionId/report');
    return _mobileDio
        .get('api/mobile/athletes/$athleteId/sessions/$sessionId/report');
  }

  // ── Mobile backend — Session History ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/sessions
  /// Returns one page of the athlete's completed sessions, newest first, as
  /// the project's standard `PaginatedResponse` envelope:
  /// `{ success, data: [ {session_id, session_type, start_time, end_time,
  /// duration_seconds, avg_score, best_series_score, total_shots,
  /// series_count} ], meta: {total, page, page_size, total_pages} }`.
  Future<Response<dynamic>> getSessionHistory({
    required String athleteId,
    int page = 1,
    int pageSize = 20,
  }) {
    debugPrint(
        '[SESSION HISTORY] GET api/mobile/athletes/$athleteId/sessions page=$page pageSize=$pageSize');
    return _mobileDio.get(
      'api/mobile/athletes/$athleteId/sessions',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
  }

  // ── Mobile backend — Session Heart Rate ──────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/sessions/{sessionId}/heart-rate
  /// Returns aggregated, chart-ready HR for a session: sample_count,
  /// avg_hr/min_hr/max_hr (null if no samples), and a downsampled points list.
  Future<Response<dynamic>> getSessionHeartRate({
    required String athleteId,
    required String sessionId,
  }) {
    debugPrint(
        '[SESSION HR] GET api/mobile/athletes/$athleteId/sessions/$sessionId/heart-rate');
    return _mobileDio
        .get('api/mobile/athletes/$athleteId/sessions/$sessionId/heart-rate');
  }

  // ── Mobile backend — Dashboard Home ─────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/home
  /// Returns live dashboard summary: athlete name, readiness, streak, insights, weekly stats.
  Future<Response<dynamic>> getDashboardHome(String athleteId) {
    debugPrint('[DASHBOARD] GET api/mobile/athletes/$athleteId/home');
    return _mobileDio.get('api/mobile/athletes/$athleteId/home');
  }

  // ── Mobile backend — Streak ──────────────────────────────────────────────

  /// GET /api/mobile/athletes/{athleteId}/streak
  /// Returns `{athlete_id, current_streak, longest_streak, last_active_date}`
  /// — real, derived from persisted completed sessions, never a local
  /// calculation. Replaces the two independent local streak calculations
  /// previously in DashboardRepositoryImpl and ProfileScreen.
  Future<Response<dynamic>> getStreak(String athleteId) {
    debugPrint('[STREAK] GET api/mobile/athletes/$athleteId/streak');
    return _mobileDio.get('api/mobile/athletes/$athleteId/streak');
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

// ── Mobile backend auth token injector + 401 refresh-and-retry ──────────────
//
// On a 401 from any mobile-backend request (except the auth endpoints
// themselves, which must never trigger this): attempt exactly one token
// refresh, retry the original request exactly once with the new token, and
// if either the refresh or the retry fails, clear local auth state and hand
// off to [ApiService.onSessionExpired] so the app can route to login.
// Concurrent 401s share one in-flight refresh instead of each firing their
// own. Never logs token contents, request bodies, or raw auth responses.
class _MobileAuthInterceptor extends Interceptor {
  _MobileAuthInterceptor(this._dio);

  final Dio _dio;

  static String? _token;

  // Requests to these paths must never trigger a refresh attempt: the OTP
  // endpoints run before any session exists, and excluding the refresh
  // endpoint itself is defense-in-depth against recursion (the refresh call
  // is also issued on a bare, interceptor-free Dio — see [_refresh]).
  static const _authPaths = [
    'api/v2/auth/refresh',
    'api/v2/auth/phone/send-otp',
    'api/v2/auth/phone/verify-otp',
  ];

  // Shared by every concurrent 401 so only one refresh call is ever
  // in flight at a time; cleared once that call resolves.
  static Future<String?>? _refreshInFlight;

  static void setToken(String? token) {
    _token = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isAuthPath = _authPaths.any((path) => options.path.contains(path));
    final alreadyRetried = options.extra['retriedAfter401'] == true;

    if (err.response?.statusCode != 401 || isAuthPath || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newToken = await (_refreshInFlight ??= _refresh());
    _refreshInFlight = null;

    if (newToken == null) {
      await _forceLogout();
      handler.next(err);
      return;
    }

    try {
      options.extra['retriedAfter401'] = true;
      options.headers['Authorization'] = 'Bearer $newToken';
      final retried = await _dio.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Exchanges the stored refresh token for a new access/refresh pair and
  /// persists both. Returns null — never throws — if there is no refresh
  /// token to use, or the exchange itself fails for any reason; either way
  /// the caller must treat the session as unrecoverable without a fresh
  /// login. Uses a bare Dio (no interceptors) so a failing refresh call can
  /// never re-enter this interceptor's own `onError`.
  static Future<String?> _refresh() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.mobileApiBaseUrl,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await refreshDio.post<Map<String, dynamic>>(
        'api/v2/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final body = response.data;
      final newAccessToken = body?['access_token'] as String?;
      final newRefreshToken = body?['refresh_token'] as String?;
      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        return null;
      }

      await SecureStorageService.saveAuthToken(newAccessToken);
      await SecureStorageService.saveRefreshToken(newRefreshToken);
      await StorageService.saveAuthToken(newAccessToken);
      _token = newAccessToken;
      return newAccessToken;
    } on DioException {
      return null;
    }
  }

  static Future<void> _forceLogout() async {
    await StorageService.clearAll();
    await SecureStorageService.clearAll();
    _token = null;
    ApiService.onSessionExpired?.call();
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
