import 'package:flutter/foundation.dart';

import '../../domain/entities/athlete_profile_entity.dart';
import '../../domain/entities/baseline_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/questions_data.dart';
import '../models/athlete_profile_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  List<BaselineQuestionEntity> getBaselineQuestions() => kBaselineQuestions;

  @override
  Future<void> saveAthleteProfile(AthleteProfileEntity profile) async {
    // Always persist locally first — onboarding must succeed even if offline.
    final model = AthleteProfileModel.fromEntity(profile);
    await StorageService.saveAthleteProfile(model.toJson());
    await StorageService.saveBaselineScores(profile.baselineScores);
    await StorageService.setOnboardingComplete(true);

    // Await the Supabase POST so athlete_id is guaranteed to be in
    // SharedPreferences before the BLoC emits success and the router
    // navigates. The loading state on the assessment screen covers this wait.
    // Failure is still non-fatal — local save already completed above.
    await _syncAthleteToSupabase(profile);
  }

  Future<void> _syncAthleteToSupabase(AthleteProfileEntity profile) async {
    debugPrint('[ONBOARDING] POST athletes name=${profile.name} age=${profile.age} sport=${profile.sportDomain}');
    try {
      final res = await ApiService.instance.createAthleteFromProfile(
        athleteName: profile.name,
        age: profile.age,
        sport: profile.sportDomain,
      );
      debugPrint('[ONBOARDING] athlete POST status=${res.statusCode} data=${res.data}');
      final athleteId = _extractAthleteId(res.data);
      if (athleteId != null && athleteId.isNotEmpty) {
        await StorageService.saveAthleteId(athleteId);
        debugPrint('[ONBOARDING] athlete_id persisted: $athleteId');
      } else {
        debugPrint('[ONBOARDING] WARNING: no athlete_id in response — ${res.data}');
      }
    } catch (e) {
      debugPrint('[ONBOARDING] athlete POST failed (non-fatal): $e');
      // Local profile already saved; AlexSummaryScreen will retry on "Go to Home".
    }
  }

  /// Extracts athlete_id from a Supabase POST response.
  /// Supabase returns an array when Prefer: return=representation is sent.
  String? _extractAthleteId(dynamic data) {
    if (data is List && data.isNotEmpty) {
      return (data.first as Map?)?['athlete_id']?.toString();
    }
    if (data is Map) return data['athlete_id']?.toString();
    return null;
  }

  @override
  Future<void> retryAthleteSync() async {
    if (StorageService.getAthleteId() != null) return; // already succeeded
    final profile = getAthleteProfile();
    if (profile == null) return;
    await _syncAthleteToSupabase(profile);
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
