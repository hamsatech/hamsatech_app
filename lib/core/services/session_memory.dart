/// Lightweight runtime store for the active session_id returned by Supabase.
///
/// Persists only for the lifetime of the app process.
/// Replace with secure storage when full auth is wired up.
class SessionMemory {
  SessionMemory._();

  static String? sessionId;

  static void clear() => sessionId = null;
}
