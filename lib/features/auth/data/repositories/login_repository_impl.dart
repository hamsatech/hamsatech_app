import '../../domain/entities/onboarding_slide_entity.dart';
import '../../domain/repositories/login_repository.dart';

/// Mock implementation — no network calls.
/// Swap this with a real implementation backed by remote config or CMS
/// when slide content needs to be dynamic.
class MockLoginRepository implements ILoginRepository {
  const MockLoginRepository();

  @override
  List<OnboardingSlideEntity> getSlides() => const [
        OnboardingSlideEntity(
          id: 'slide_1',
          title: 'Performance',
          description:
              'Track mental performance, recovery and readiness to unlock your full potential in competition.',
          imageAssetPath: 'assets/onboarding/performance.jpg',
        ),
        OnboardingSlideEntity(
          id: 'slide_2',
          title: 'Relationships & Compatibility',
          description:
              'Understand how stress and emotional patterns shape your most important connections.',
          comingSoon: true,
          imageAssetPath: 'assets/onboarding/wellness.jpg',
        ),
        OnboardingSlideEntity(
          id: 'slide_3',
          title: 'Work / Parenting / Wellbeing',
          description:
              'Balance performance demands across every dimension of your life.',
          comingSoon: true,
          imageAssetPath: 'assets/onboarding/balance.jpg',
        ),
      ];

  @override
  Future<void> initiateSignUp() async {
    await Future.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<void> initiateLogin() async {
    await Future.delayed(const Duration(milliseconds: 80));
  }
}
