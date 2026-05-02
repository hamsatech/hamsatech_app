abstract class ISignUpRepository {
  Future<void> initiateGoogleSignUp();
  Future<void> initiateAppleSignUp();
}
