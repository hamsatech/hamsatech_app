import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/checkin/data/repositories/daily_checkin_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression coverage: the Polar H10 has no sleep sensor, so there was
/// never a real measurement behind "We saw Xh from your Polar" — it was
/// computed from a `recovery` baseline score via an arbitrary formula, and
/// that score was never actually populated by any live code path either.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('getPolarSleepEstimate is always null, even if a baseline score '
      'happens to be cached locally', () async {
    await StorageService.saveBaselineScores({'recovery': 0.8});
    final repository = DailyCheckinRepositoryImpl();

    expect(repository.getPolarSleepEstimate(), isNull);
  });

  test('getPolarSleepEstimate is null with no cached data either', () {
    final repository = DailyCheckinRepositoryImpl();

    expect(repository.getPolarSleepEstimate(), isNull);
  });
}
