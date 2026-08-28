import 'package:equatable/equatable.dart';

class BaselineQuestionEntity extends Equatable {
  const BaselineQuestionEntity({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
  });

  final int id;
  final String question;
  final String
      category; // focus | emotional_stability | decision_style | motivation
  final List<AnswerOptionEntity> options;

  @override
  List<Object?> get props => [id, question, category];
}

class AnswerOptionEntity extends Equatable {
  const AnswerOptionEntity({required this.text, required this.score, this.optionCode});

  final String text;
  final int score; // 1–5
  final String? optionCode; // set when sourced from GET /api/v2/psychology-assessment

  @override
  List<Object?> get props => [text, score, optionCode];
}
