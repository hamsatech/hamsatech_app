import '../../domain/entities/onboarding_slide_entity.dart';
import '../../domain/repositories/login_repository.dart';

/// Sits between the BLoC and the repository.
/// Owns all presentation-specific derivations so the BLoC stays event-driven
/// and the UI stays declarative.
class WelcomeViewModel {
  const WelcomeViewModel(this._repository);

  final ILoginRepository _repository;

  // ── Static copy ───────────────────────────────────────────────────────────
  static const String headerSubtitle = 'Mental Performance AI';
  static const String headerTitle    = 'ASTRA';
  static const String signUpLabel    = 'Sign Up Now';
  static const String loginLabel     = 'Log In Here';

  // ── Data ──────────────────────────────────────────────────────────────────
  List<OnboardingSlideEntity> get slides => _repository.getSlides();

  Future<void> initiateSignUp()  => _repository.initiateSignUp();
  Future<void> initiateLogin()   => _repository.initiateLogin();
}
