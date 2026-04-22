import '../../domain/entities/athlete_profile_entity.dart';
import '../../domain/entities/baseline_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/questions_data.dart';
import '../models/athlete_profile_model.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  List<BaselineQuestionEntity> getBaselineQuestions() => kBaselineQuestions;

  @override
  Future<void> saveAthleteProfile(AthleteProfileEntity profile) async {
    final model = AthleteProfileModel.fromEntity(profile);
    await StorageService.saveAthleteProfile(model.toJson());
    await StorageService.saveBaselineScores(profile.baselineScores);
    await StorageService.setOnboardingComplete(true);
  }

  @override
  AthleteProfileEntity? getAthleteProfile() {
    final json = StorageService.getAthleteProfile();
    if (json == null) return null;
    return AthleteProfileModel.fromJson(json);
  }

  @override
  Map<String, double> calculateScores(Map<int, int> answers) {
    final questions = kBaselineQuestions;
    final categoryTotals = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final q in questions) {
      final selectedIndex = answers[q.id];
      if (selectedIndex == null) continue;
      final score = q.options[selectedIndex].score;
      categoryTotals[q.category] = (categoryTotals[q.category] ?? 0) + score;
      categoryCounts[q.category] = (categoryCounts[q.category] ?? 0) + 1;
    }

    // Max score per question is 5; normalize to 0–100
    return {
      'focus': _normalize(categoryTotals['focus'] ?? 0,
          categoryCounts['focus'] ?? 1),
      'emotionalStability': _normalize(
          categoryTotals['emotional_stability'] ?? 0,
          categoryCounts['emotional_stability'] ?? 1),
      'decisionStyle': _normalize(categoryTotals['decision_style'] ?? 0,
          categoryCounts['decision_style'] ?? 1),
      'motivation': _normalize(categoryTotals['motivation'] ?? 0,
          categoryCounts['motivation'] ?? 1),
    };
  }

  double _normalize(int total, int count) =>
      count == 0 ? 0 : (total / (count * 5)) * 100;
}
