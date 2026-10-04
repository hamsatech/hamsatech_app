import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/score_entry/bloc/score_entry_state.dart';

/// Pure, network-free coverage for the isSubmitting/submitError fields added
/// to ScoreEntryActiveState so the UI can tell the difference between "still
/// saving", "saved", and "save failed, please retry" instead of the score
/// screen reporting success before the series/score/completion calls had
/// even resolved.
void main() {
  const base = ScoreEntryActiveState(
    sessionTitle: 'Test Session',
    totalSeries: 3,
    shotsPerSeries: 10,
    enteredTotals: [90, 88, 91],
  );

  test('defaults to not submitting and no error', () {
    expect(base.isSubmitting, isFalse);
    expect(base.submitError, isNull);
  });

  test('copyWith(isSubmitting: true) flips the flag and keeps other fields',
      () {
    final submitting = base.copyWith(isSubmitting: true);

    expect(submitting.isSubmitting, isTrue);
    expect(submitting.enteredTotals, base.enteredTotals);
    expect(submitting.submitError, isNull);
  });

  test('copyWith(submitError: ...) sets an error message', () {
    final failed = base.copyWith(
      isSubmitting: false,
      submitError: 'Could not save your scores. Check your connection and '
          'try again.',
    );

    expect(failed.isSubmitting, isFalse);
    expect(failed.submitError, isNotNull);
  });

  test(
    'copyWith(clearSubmitError: true) clears a previous error even without '
    'passing a new submitError',
    () {
      final failed = base.copyWith(submitError: 'network error');
      final retrying =
          failed.copyWith(isSubmitting: true, clearSubmitError: true);

      expect(retrying.submitError, isNull);
      expect(retrying.isSubmitting, isTrue);
    },
  );

  test('an unrelated copyWith call preserves a previously set submitError', () {
    final failed = base.copyWith(submitError: 'network error');
    final stillFailed = failed.copyWith(enteredTotals: [90, 88, 91, 95]);

    expect(stillFailed.submitError, 'network error');
  });
}
