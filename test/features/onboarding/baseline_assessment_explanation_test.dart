import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/onboarding/presentation/screens/baseline_assessment_screen.dart';

/// Regression coverage for Phase 3B Part B: the "Explain your answer" field
/// used to be captured in the TextEditingController and then silently
/// discarded — never read by the Next/Complete dispatch. This locks down
/// the trim/blank-to-null mapping that now feeds `answerText` into
/// [OnboardingNextQuestion]/[OnboardingAssessmentCompleted].
void main() {
  group('explanationTextOrNull', () {
    test('returns the trimmed text when the athlete wrote something', () {
      expect(explanationTextOrNull('  I felt nervous before the shot  '),
          'I felt nervous before the shot');
    });

    test('returns null for an empty string', () {
      expect(explanationTextOrNull(''), isNull);
    });

    test('returns null for whitespace-only input', () {
      expect(explanationTextOrNull('   \n  '), isNull);
    });

    test('preserves internal whitespace, only trims the ends', () {
      expect(explanationTextOrNull('  a  b  '), 'a  b');
    });
  });
}
