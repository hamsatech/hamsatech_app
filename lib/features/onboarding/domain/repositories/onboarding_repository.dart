import '../entities/athlete_profile_entity.dart';
import '../entities/baseline_question_entity.dart';

abstract class OnboardingRepository {
  List<BaselineQuestionEntity> getBaselineQuestions();
  Future<void> saveAthleteProfile(AthleteProfileEntity profile);
  AthleteProfileEntity? getAthleteProfile();
  Map<String, double> calculateScores(Map<int, int> answers);
}
