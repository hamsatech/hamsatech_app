import '../../../../core/services/storage_service.dart';
import '../../domain/entities/daily_checkin_entity.dart';
import '../../domain/repositories/daily_checkin_repository.dart';
import '../models/daily_checkin_model.dart';

class DailyCheckinRepositoryImpl implements DailyCheckinRepository {
  @override
  Future<void> saveCheckin(DailyCheckinEntity checkin) async {
    final model = DailyCheckinModel(
      id: checkin.id,
      date: checkin.date,
      mood: checkin.mood,
      energy: checkin.energy,
      sleep: checkin.sleep,
      emotions: checkin.emotions,
    );
    await StorageService.saveTodayCheckIn(model.toJson());
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
}
