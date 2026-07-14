import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneOrEmail);
  Future<UserEntity> verifyOtp(String phoneOrEmail, String otp);
  Future<void> logout();
  UserEntity? getCurrentUser();

  /// Fetches the athlete's full profile from the mobile backend.
  Future<Map<String, dynamic>> getAthleteProfile(String athleteId);

  /// Updates athlete profile fields on the mobile backend.
  /// Only non-null values in [updates] are sent.
  Future<void> updateAthleteProfile(
    String athleteId,
    Map<String, dynamic> updates,
  );
}
