import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'onboarding_step2_event.dart';
import 'onboarding_step2_state.dart';

class OnboardingStep2Bloc
    extends Bloc<OnboardingStep2Event, OnboardingStep2State> {
  OnboardingStep2Bloc() : super(const OnboardingStep2State()) {
    on<OnDisciplineChanged>(_onDisciplineChanged);
    on<OnExperienceChanged>(_onExperienceChanged);
    on<OnYearsIncrement>(_onYearsIncrement);
    on<OnYearsDecrement>(_onYearsDecrement);
    on<OnAcademySelected>(_onAcademySelected);
    on<OnLoadAcademies>(_onLoadAcademies);
    on<OnLoadOnboarding>(_onLoadOnboarding);
    on<OnStep2Submit>(_onSubmit);
  }

  void _onDisciplineChanged(
    OnDisciplineChanged event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next =
        state.copyWith(discipline: event.discipline, errorMessage: null);
    emit(_validate(next));
  }

  void _onExperienceChanged(
    OnExperienceChanged event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next =
        state.copyWith(experience: event.experience, errorMessage: null);
    emit(_validate(next));
  }

  void _onYearsIncrement(
    OnYearsIncrement event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next = state.copyWith(
      yearsShoot: state.yearsShoot + 1,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  void _onYearsDecrement(
    OnYearsDecrement event,
    Emitter<OnboardingStep2State> emit,
  ) {
    if (state.yearsShoot <= 0) return;
    final next = state.copyWith(
      yearsShoot: state.yearsShoot - 1,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  void _onAcademySelected(
    OnAcademySelected event,
    Emitter<OnboardingStep2State> emit,
  ) {
    final next = state.copyWith(
      academy: event.academy.name,
      academyId: event.academy.id,
      errorMessage: null,
    );
    emit(_validate(next));
  }

  Future<void> _onLoadAcademies(
    OnLoadAcademies event,
    Emitter<OnboardingStep2State> emit,
  ) async {
    try {
      final res = await ApiService.instance.getAcademies();
      debugPrint('[ONBOARDING STEP2] GET academies status=${res.statusCode}');
      debugPrint(
          '[ONBOARDING STEP2] GET academies raw body (${res.data.runtimeType}): ${res.data}');
      final list = res.data as List<dynamic>;
      final academies = list
          .map((raw) {
            final item = raw as Map<String, dynamic>;
            final id = item['academyId'] as String?;
            final name = item['academyName'] as String?;
            if (id == null || name == null) return null;
            return AcademyOption(id: id, name: name);
          })
          .whereType<AcademyOption>()
          .toList();
      emit(state.copyWith(academies: academies));
      debugPrint('[ONBOARDING STEP2] loaded ${academies.length} academies');

      // If GET /api/v2/onboarding already prefilled an academyId before
      // this list arrived, resolve its display name now.
      final selectedId = state.academyId;
      if (selectedId != null) {
        final match =
            academies.where((a) => a.id == selectedId).toList();
        if (match.isNotEmpty) {
          emit(state.copyWith(academy: match.first.name));
        }
      }
    } catch (e) {
      debugPrint('[ONBOARDING STEP2] GET academies failed (non-fatal): $e');
    }
  }

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<OnboardingStep2State> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final discipline = data['discipline'] as String?;
      final experienceLevel = data['experience_level'] as String?;
      final yearsShooting = data['years_shooting'] as int?;
      final academyId = data['academy_id'] as String?;

      if (discipline == null &&
          experienceLevel == null &&
          yearsShooting == null &&
          academyId == null) {
        return;
      }

      var next = state.copyWith(
        discipline: discipline ?? state.discipline,
        experience: experienceLevel ?? state.experience,
        yearsShoot: yearsShooting ?? state.yearsShoot,
      );
      if (academyId != null) {
        final match =
            state.academies.where((a) => a.id == academyId).toList();
        next = next.copyWith(
          academyId: academyId,
          academy: match.isNotEmpty ? match.first.name : next.academy,
        );
      }
      emit(_validate(next));
      debugPrint('[ONBOARDING STEP2] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint('[ONBOARDING STEP2] GET onboarding failed (non-fatal): $e');
    }
  }

  Future<void> _onSubmit(
    OnStep2Submit event,
    Emitter<OnboardingStep2State> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated);
      return;
    }
    if (validated.academyId == null) {
      emit(validated.copyWith(errorMessage: 'Please select an academy'));
      return;
    }

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep2(
        discipline: validated.discipline,
        experienceLevel: validated.experience,
        yearsShooting: validated.yearsShoot,
        academyId: validated.academyId!,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[ONBOARDING STEP2] PUT step-2 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  OnboardingStep2State _validate(OnboardingStep2State s) {
    if (s.discipline.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please select a discipline',
      );
    }
    if (s.experience.isEmpty) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Please select your experience level',
      );
    }
    if (s.yearsShoot < 0) {
      return s.copyWith(
        isValid: false,
        errorMessage: 'Years shooting cannot be negative',
      );
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
