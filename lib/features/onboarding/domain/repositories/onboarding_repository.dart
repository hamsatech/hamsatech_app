import '../entities/athlete_profile_entity.dart';
import '../entities/baseline_question_entity.dart';

abstract class OnboardingRepository {
  List<BaselineQuestionEntity> getBaselineQuestions();
  Future<void> saveAthleteProfile(AthleteProfileEntity profile);
  AthleteProfileEntity? getAthleteProfile();
  Map<String, double> calculateScores(Map<int, int> answers);

  /// Retries the Supabase athletes POST if supabase_athlete_id was not saved
  /// during onboarding (e.g. network failure during assessment completion).
  /// Safe to call multiple times — no-ops if athlete_id already persisted.
  Future<void> retryAthleteSync();
}
