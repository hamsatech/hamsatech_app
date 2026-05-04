import 'package:equatable/equatable.dart';

class OnboardingSlideEntity extends Equatable {
  const OnboardingSlideEntity({
    required this.id,
    required this.caption,
    this.imageAssetPath,
    this.imageNetworkUrl,
  });

  final String id;
  final String caption;

  /// Local asset path (e.g. 'assets/images/slide_1.jpg').
  /// When null the slide renders a branded placeholder.
  final String? imageAssetPath;

  /// Remote image URL; takes precedence over [imageAssetPath] when both provided.
  final String? imageNetworkUrl;

  bool get hasImage => imageAssetPath != null || imageNetworkUrl != null;

  @override
  List<Object?> get props => [id, caption, imageAssetPath, imageNetworkUrl];
}
