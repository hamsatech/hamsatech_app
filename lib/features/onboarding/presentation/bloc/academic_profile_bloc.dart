import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'academic_profile_event.dart';
import 'academic_profile_state.dart';

class AcademicProfileBloc
    extends Bloc<AcademicProfileEvent, AcademicProfileState> {
  AcademicProfileBloc() : super(const AcademicProfileState()) {
    on<OnClassChanged>(_onClassChanged);
    on<OnSchoolNameChanged>(_onSchoolNameChanged);
    on<OnAcademicPerformanceChanged>(_onAcademicPerformanceChanged);
    on<OnLoadOnboarding>(_onLoadOnboarding);
    on<OnAcademicProfileSubmit>(_onSubmit);
  }

  void _onClassChanged(
    OnClassChanged event,
    Emitter<AcademicProfileState> emit,
  ) {
    final next =
        state.copyWith(className: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onSchoolNameChanged(
    OnSchoolNameChanged event,
    Emitter<AcademicProfileState> emit,
  ) {
    final next =
        state.copyWith(schoolName: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onAcademicPerformanceChanged(
    OnAcademicPerformanceChanged event,
    Emitter<AcademicProfileState> emit,
  ) {
    final next = state.copyWith(
        academicPerformance: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<AcademicProfileState> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final schoolClass = data['school_class'] as String?;
      final schoolName = data['school_name'] as String?;
      final academicPerformance = data['academic_performance'] as String?;

      if (schoolClass == null &&
          schoolName == null &&
          academicPerformance == null) {
        return;
      }

      final next = state.copyWith(
        className: schoolClass ?? state.className,
        schoolName: schoolName ?? state.schoolName,
        academicPerformance: academicPerformance ?? state.academicPerformance,
      );
      emit(_validate(next));
      debugPrint('[ACADEMIC PROFILE] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint('[ACADEMIC PROFILE] GET onboarding failed (non-fatal): $e');
    }
  }

  Future<void> _onSubmit(
    OnAcademicProfileSubmit event,
    Emitter<AcademicProfileState> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep4(
        schoolClass: validated.className,
        schoolName: validated.schoolName,
        academicPerformance: validated.academicPerformance,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[ACADEMIC PROFILE] PUT step-4 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  AcademicProfileState _validate(AcademicProfileState s) {
    if (s.className.isEmpty) {
      return s.copyWith(isValid: false, errorMessage: 'Please enter your class');
    }
    if (s.schoolName.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your school name');
    }
    if (s.academicPerformance.isEmpty) {
      return s.copyWith(
          isValid: false,
          errorMessage: 'Please enter your academic performance');
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
