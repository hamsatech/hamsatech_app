import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/auth/data/repositories/auth_repository_impl.dart';

/// Regression coverage for the "stale identity after logout" bug: the
/// Dashboard's logout button used to call `StorageService.clearAuth()`
/// directly, which removes only the auth-token-related keys and leaves
/// `athlete_profile` / `supabase_athlete_id` / other athlete-specific state
/// cached — so a different athlete logging in afterward on the same device
/// could briefly see the previous athlete's data. Both logout entry points
/// (Dashboard and Profile) now funnel through `AuthRepositoryImpl.logout()`,
/// so this test locks down that a single call there clears everything.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final secureChannelCalls = <MethodCall>[];

  setUp(() async {
    secureChannelCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      secureChannelCalls.add(call);
      return null;
    });
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
  });

  test(
    'logout() clears the auth token, athlete_id, athlete_profile and all '
    'other cached athlete-specific local state — not just the auth-only keys',
    () async {
      // Seed local state the way a real logged-in session leaves it.
      await StorageService.saveAuthToken('jwt-token');
      await StorageService.saveAthleteId('ASA001');
      await StorageService.saveAthleteProfile({'name': 'Test Athlete'});
      await StorageService.saveBaselineScores({'resting_hr': 62.0});
      await StorageService.saveSessionId('session-123');
      await StorageService.setOnboardingComplete(true);

      await AuthRepositoryImpl().logout();

      expect(StorageService.getAuthToken(), isNull);
      expect(StorageService.getAthleteId(), isNull,
          reason: 'supabase_athlete_id must not survive logout');
      expect(StorageService.getAthleteProfile(), isNull,
          reason: 'athlete_profile must not survive logout');
      expect(StorageService.getBaselineScores(), isNull);
      expect(StorageService.getSessionId(), isNull);
      expect(StorageService.isOnboardingComplete(), isFalse);
    },
  );

  test(
    'logout() also clears every key in the encrypted Keychain/Keystore store',
    () async {
      await AuthRepositoryImpl().logout();

      final deletedKeys = secureChannelCalls
          .where((call) => call.method == 'delete')
          .map((call) => (call.arguments as Map)['key'] as String)
          .toSet();

      expect(
        deletedKeys,
        {'sec_athlete_id', 'sec_auth_token', 'sec_refresh_token', 'sec_phone'},
      );
    },
  );
}
