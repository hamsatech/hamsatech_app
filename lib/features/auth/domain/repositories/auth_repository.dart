import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneOrEmail);
  Future<UserEntity> verifyOtp(String phoneOrEmail, String otp);
  Future<void> logout();
  UserEntity? getCurrentUser();
}
