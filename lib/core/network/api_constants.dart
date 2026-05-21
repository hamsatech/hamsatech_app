class ApiConstants {
  ApiConstants._();

  // ── Supabase credentials ──────────────────────────────────────────────────
  static const String supabaseUrl =
      'https://pjjkjnofislpdckjixtg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqamtqbm9maXNscGRja2ppeHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNDIxNzUsImV4cCI6MjA5MDcxODE3NX0.7MgVLFScjw0xY5j8c3Uug74MG1WYhzoC5_F_ccPqOiU';

  // ── Base URLs ─────────────────────────────────────────────────────────────
  static const String baseUrl = '$supabaseUrl/rest/v1/';
  static const String rpcBaseUrl = '$supabaseUrl/rest/v1/rpc/';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Auth tables ───────────────────────────────────────────────────────────
  // App_Sessions stores auth session tokens (session_token, user_email, expires_at).
  // It is NOT the training sessions table.
  static const String appSessions = 'App_Sessions';
  static const String appUsers = 'App_Users';
  // users table: uid, phone_number, role, created_at, last_login_at
  static const String users = 'users';

  // ── Training sessions ─────────────────────────────────────────────────────
  // sessions: session_id (uuid PK), athlete_id, session_type, start_time, end_time
  static const String sessions = 'sessions';
  // session_pre_log: energy_level, readiness_score, mental_state, feeling_rating, mental_tags…
  static const String sessionPreLog = 'session_pre_log';
  // session_post_log: focus_level, focus_area, session_duration, performance_rating, challenges, coach_feedback
  static const String sessionPostLog = 'session_post_log';
  // session_summary: computed HR/ACC metrics after session
  static const String sessionSummary = 'session_summary';

  // ── Athletes ──────────────────────────────────────────────────────────────
  static const String athletes = 'athletes';
  static const String athleteDetails = 'athlete_details';
  static const String athleteFamily = 'athlete_family';
  static const String athleteChat = 'athlete_chat';
  // athlete_physiology: resting_hr, avg_hr, spo2, sleep_hours, recovery_score, stress_score
  static const String athletePhysiology = 'athlete_physiology';

  // ── Psychology module ─────────────────────────────────────────────────────
  static const String psychologyQuestions = 'psychology_questions';
  static const String psychologyQuestionOptions = 'psychology_question_options';
  static const String psychologyResponses = 'psychology_responses';
  static const String psychologyScores = 'psychology_scores';

  // ── Performance & AI ──────────────────────────────────────────────────────
  static const String performanceSummary = 'performance_summary';
  static const String aiInsights = 'ai_insights';
  static const String insightLibrary = 'insight_library';
  // Shooting-specific analytics (Tachus device + manual score entry)
  static const String shootingSessionLog = 'shooting_session_log';
  static const String tachusReports = 'tachus_reports';

  // ── Coach ─────────────────────────────────────────────────────────────────
  static const String coachFeedback = 'coach_feedback';
  static const String coaches = 'coaches';
  static const String coachAssignments = 'coach_assignments';
  static const String assignmentRequests = 'assignment_requests';
  static const String feedbackRequests = 'feedback_requests';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String academies = 'academies';

  // ── Device streams (bulk write only, not for UI reads) ───────────────────
  static const String hrStream = 'hr_stream';
  static const String ecgStream = 'ecg_stream';
  static const String accStream = 'acc_stream';
  // polar_credentials: polar_user_id, polar_access_token, polar_member_id
  static const String polarCredentials = 'polar_credentials';

  // ── Content ───────────────────────────────────────────────────────────────
  static const String audioLibrary = 'audio_library';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = 'notifications';

  // ── RPC functions ─────────────────────────────────────────────────────────
  // TODO(backend): Create this PostgreSQL function in Supabase before calling.
  // Returns: {physiology, latest_session, session_summary, performance, insights}
  static const String rpcGetDashboardData = 'get_dashboard_data';
  // TODO(backend): Create this view or RPC before calling.
  static const String rpcGetSessionFullData = 'get_session_full_data';
}
