import 'storage_service.dart';

/// Centralized athlete ID resolution for all Supabase API calls.
///
/// Priority order:
///   1. `supabase_athlete_id` — UUID written after the athletes POST during
///      onboarding. This is the canonical, server-issued ID.
///   2. `athlete_profile['athlete_id']` — legacy fallback; populated if an
///      athlete row was fetched via AthleteBloc before onboarding finished.
///   3. `user_profile['phoneOrEmail']` — last-resort text identifier used
///      as athlete_id for sessions created before onboarding finishes.
///
/// Returns `null` when no ID can be resolved (onboarding incomplete or
/// cleared). Callers that REQUIRE an ID should redirect to onboarding:
///
///   final id = AuthHelper.getCurrentAthleteId();
///   if (id == null) { context.go('/onboarding'); return; }
class AuthHelper {
  AuthHelper._();

  static String? getCurrentAthleteId() {
    // 1 — Server-issued Supabase UUID (primary)
    final supabaseId = StorageService.getAthleteId();
    if (supabaseId != null && supabaseId.isNotEmpty) return supabaseId;

    // 2 — athlete_profile map may carry an ID if fetched from the API
    final profile = StorageService.getAthleteProfile();
    final profileId = profile?['athlete_id'] as String?;
    if (profileId != null && profileId.isNotEmpty) return profileId;

    // 3 — phone / email as last-resort text identifier
    final user = StorageService.getUserProfile();
    final phoneOrEmail = user?['phoneOrEmail'] as String?;
    if (phoneOrEmail != null && phoneOrEmail.isNotEmpty) return phoneOrEmail;

    return null;
  }
}
