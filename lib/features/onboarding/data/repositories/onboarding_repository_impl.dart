import 'package:flutter/foundation.dart';

import '../../domain/entities/athlete_profile_entity.dart';
import '../../domain/entities/baseline_question_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/questions_data.dart';
import '../models/athlete_profile_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  List<BaselineQuestionEntity> getBaselineQuestions() => kBaselineQuestions;

  @override
  Future<void> saveAthleteProfile(AthleteProfileEntity profile) async {
    // Persist locally — onboarding must succeed even if offline.
    final model = AthleteProfileModel.fromEntity(profile);
    await StorageService.saveAthleteProfile(model.toJson());
    await StorageService.saveBaselineScores(profile.baselineScores);
    await StorageService.setOnboardingComplete(true);

    // Athlete row is created by the backend at OTP verify-registration time.
    // Flutter only writes psychology scores here.
    await _syncPsychologyScores(profile.baselineScores);

    // Fire-and-forget: sync full profile to mobile backend (non-blocking).
    _syncProfileUpdate(profile);
  }

  void _syncProfileUpdate(AthleteProfileEntity profile) {
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) {
      debugPrint('[PROFILE UPDATE] skipped — no athlete_id');
      return;
    }
    Future(() async {
      try {
        final res = await ApiService.instance.updateMobileAthleteProfile(
          athleteId: athleteId,
          name: profile.name,
          age: profile.age,
          sportDomain: profile.sportDomain,
          experienceLevel: profile.experienceLevel,
          familySupport: profile.familySupport,
          pressureSources: profile.pressureSources,
        );
        debugPrint('[PROFILE UPDATE] status=${res.statusCode}');
      } catch (e) {
        debugPrint('[PROFILE UPDATE] failed (non-fatal): $e');
      }
    });
  }

  Future<void> _syncPsychologyScores(Map<String, double> scores) async {
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) {
      debugPrint('[PSYCH SCORES] skipped — no athlete_id available');
      return;
    }

    final focus = scores['focus'] ?? 0;
    final emotional = scores['emotionalStability'] ?? 0;
    final decision = scores['decisionStyle'] ?? 0;
    final motivation = scores['motivation'] ?? 0;
    final composite =
        focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20;
    final totalQuestions = kBaselineQuestions.length;

    // One row per category — matches actual psychology_scores table schema.
    final categories = <String, double>{
      'focus': focus,
      'confidence': emotional,
      'anxiety': 100 - emotional,
      'motivation': motivation,
      'resilience': decision,
      'composite': composite,
    };

    for (final entry in categories.entries) {
      debugPrint('[PSYCH SCORES] POST category=${entry.key} '
          'score=${entry.value.toStringAsFixed(2)} athleteId=$athleteId');
      try {
        final res = await ApiService.instance.createPsychologyScore(
          athleteId: athleteId,
          category: entry.key,
          score: entry.value,
          answeredQuestions: totalQuestions,
        );
        debugPrint(
            '[PSYCH SCORES] ${entry.key} success status=${res.statusCode}');
      } catch (e) {
        debugPrint('[PSYCH SCORES] ${entry.key} POST failed (non-fatal): $e');
      }
    }
  }

  @override
  Future<void> retryAthleteSync() async {
    // Athlete creation is handled by the backend at OTP verify-registration time.
    // The returned athleteId is already persisted in StorageService — no retry needed.
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
      'focus': _normalize(
          categoryTotals['focus'] ?? 0, categoryCounts['focus'] ?? 1),
      'emotionalStability': _normalize(
          categoryTotals['emotional_stability'] ?? 0,
          categoryCounts['emotional_stability'] ?? 1),
      'decisionStyle': _normalize(categoryTotals['decision_style'] ?? 0,
          categoryCounts['decision_style'] ?? 1),
      'motivation': _normalize(
          categoryTotals['motivation'] ?? 0, categoryCounts['motivation'] ?? 1),
    };
  }

  double _normalize(int total, int count) =>
      count == 0 ? 0 : (total / (count * 5)) * 100;
}
