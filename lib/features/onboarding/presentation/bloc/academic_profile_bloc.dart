import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import 'academic_profile_event.dart';
import 'academic_profile_state.dart';

class AcademicProfileBloc
    extends Bloc<AcademicProfileEvent, AcademicProfileState> {
  AcademicProfileBloc() : super(const AcademicProfileState()) {
    on<OnClassChanged>(_onClassChanged);
    on<OnSchoolNameChanged>(_onSchoolNameChanged);
    on<OnAcademicPerformanceChanged>(_onAcademicPerformanceChanged);
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

  Future<void> _onSubmit(
    OnAcademicProfileSubmit event,
    Emitter<AcademicProfileState> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    // No backend endpoint exists yet for this screen — store locally only.
    // TODO(onboarding-flow): wire to a real API once backend/product decide
    // where this screen sits in the onboarding sequence.
    await StorageService.saveAcademicProfile({
      'class': validated.className,
      'school_name': validated.schoolName,
      'academic_performance': validated.academicPerformance,
    });

    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
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
