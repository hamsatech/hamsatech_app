import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value store for sensitive auth credentials.
///
/// Uses Keychain on iOS and AES/RSA via Android Keystore on Android.
/// All operations are async — call [restoreToCache] in main() after
/// StorageService.init() so synchronous StorageService reads still work.
class SecureStorageService {
  static const FlutterSecureStorage _store = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kAthleteId = 'sec_athlete_id';
  static const _kAuthToken = 'sec_auth_token';
  static const _kPhone = 'sec_phone';

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> saveAthleteId(String id) =>
      _store.write(key: _kAthleteId, value: id);

  static Future<void> saveAuthToken(String token) =>
      _store.write(key: _kAuthToken, value: token);

  static Future<void> savePhone(String phone) =>
      _store.write(key: _kPhone, value: phone);

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<String?> getAthleteId() => _store.read(key: _kAthleteId);

  static Future<String?> getAuthToken() => _store.read(key: _kAuthToken);

  static Future<String?> getPhone() => _store.read(key: _kPhone);

  // ── Delete ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _store.delete(key: _kAthleteId);
    await _store.delete(key: _kAuthToken);
    await _store.delete(key: _kPhone);
  }
}
