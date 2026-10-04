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
    // Save locally first — today's UI state remains usable even if the
    // backend call below fails. This part is unchanged.
    final model = DailyCheckinModel(
      id: checkin.id,
      date: checkin.date,
      mood: checkin.mood,
      energy: checkin.energy,
      sleep: checkin.sleep,
      emotions: checkin.emotions,
    );
    await StorageService.saveTodayCheckIn(model.toJson());

    // Backend sync is now awaited, and a failure here propagates to the
    // caller instead of being silently swallowed: `DailyCheckinBloc._onSubmit`
    // already wraps this whole call in a try/catch that emits
    // `DailyCheckinError` on any thrown exception — previously that path
    // was unreachable for a backend failure because it was caught and only
    // logged here. The UI must not report success when the backend write
    // did not actually happen.
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) {
      throw StateError('Unable to sync check-in: no athlete_id available.');
    }

    await ApiService.instance.saveDailyCheckin(
      athleteId: athleteId,
      mood: _moodToInt(checkin.mood),
      energyLevel: checkin.energy,
      sleepBand: checkin.sleep.label,
      tags: checkin.emotions.map((e) => e.name).toList(),
    );
    debugPrint('[CHECKIN] daily check-in synced athleteId=$athleteId');
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
    // The Polar H10 is a heart-rate chest strap — it has no sleep sensor,
    // so there has never been a real "Polar sleep estimate" to derive here.
    // This used to compute one anyway from a `recovery` baseline score via
    // an arbitrary formula, labeled in the UI as "We saw Xh from your
    // Polar" — misleading regardless of whether that score was ever
    // populated (it never was in the live app; `StorageService
    // .getBaselineScores()` has no live writer — see
    // OnboardingRepositoryImpl's own dead `saveAthleteProfile`). Always
    // null now, so `_SleepSubtitle` shows its existing, honest fallback
    // ("Select how many hours you slept last night:") instead.
    return null;
  }

  int _moodToInt(MoodOption mood) => switch (mood) {
        MoodOption.trouble => 1,
        MoodOption.poor => 2,
        MoodOption.okay => 3,
        MoodOption.good => 4,
        MoodOption.great => 5,
      };
}
