import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Centralized athlete ID resolution for all Supabase API calls.
///
/// Priority order:
///   1. `supabase_athlete_id` — written by onboarding after POST /athletes
///      returns the server-issued ID (e.g. "ASA006").
///   2. `athlete_profile['athlete_id']` — fallback if fetched separately.
///
/// Returns `null` when no real athlete_id is stored yet.
/// Callers already guard against null by skipping the API call — this is
/// intentional: sending a phone number as athlete_id causes FK violations.
class AuthHelper {
  AuthHelper._();

  static String? getCurrentAthleteId() {
    // 1 — Server-issued ID stored after POST /athletes during onboarding.
    final storedId = StorageService.getAthleteId();
    if (storedId != null && storedId.isNotEmpty) {
      debugPrint('[AUTH HELPER] athlete_id loaded from storage: $storedId');
      return storedId;
    }

    // 2 — athlete_profile map may carry an ID if fetched from the API.
    final profile = StorageService.getAthleteProfile();
    final profileId = profile?['athlete_id'] as String?;
    if (profileId != null && profileId.isNotEmpty) {
      debugPrint('[AUTH HELPER] athlete_id from profile map: $profileId');
      return profileId;
    }

    // Phone number is intentionally NOT used as a fallback — it is not a
    // valid athlete_id and causes FK constraint failures on the backend.
    debugPrint('[AUTH HELPER] no athlete_id found — POST /athletes may be pending');
    return null;
  }
}
