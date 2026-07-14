import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> sendOtp(String phoneOrEmail) async {
    debugPrint('[OTP SEND] initiating OTP for phone=$phoneOrEmail');
    try {
      await ApiService.instance.sendOtpToBackend(phoneOrEmail);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<UserEntity> verifyOtp(String phoneOrEmail, String otp) async {
    debugPrint('[OTP VERIFY] phone=$phoneOrEmail');
    try {
      final res = await ApiService.instance.verifyOtpAndRegister(
        phone: phoneOrEmail,
        otp: otp,
      );
      debugPrint('[OTP VERIFY] raw response: ${res.data}');

      final parsed = AuthResponseModel.fromJson(
        res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : <String, dynamic>{},
      );

      if (!parsed.success || parsed.athleteId.isEmpty) {
        throw Exception(
            'Verification failed — no athlete ID returned from server.');
      }

      debugPrint('[OTP VERIFY] success athleteId=${parsed.athleteId}');

      // The live PhoneOtpVerifyResponse has no token field — athleteId is
      // the only identifier the backend gives us, so it doubles as the
      // bearer value for subsequent mobile backend calls.
      final token = parsed.athleteId;

      // Persist to secure storage (Keychain / Keystore) — authoritative store.
      await SecureStorageService.saveAthleteId(parsed.athleteId);
      await SecureStorageService.savePhone(phoneOrEmail);
      await SecureStorageService.saveAuthToken(token);

      // Mirror into SharedPreferences so all synchronous StorageService
      // reads continue to work without refactoring call-sites.
      await StorageService.saveAthleteId(parsed.athleteId);
      await StorageService.saveAuthToken(token);

      // Prime the in-memory token cache so the very next mobile backend
      // request already carries the Authorization header.
      ApiService.setMobileAuthToken(token);

      // registerAthlete() is intentionally NOT called from here. The live
      // MobileAthleteRegistrationInput requires fullName/email/age/gender,
      // none of which are known at this point — the OTP screen only
      // collects phone+otp. Calling it with placeholder values would send
      // fabricated data and still fail the backend's required-field
      // validation. Wiring this call in requires a product decision on
      // where those fields get collected (see task report).

      final user = UserModel(
        id: parsed.athleteId,
        phoneOrEmail: phoneOrEmail,
        token: token,
      );
      await StorageService.saveUserProfile(user.toJson());
      return user;
    } on DioException catch (e) {
      debugPrint('[OTP VERIFY] DioException: $e');
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    await StorageService.clearAuth();
    await SecureStorageService.clearAll();
    ApiService.setMobileAuthToken(null);
  }

  @override
  UserEntity? getCurrentUser() {
    final json = StorageService.getUserProfile();
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> getAthleteProfile(String athleteId) async {
    debugPrint('[PROFILE] GET profile athleteId=$athleteId');
    try {
      final res = await ApiService.instance.getMobileAthleteProfile(athleteId);
      final raw = res.data;
      // MobileAthleteProfileResponse wraps the record as { "profile": {...} }.
      if (raw is Map<String, dynamic>) {
        return raw['profile'] is Map<String, dynamic>
            ? raw['profile'] as Map<String, dynamic>
            : raw;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> updateAthleteProfile(
    String athleteId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('[PROFILE] PUT profile athleteId=$athleteId');
    try {
      await ApiService.instance.updateMobileAthleteProfile(
        athleteId: athleteId,
        name: updates['name'] as String?,
        age: updates['age'] is int ? updates['age'] as int : null,
        sportDomain: updates['sport_domain'] as String?,
        experienceLevel: updates['experience_level'] as String?,
        familySupport: updates['family_support'] as String?,
        pressureSources: updates['pressure_sources'] is List
            ? List<String>.from(updates['pressure_sources'] as List)
            : null,
        goal30: updates['goal_30'] as String?,
        goal6Month: updates['goal_6_month'] as String?,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Extracts a human-readable error message from a DioException.
  /// Handles FastAPI's { "detail": "..." } shape and common variants.
  static String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // FastAPI HTTP exception: { "detail": "message" }
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;

      // FastAPI validation error: { "detail": [{ "msg": "..." }] }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) {
          return first['msg']?.toString() ?? 'Validation error';
        }
      }

      // Custom error shapes
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }

    if (data is String && data.isNotEmpty) return data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please try again.';
      case 404:
        return 'Service unavailable. Please try again later.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
