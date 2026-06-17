import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/daily_checkin_entity.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import '../models/daily_checkin_model.dart';

class DailyCheckinRepositoryImpl implements DailyCheckinRepository {
  @override
  Future<void> saveCheckin(DailyCheckinEntity checkin) async {
    // Save locally first — works offline and is the source of truth for the UI.
    final model = DailyCheckinModel(
      id: checkin.id,
      date: checkin.date,
      mood: checkin.mood,
      energy: checkin.energy,
      sleep: checkin.sleep,
      emotions: checkin.emotions,
    );
    await StorageService.saveTodayCheckIn(model.toJson());

    // Fire-and-forget: sync to mobile backend (non-blocking).
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId != null) {
      Future(() async {
        try {
          await ApiService.instance.saveDailyCheckin(
            athleteId: athleteId,
            mood: _moodToInt(checkin.mood),
            energyLevel: checkin.energy,
            sleepBand: checkin.sleep.label,
            tags: checkin.emotions.map((e) => e.name).toList(),
          );
          debugPrint('[CHECKIN] daily check-in synced athleteId=$athleteId');
        } catch (e) {
          debugPrint('[CHECKIN] daily check-in sync failed (non-fatal): $e');
        }
      });
    } else {
      debugPrint('[CHECKIN] sync skipped — no athlete_id');
    }
  }

  @override
  DailyCheckinEntity? getTodayCheckin() {
    final json = StorageService.getTodayCheckIn();
    if (json == null) return null;
    try {
      return DailyCheckinModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  String? getPolarSleepEstimate() {
    // Derives a rough sleep estimate from baseline scores when Polar is
    // connected; returns null when no data is available so the UI shows a
    // generic subtitle instead.
    final scores = StorageService.getBaselineScores();
    if (scores == null) return null;
    final recovery = scores['recovery'] ?? 0.5;
    final sleepHours = 5.5 + recovery * 3.0; // maps 0–1 → 5.5h–8.5h
    final hours = sleepHours.floor();
    final minutes = ((sleepHours - hours) * 60).round();
    return '~${hours}h ${minutes}min';
  }

  int _moodToInt(MoodOption mood) => switch (mood) {
        MoodOption.trouble => 1,
        MoodOption.poor => 2,
        MoodOption.okay => 3,
        MoodOption.good => 4,
        MoodOption.great => 5,
      };
}
