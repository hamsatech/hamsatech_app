import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> sendOtp(String phoneOrEmail) async {
    debugPrint('[OTP SEND API] initiating OTP for phone=$phoneOrEmail');
    try {
      await ApiService.instance.sendOtpToBackend(phoneOrEmail);
      debugPrint('[OTP SEND API] OTP dispatched successfully via backend');
    } catch (e) {
      debugPrint('[AUTH ERROR] sendOtp failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> verifyOtp(String phoneOrEmail, String otp) async {
    debugPrint('[OTP VERIFY API] verifying OTP for phone=$phoneOrEmail');
    try {
      final res = await ApiService.instance.verifyOtpAndRegister(
        phone: phoneOrEmail,
        otp: otp,
      );
      debugPrint('[OTP VERIFY API] raw response: ${res.data}');

      final athleteId = _extractAthleteId(res.data);
      if (athleteId == null || athleteId.isEmpty) {
        throw Exception(
            'Verification failed — no athleteId returned from server.');
      }

      debugPrint('[AUTH SUCCESS] athleteId=$athleteId');
      await StorageService.saveAthleteId(athleteId);
      debugPrint('[ATHLETE ID SAVED] $athleteId stored as supabase_athlete_id');

      final user = UserModel(
        id: athleteId,
        phoneOrEmail: phoneOrEmail,
        token: athleteId,
      );
      await StorageService.saveAuthToken(user.token);
      await StorageService.saveUserProfile(user.toJson());
      return user;
    } catch (e) {
      debugPrint('[AUTH ERROR] verifyOtp failed: $e');
      rethrow;
    }
  }

  String? _extractAthleteId(dynamic data) {
    if (data is Map) return data['athleteId']?.toString();
    if (data is List && data.isNotEmpty) {
      return (data.first as Map?)?['athleteId']?.toString();
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await StorageService.clearAuth();
  }

  @override
  UserEntity? getCurrentUser() {
    final json = StorageService.getUserProfile();
    if (json == null) return null;
    return UserModel.fromJson(json);
  }
}
