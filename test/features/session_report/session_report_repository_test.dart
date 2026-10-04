import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/services/session_memory.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/session_report/data/repositories/session_report_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression coverage for the historical-session data-correctness fix:
/// `StorageService.getScoreSummary()` has no session key of its own, so
/// `SessionReportRepositoryImpl.getReport()` must only trust it when it was
/// tagged (via `saveScoreSummarySessionId`) for the session actually
/// selected (`SessionMemory.sessionId` / `StorageService.getSessionId()`),
/// never merely because *some* local summary happens to be present.
///
/// No athlete ID is ever configured in these tests, so the backend-fallback
/// paths (`_fetchSessionReport`/`_fetchSessionHr`) take their existing
/// early-return ("no athlete id") branch and never attempt a real network
/// call — same technique already used by `score_entry_bloc_test.dart`.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    // Static field — must not leak a session ID between tests.
    SessionMemory.sessionId = null;
  });

  List<Map<String, dynamic>> sampleSummary() => [
        {
          'seriesNumber': 1,
          'shots': List<String>.filled(10, '8.50'),
          'total': 85.0,
        },
      ];

  test(
      'local cache tagged for the selected session is used '
      '(seriesRows reflects the cached shots)', () async {
    await StorageService.saveScoreSummary(sampleSummary());
    await StorageService.saveScoreSummarySessionId('session-A');
    SessionMemory.sessionId = 'session-A';

    final report = await SessionReportRepositoryImpl().getReport();

    expect(report.seriesRows, isNotEmpty);
    expect(report.seriesRows.first.total, 85.0);
  });

  test(
      'local cache tagged for a DIFFERENT session must NOT be used '
      '(falls back to empty/backend, never shows the wrong session)',
      () async {
    await StorageService.saveScoreSummary(sampleSummary());
    await StorageService.saveScoreSummarySessionId('session-OLD');
    SessionMemory.sessionId = 'session-NEW'; // a different, newly-selected session

    final report = await SessionReportRepositoryImpl().getReport();

    // No athlete ID configured, so the backend fetch can't succeed either —
    // the honest result is the safe empty report, not session-OLD's data.
    expect(report.seriesRows, isEmpty);
  });

  test('no local cache at all → empty report, no crash', () async {
    final report = await SessionReportRepositoryImpl().getReport();

    expect(report.seriesRows, isEmpty);
  });

  test(
      'local cache present but NO session is selected at all → used as '
      'best-effort (unchanged prior behavior; nothing specific to conflict with)',
      () async {
    await StorageService.saveScoreSummary(sampleSummary());
    // Deliberately: no saveScoreSummarySessionId, no SessionMemory.sessionId,
    // no StorageService.saveSessionId — no selected session exists anywhere.

    final report = await SessionReportRepositoryImpl().getReport();

    expect(report.seriesRows, isNotEmpty);
  });

  test(
      'local cache present but never tagged (legacy/untagged data) while a '
      'specific session IS selected → must NOT be guessed as a match',
      () async {
    await StorageService.saveScoreSummary(sampleSummary());
    // No saveScoreSummarySessionId call at all — simulates data written
    // before this fix existed.
    SessionMemory.sessionId = 'session-NEW';

    final report = await SessionReportRepositoryImpl().getReport();

    expect(report.seriesRows, isEmpty);
  });
}
