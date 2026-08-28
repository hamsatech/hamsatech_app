/// Parsed response from POST /api/v2/auth/phone/verify-otp.
///
/// Matches the live OpenAPI `AuthResponse` schema exactly:
///   { access_token, refresh_token, token_type, expires_in, user_id,
///     is_new_user, next_step }
/// `next_step` is the backend's authoritative routing instruction — the
/// client must not re-derive it from local state.
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.isNewUser,
    required this.nextStep,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final bool isNewUser;

  /// Raw `OnboardingStatus` enum value: "HOME" or "ONBOARDING_STEP_1".
  final String nextStep;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] as int,
      userId: json['user_id'] as String,
      isNewUser: json['is_new_user'] as bool,
      nextStep: json['next_step'] as String,
    );
  }
}
