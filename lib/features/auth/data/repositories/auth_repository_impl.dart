import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  // In production this would call an API. We simulate OTP with a fixed code.
  static const _validOtp = '1234';

  @override
  Future<void> sendOtp(String phoneOrEmail) async {
    await Future.delayed(const Duration(seconds: 1));
    // Production: POST /auth/send-otp with phoneOrEmail
  }

  @override
  Future<UserEntity> verifyOtp(String phoneOrEmail, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp != _validOtp) {
      throw Exception('Invalid OTP. Please try again.');
    }
    final user = UserModel(
      id: const Uuid().v4(),
      phoneOrEmail: phoneOrEmail,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await StorageService.saveAuthToken(user.token);
    await StorageService.saveUserProfile(user.toJson());
    return user;
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
