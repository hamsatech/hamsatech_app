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
  final athleteId = await SecureStorageService.getAthleteId();
  if (athleteId == null || athleteId.isEmpty) return;

  // Back-fill SharedPreferences if it was wiped.
  if (StorageService.getAthleteId() == null) {
    await StorageService.saveAthleteId(athleteId);
  }

  // Prime the in-memory token so the first mobile backend request after
  // a cold start already carries the Authorization header.
  final token = await SecureStorageService.getAuthToken();
  if (token != null && token.isNotEmpty) {
    ApiService.setMobileAuthToken(token);

    // Self-healing, non-blocking: an already-authenticated session may
    // have an athlete_id persisted before the auth flow correctly
    // resolved it (see AuthRepositoryImpl._syncAthleteId). Refresh it from
    // the existing JWT-authenticated onboarding-status endpoint in the
    // background — intentionally not awaited, so it never delays startup.
    _syncStoredAthleteId();
  }
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
