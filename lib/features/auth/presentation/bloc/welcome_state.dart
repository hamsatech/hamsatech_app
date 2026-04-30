import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_slide_entity.dart';

enum WelcomeStatus { idle, navigateToSignUp, navigateToLogin }

class WelcomeState extends Equatable {
  const WelcomeState({
    this.slides = const [],
    this.currentPage = 0,
    this.status = WelcomeStatus.idle,
  });

  final List<OnboardingSlideEntity> slides;
  final int currentPage;
  final WelcomeStatus status;

  OnboardingSlideEntity? get currentSlide =>
      slides.isNotEmpty ? slides[currentPage] : null;

  WelcomeState copyWith({
    List<OnboardingSlideEntity>? slides,
    int? currentPage,
    WelcomeStatus? status,
  }) {
    return WelcomeState(
      slides: slides ?? this.slides,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [slides, currentPage, status];
}
