import 'package:equatable/equatable.dart';

class CategoryScoreEntity extends Equatable {
  const CategoryScoreEntity({
    required this.category,
    required this.displayName,
    this.childDescription,
    this.iconSlug,
    this.score,
    this.interpretation,
  });

  final String category;
  final String displayName;
  final String? childDescription;
  final String? iconSlug;
  final num? score;
  final String? interpretation;

  @override
  List<Object?> get props =>
      [category, displayName, childDescription, iconSlug, score, interpretation];
}

class AssessmentInsightEntity extends Equatable {
  const AssessmentInsightEntity({
    required this.category,
    this.score,
    this.title,
    this.insightText,
  });

  final String category;
  final num? score;
  final String? title;
  final String? insightText;

  @override
  List<Object?> get props => [category, score, title, insightText];
}
