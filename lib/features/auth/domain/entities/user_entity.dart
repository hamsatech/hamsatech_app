import 'package:equatable/equatable.dart';

/// Where the client should route to after authentication, mirroring the
/// backend's `OnboardingStatus` enum. Always trust this over any local flag.
enum AuthNextStep {
  home,
  onboardingStep1;

  static AuthNextStep fromApi(String value) {
    switch (value) {
      case 'HOME':
        return AuthNextStep.home;
      case 'ONBOARDING_STEP_1':
        return AuthNextStep.onboardingStep1;
      default:
        return AuthNextStep.onboardingStep1;
    }
  }

  String toApi() => this == AuthNextStep.home ? 'HOME' : 'ONBOARDING_STEP_1';
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phoneOrEmail,
    required this.token,
    required this.isNewUser,
    required this.nextStep,
  });

  final String id;
  final String phoneOrEmail;
  final String token;
  final bool isNewUser;
  final AuthNextStep nextStep;

  @override
  List<Object?> get props => [id, phoneOrEmail, token, isNewUser, nextStep];
}
