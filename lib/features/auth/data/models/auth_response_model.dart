/// Parsed response from POST /api/v1/auth/phone/verify-otp.
///
/// Matches the live OpenAPI contract exactly — `PhoneOtpVerifyResponse` is:
///   { "athleteId": "string", "success": true }
/// No token, no isNewUser, no envelope. Do not add fields here that aren't
/// in that schema.
class AuthResponseModel {
  const AuthResponseModel({
    required this.athleteId,
    required this.success,
  });

  final String athleteId;
  final bool success;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      athleteId: (json['athleteId'] ?? '').toString().trim(),
      success: json['success'] == true,
    );
  }
}
