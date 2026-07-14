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
