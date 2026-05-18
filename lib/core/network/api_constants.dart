/// Single source of truth for all API-related constants.
///
/// Replace the placeholder credential strings with real values from:
///   Supabase Dashboard → Project Settings → API
class ApiConstants {
  ApiConstants._();

  // ── Supabase credentials ──────────────────────────────────────────────────
  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';

  // ── Base URLs ─────────────────────────────────────────────────────────────
  static const String baseUrl = '$supabaseUrl/rest/v1';
  static const String rpcBaseUrl = '$supabaseUrl/rest/v1/rpc';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 10);

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String athletes = '/athletes';
  // Add feature endpoints here as new modules are built.
}
