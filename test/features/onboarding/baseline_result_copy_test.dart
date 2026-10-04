import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/onboarding/presentation/screens/baseline_result_screen.dart';

/// Regression coverage for the fabricated-baseline fix: BaselineResultScreen
/// used to default to a hardcoded 76bpm whenever Polar hadn't produced a
/// reading, and unconditionally showed "Baseline saved" regardless of
/// whether a real measurement existed. This locks down that the "saved"
/// language can only ever appear when a reading actually exists, and that
/// the no-reading copy never implies a value was captured.
void main() {
  group('resolveBaselineResultCopy(true) — a real reading exists', () {
    final copy = resolveBaselineResultCopy(true);

    test('claims the baseline was saved', () {
      expect(copy.cardTitle, 'Baseline saved');
    });

    test('heading presents the number as a real measurement', () {
      expect(copy.heading, 'Your resting heart rate is');
    });
  });

  group('resolveBaselineResultCopy(false) — no reading was captured', () {
    final copy = resolveBaselineResultCopy(false);

    test('never positively claims anything was saved', () {
      expect(copy.cardTitle, isNot(contains('Baseline saved')));
      expect(copy.cardBody, isNot(contains('This is your personal baseline')));
    });

    test('is explicit that no baseline was captured', () {
      expect(copy.cardTitle, 'No baseline captured');
      expect(copy.cardBody, contains('no baseline was saved'));
    });

    test('heading does not present a fabricated value as measured', () {
      expect(copy.heading, isNot(contains('resting heart rate is')));
    });
  });
}
