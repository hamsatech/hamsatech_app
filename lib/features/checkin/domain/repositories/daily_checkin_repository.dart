import '../entities/daily_checkin_entity.dart';

abstract class DailyCheckinRepository {
  Future<void> saveCheckin(DailyCheckinEntity checkin);
  DailyCheckinEntity? getTodayCheckin();
  String? getPolarSleepEstimate();
}
