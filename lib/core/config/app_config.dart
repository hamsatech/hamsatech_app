/// App-wide configuration injected at build time via --dart-define.
///
/// Run with overrides:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://... \
///     --dart-define=SUPABASE_ANON_KEY=eyJ... \
///     --dart-define=MOBILE_API_BASE_URL=https://...
///
/// When a --dart-define is omitted the current production values are used as
/// defaults so the app runs out of the box in development.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pjjkjnofislpdckjixtg.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqamtqbm9maXNscGRja2ppeHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNDIxNzUsImV4cCI6MjA5MDcxODE3NX0.7MgVLFScjw0xY5j8c3Uug74MG1WYhzoC5_F_ccPqOiU',
  );

  /// Base URL for the custom mobile backend (OTP, registration, onboarding).
  /// Must end with a trailing slash.
  static const String mobileApiBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'https://hamsatech-api.onrender.com/',
  );

  /// Full Supabase REST v1 base URL (trailing slash required for Dio).
  static const String supabaseRestBaseUrl = '$supabaseUrl/rest/v1/';
}
