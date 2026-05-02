import 'package:bloc/bloc.dart';
import 'onboarding_step1_event.dart';
import 'onboarding_step1_state.dart';

class OnboardingStep1Bloc
    extends Bloc<OnboardingStep1Event, OnboardingStep1State> {
  OnboardingStep1Bloc() : super(const OnboardingStep1State()) {
    on<OnNameChanged>(_onNameChanged);
    on<OnAgeChanged>(_onAgeChanged);
    on<OnGenderSelected>(_onGenderSelected);
    on<OnCityChanged>(_onCityChanged);
    on<OnSubmit>(_onSubmit);
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

  void _onSubmit(
    OnSubmit event,
    Emitter<OnboardingStep1State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    // simulate submission or call repository here
    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    // For now, mark success immediately. In real app, call async repository.
    emit(validated.copyWith(submissionSuccess: true));
  }

  OnboardingStep1State _validate(OnboardingStep1State s) {
    // Validation rules:
    // - name non-empty and >= 2 chars
    // - age numeric and between 10 and 120
    // - gender must be selected (not unknown)
    // - city non-empty

    if (s.name.isEmpty) {
      return s.copyWith(isValid: false, errorMessage: 'Please enter your full name');
    }
    if (s.name.length < 2) {
      return s.copyWith(isValid: false, errorMessage: 'Name is too short');
    }

    final ageInt = int.tryParse(s.age);
    if (ageInt == null) {
      return s.copyWith(isValid: false, errorMessage: 'Please enter a valid age');
    }
    if (ageInt < 10 || ageInt > 120) {
      return s.copyWith(isValid: false, errorMessage: 'Please enter a realistic age');
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
}
