import '../../domain/repositories/sign_up_repository.dart';

class SignUpViewModel {
  const SignUpViewModel(this._repository);

  final ISignUpRepository _repository;

  static const String screenTitle = 'Sign Up';
  static const String welcomeTitle = 'Meet Astra';
  static const String welcomeSubtitle =
      'Understanding what drives outcomes—from performance to relationships to daily life.';
  static const String continueLabel = 'Continue';
  static const String googleLabel = 'Continue with Google';
  static const String appleLabel = 'Continue with Apple';
  static const String privacyPrefix =
      'We collect personal information from you to customize your ASTRA '
      'experience and for other purposes. Learn more about how we use your '
      'data, your choices, and your rights in our ';
  static const String privacyLinkLabel = 'Privacy Policy';
  static const String orDividerLabel = 'OR';

  Future<void> signUpWithGoogle() => _repository.initiateGoogleSignUp();
  Future<void> signUpWithApple() => _repository.initiateAppleSignUp();
}
