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
          caption: 'Ready to achieve success?\nStart tracking — it\'s simple!',
          imageNetworkUrl:
              'https://i.postimg.cc/52239rPR/Mask-group.png',
        ),
        OnboardingSlideEntity(
          id: 'slide_2',
          caption: 'Track your mental performance\nwith AI-powered insights.',
          imageNetworkUrl:
              'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=600&h=680&fit=crop&q=80',
        ),
        OnboardingSlideEntity(
          id: 'slide_3',
          caption: 'Join elite athletes building\nconsistency under pressure.',
          imageNetworkUrl:
              'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=600&h=680&fit=crop&q=80',
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
