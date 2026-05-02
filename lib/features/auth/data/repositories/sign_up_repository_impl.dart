import '../../domain/repositories/sign_up_repository.dart';

class SignUpRepositoryImpl implements ISignUpRepository {
  const SignUpRepositoryImpl();

  @override
  Future<void> initiateGoogleSignUp() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: integrate Google Sign-In SDK
  }

  @override
  Future<void> initiateAppleSignUp() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: integrate Apple Sign-In SDK
  }
}
