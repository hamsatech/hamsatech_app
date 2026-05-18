import 'package:equatable/equatable.dart';

class OnboardingSlideEntity extends Equatable {
  const OnboardingSlideEntity({
    required this.id,
    required this.title,
    required this.description,
    this.comingSoon = false,
    this.imageAssetPath,
  });

  final String id;
  final String title;
  final String description;
  final bool comingSoon;

  /// Local asset path (e.g. 'assets/images/slide_1.png').
  /// When null the slide renders a branded placeholder.
  final String? imageAssetPath;

  bool get hasImage => imageAssetPath != null;

  @override
  List<Object?> get props => [id, title, description, comingSoon, imageAssetPath];
}
