import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_step1_bloc.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_step1_event.dart';
import 'package:hamsatech/features/onboarding/presentation/bloc/onboarding_step1_state.dart';

/// Regression coverage for the Step 1 gender contract mismatch: the backend
/// `Gender` enum only ever accepts "Male"/"Female" (it matches the real
/// hamsatech.athletes.gender column data), but the UI used to also offer a
/// third "Other" option that would 422 on submit. The fix removed "Other"
/// from OnboardingGender/genderOptions entirely, so there is no longer any
/// selectable, submittable value the backend would reject.
void main() {
  test(
      'the default gender options offered to the athlete are exactly '
      'male/female — no "other" option exists to select', () {
    const state = OnboardingStep1State();
    expect(state.genderOptions, ['male', 'female']);
  });

  group('OnboardingStep1Bloc gender selection', () {
    late OnboardingStep1Bloc bloc;

    setUp(() => bloc = OnboardingStep1Bloc());
    tearDown(() => bloc.close());

    test('selecting "male" resolves to OnboardingGender.male', () async {
      bloc.add(const OnGenderSelected('male'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.gender, OnboardingGender.male);
    });

    test('selecting "female" resolves to OnboardingGender.female', () async {
      bloc.add(const OnGenderSelected('female'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.gender, OnboardingGender.female);
    });

    test(
      'a legacy/unrecognized value (e.g. "other", from a pre-fix cached '
      'state) resolves to OnboardingGender.unknown, not a distinct '
      '"other" state — there is no OnboardingGender.other any more',
      () async {
        // Fill every other required field first so the validation error we
        // assert on below is specifically about gender, not an earlier
        // field in _validate's checks.
        bloc.add(const OnNameChanged('Jane Doe'));
        bloc.add(const OnAgeChanged('22'));
        bloc.add(const OnCityChanged('Delhi'));
        bloc.add(const OnGenderSelected('other'));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.gender, OnboardingGender.unknown);
        expect(bloc.state.isValid, isFalse);
        expect(bloc.state.errorMessage, 'Please select a gender');
      },
    );
  });
}
