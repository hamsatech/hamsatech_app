import '../entities/onboarding_slide_entity.dart';

/// Abstraction for the welcome/login entry-point flow.
/// Concrete implementations swap between mock and production data sources.
abstract class ILoginRepository {
  /// Returns the ordered list of onboarding carousel slides.
  List<OnboardingSlideEntity> getSlides();

  /// Initiates the sign-up flow (e.g. pre-flight checks, analytics).
  Future<void> initiateSignUp();

  /// Initiates the login flow.
  Future<void> initiateLogin();
}
