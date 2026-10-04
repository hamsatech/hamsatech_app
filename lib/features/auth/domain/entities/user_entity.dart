import 'package:equatable/equatable.dart';

/// Where the client should route to after authentication, mirroring the
/// backend's `OnboardingStatus` enum. Always trust this over any local flag.
enum AuthNextStep {
  home,
  onboardingStep1,
  onboardingStep2,
  onboardingStep3,
  onboardingStep4,
  onboardingStep5,
  onboardingStep6;

  static AuthNextStep fromApi(String value) {
    switch (value) {
      case 'HOME':
        return AuthNextStep.home;
      case 'ONBOARDING_STEP_1':
        return AuthNextStep.onboardingStep1;
      case 'ONBOARDING_STEP_2':
        return AuthNextStep.onboardingStep2;
      case 'ONBOARDING_STEP_3':
        return AuthNextStep.onboardingStep3;
      case 'ONBOARDING_STEP_4':
        return AuthNextStep.onboardingStep4;
      case 'ONBOARDING_STEP_5':
        return AuthNextStep.onboardingStep5;
      case 'ONBOARDING_STEP_6':
        return AuthNextStep.onboardingStep6;
      default:
        return AuthNextStep.onboardingStep1;
    }
  }

  String toApi() {
    switch (this) {
      case AuthNextStep.home:
        return 'HOME';
      case AuthNextStep.onboardingStep1:
        return 'ONBOARDING_STEP_1';
      case AuthNextStep.onboardingStep2:
        return 'ONBOARDING_STEP_2';
      case AuthNextStep.onboardingStep3:
        return 'ONBOARDING_STEP_3';
      case AuthNextStep.onboardingStep4:
        return 'ONBOARDING_STEP_4';
      case AuthNextStep.onboardingStep5:
        return 'ONBOARDING_STEP_5';
      case AuthNextStep.onboardingStep6:
        return 'ONBOARDING_STEP_6';
    }
  }
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
