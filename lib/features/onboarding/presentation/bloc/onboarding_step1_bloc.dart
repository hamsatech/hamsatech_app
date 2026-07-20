import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'onboarding_step1_event.dart';
import 'onboarding_step1_state.dart';

class OnboardingStep1Bloc
    extends Bloc<OnboardingStep1Event, OnboardingStep1State> {
  OnboardingStep1Bloc() : super(const OnboardingStep1State()) {
    on<OnNameChanged>(_onNameChanged);
    on<OnAgeChanged>(_onAgeChanged);
    on<OnDobSelected>(_onDobSelected);
    on<OnGenderSelected>(_onGenderSelected);
    on<OnCityChanged>(_onCityChanged);
    on<OnSubmit>(_onSubmit);
    on<OnLoadOnboarding>(_onLoadOnboarding);
  }

  void _onNameChanged(
    OnNameChanged event,
    Emitter<OnboardingStep1State> emit,
  ) {
    final name = event.name.trim();
    final next = state.copyWith(name: name, errorMessage: null);
    emit(_validate(next));
  }

  void _onAgeChanged(
    OnAgeChanged event,
    Emitter<OnboardingStep1State> emit,
  ) {
    final ageRaw = event.age.trim();
    // allow only numeric string in state; validation checks numeric range
    final age = ageRaw;
    final next = state.copyWith(age: age, errorMessage: null);
    emit(_validate(next));
  }

  void _onGenderSelected(
    OnGenderSelected event,
    Emitter<OnboardingStep1State> emit,
  ) {
    final gender = _parseGender(event.gender);
    final next = state.copyWith(gender: gender, errorMessage: null);
    emit(_validate(next));
  }

  void _onCityChanged(
    OnCityChanged event,
    Emitter<OnboardingStep1State> emit,
  ) {
    final city = event.city.trim();
    final next = state.copyWith(city: city, errorMessage: null);
    emit(_validate(next));
  }

  Future<void> _onSubmit(
    OnSubmit event,
    Emitter<OnboardingStep1State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid || validated.dateOfBirth == null) {
      emit(validated);
      return;
    }

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep1(
        fullName: validated.name,
        dateOfBirth: _formatDate(validated.dateOfBirth!),
        gender: _genderApiValue(validated.gender),
        city: validated.city,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[ONBOARDING STEP1] PUT step-1 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onDobSelected(
    OnDobSelected event,
    Emitter<OnboardingStep1State> emit,
  ) {
    final next = state.copyWith(
      dateOfBirth: event.dob,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<OnboardingStep1State> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final fullName = data['full_name'] as String?;
      final dobRaw = data['date_of_birth'] as String?;
      final genderRaw = data['gender'] as String?;
      final city = data['city'] as String?;

      if (fullName == null && dobRaw == null && genderRaw == null &&
          city == null) {
        return;
      }

      final dob = dobRaw != null ? DateTime.tryParse(dobRaw) : null;

      var next = state.copyWith(
        name: fullName ?? state.name,
        city: city ?? state.city,
        gender: genderRaw != null ? _parseGender(genderRaw) : state.gender,
      );
      if (dob != null) {
        next = next.copyWith(
          dateOfBirth: dob,
          age: _calculateAge(dob).toString(),
        );
      }
      emit(_validate(next));
      debugPrint('[ONBOARDING STEP1] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint('[ONBOARDING STEP1] GET onboarding failed (non-fatal): $e');
    }
  }

  OnboardingStep1State _validate(OnboardingStep1State s) {
    // Validation rules:
    // - name non-empty and >= 2 chars
    // - age numeric and between 10 and 120
    // - gender must be selected (not unknown)
    // - city non-empty

    if (s.name.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your full name');
    }
    if (s.name.length < 2) {
      return s.copyWith(isValid: false, errorMessage: 'Name is too short');
    }

    final ageInt = int.tryParse(s.age);
    if (ageInt == null) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter a valid age');
    }
    if (ageInt < 10 || ageInt > 120) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter a realistic age');
    }

    if (s.gender == OnboardingGender.unknown) {
      return s.copyWith(isValid: false, errorMessage: 'Please select a gender');
    }

    if (s.city.isEmpty) {
      return s.copyWith(isValid: false, errorMessage: 'Please enter your city');
    }

    return s.copyWith(isValid: true, errorMessage: null);
  }

  OnboardingGender _parseGender(String value) {
    final v = value.toLowerCase();
    if (v == 'male') return OnboardingGender.male;
    if (v == 'female') return OnboardingGender.female;
    if (v == 'other') return OnboardingGender.other;
    return OnboardingGender.unknown;
  }

  // NOTE: the OpenAPI `Gender` enum only accepts "Male"/"Female" — the UI's
  // third "Other" option has no backend equivalent yet, so submitting it
  // will 422. See task report for details; not resolved here per
  // "do not modify UI" constraint.
  String _genderApiValue(OnboardingGender gender) {
    switch (gender) {
      case OnboardingGender.male:
        return 'Male';
      case OnboardingGender.female:
        return 'Female';
      case OnboardingGender.other:
        return 'Other';
      case OnboardingGender.unknown:
        return '';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    final beforeBirthday = now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day);
    if (beforeBirthday) age -= 1;
    return age;
  }
}
