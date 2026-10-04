import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await StorageService.init();
  // A session that can't be recovered (401 with no usable refresh token, or
  // the refresh call itself failing) is signaled here rather than the auth
  // interceptor importing the router directly — see ApiService.onSessionExpired.
  ApiService.onSessionExpired = () => AppRouter.router.go('/login');
  await _restoreSecureSession();
  setupDI();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

/// Restores encrypted credentials from the Keychain/Keystore back into
/// SharedPreferences so all synchronous StorageService reads remain valid
/// (e.g. after an app reinstall that cleared SharedPreferences but kept
/// the Keychain entry intact).
Future<void> _restoreSecureSession() async {
  final token = await SecureStorageService.getAuthToken();
  final secureAthleteId = await SecureStorageService.getAthleteId();
  final cachedAthleteId = StorageService.getAthleteId();

  final plan = planSecureSessionRestore(
    secureToken: token,
    secureAthleteId: secureAthleteId,
    cachedAthleteId: cachedAthleteId,
  );

  // The JWT is saved to secure storage unconditionally on login
  // (AuthRepositoryImpl.verifyOtp), independent of whether the best-effort
  // athlete_id sync that follows it succeeds. Restoring the token into the
  // mobile-auth interceptor must never be gated on athlete_id being
  // present — otherwise a single failed sync leaves every subsequent
  // mobile-backend request silently unauthenticated after a cold start.
  if (!plan.shouldSetToken) return;
  ApiService.setMobileAuthToken(token);

  // Back-fill SharedPreferences if it was wiped, when we already know the
  // athlete_id.
  if (plan.shouldBackfillAthleteId) {
    await StorageService.saveAthleteId(secureAthleteId!);
  }

  // Self-healing, non-blocking: an already-authenticated session may have
  // no athlete_id persisted yet (a prior sync failed) or a stale one.
  // Re-resolve it from the existing JWT-authenticated onboarding-status
  // endpoint in the background — intentionally not awaited, so it never
  // delays startup.
  _syncStoredAthleteId();
}

/// Pure decision logic behind [_restoreSecureSession], extracted so the
/// restore behavior can be unit-tested without touching the
/// Keychain/Keystore or SharedPreferences.
@visibleForTesting
class SecureSessionRestorePlan {
  final bool shouldSetToken;
  final bool shouldBackfillAthleteId;

  const SecureSessionRestorePlan({
    required this.shouldSetToken,
    required this.shouldBackfillAthleteId,
  });
}

@visibleForTesting
SecureSessionRestorePlan planSecureSessionRestore({
  required String? secureToken,
  required String? secureAthleteId,
  required String? cachedAthleteId,
}) {
  final hasToken = secureToken != null && secureToken.isNotEmpty;
  final hasSecureAthleteId =
      secureAthleteId != null && secureAthleteId.isNotEmpty;
  return SecureSessionRestorePlan(
    shouldSetToken: hasToken,
    shouldBackfillAthleteId:
        hasToken && hasSecureAthleteId && cachedAthleteId == null,
  );
}

/// Refreshes the persisted athlete_id from the existing onboarding-status
/// endpoint. Non-fatal: on any failure the next successful login or app
/// restart will retry.
Future<void> _syncStoredAthleteId() async {
  try {
    final res = await ApiService.instance.getOnboardingStatus();
    final data = res.data;
    final athleteId =
        data is Map<String, dynamic> ? data['athlete_id'] as String? : null;
    if (athleteId == null || athleteId.isEmpty) return;
    await SecureStorageService.saveAthleteId(athleteId);
    await StorageService.saveAthleteId(athleteId);
  } catch (_) {
    // Non-fatal — see doc comment above.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ASTRA',
      theme: DSTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
