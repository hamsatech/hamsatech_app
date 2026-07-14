import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import 'mental_social_profile_event.dart';
import 'mental_social_profile_state.dart';

class MentalSocialProfileBloc
    extends Bloc<MentalSocialProfileEvent, MentalSocialProfileState> {
  MentalSocialProfileBloc() : super(const MentalSocialProfileState()) {
    on<OnFriendCircleChanged>(_onFriendCircleChanged);
    on<OnAngerPatternChanged>(_onAngerPatternChanged);
    on<OnSadnessPatternChanged>(_onSadnessPatternChanged);
    on<OnReasonForShootingChanged>(_onReasonForShootingChanged);
    on<OnAthleteGoalChanged>(_onAthleteGoalChanged);
    on<OnMentalSocialProfileSubmit>(_onSubmit);
  }

  void _onFriendCircleChanged(
    OnFriendCircleChanged event,
    Emitter<MentalSocialProfileState> emit,
  ) {
    final next =
        state.copyWith(friendCircle: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onAngerPatternChanged(
    OnAngerPatternChanged event,
    Emitter<MentalSocialProfileState> emit,
  ) {
    final next =
        state.copyWith(angerPattern: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onSadnessPatternChanged(
    OnSadnessPatternChanged event,
    Emitter<MentalSocialProfileState> emit,
  ) {
    final next = state.copyWith(
        sadnessPattern: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onReasonForShootingChanged(
    OnReasonForShootingChanged event,
    Emitter<MentalSocialProfileState> emit,
  ) {
    final next = state.copyWith(
        reasonForShooting: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  void _onAthleteGoalChanged(
    OnAthleteGoalChanged event,
    Emitter<MentalSocialProfileState> emit,
  ) {
    final next =
        state.copyWith(athleteGoal: event.value.trim(), errorMessage: null);
    emit(_validate(next));
  }

  Future<void> _onSubmit(
    OnMentalSocialProfileSubmit event,
    Emitter<MentalSocialProfileState> emit,
  ) async {
    final validated = _validate(state);
    if (!validated.isValid) {
      emit(validated.copyWith(errorMessage: validated.errorMessage));
      return;
    }

    // No backend endpoint exists yet for this screen — store locally only.
    // Onboarding-completion logic is untouched: it fires from Step 3 (reused
    // OnboardingStep4Bloc → ApiService.saveOnboardingGoals) earlier in the
    // flow. This Submit only persists this screen's own fields and advances
    // to /questions.
    await StorageService.saveMentalSocialProfile({
      'friend_circle': validated.friendCircle,
      'anger_pattern': validated.angerPattern,
      'sadness_pattern': validated.sadnessPattern,
      'reason_for_shooting': validated.reasonForShooting,
      'athlete_goal': validated.athleteGoal,
    });

    emit(validated.copyWith(submissionSuccess: false, errorMessage: null));
    emit(validated.copyWith(submissionSuccess: true));
  }

  MentalSocialProfileState _validate(MentalSocialProfileState s) {
    if (s.friendCircle.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please describe your friend circle');
    }
    if (s.angerPattern.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please describe your anger pattern');
    }
    if (s.sadnessPattern.isEmpty) {
      return s.copyWith(
          isValid: false,
          errorMessage: 'Please describe your sadness pattern');
    }
    if (s.reasonForShooting.isEmpty) {
      return s.copyWith(
          isValid: false,
          errorMessage: 'Please share your reason for shooting');
    }
    if (s.athleteGoal.isEmpty) {
      return s.copyWith(
          isValid: false, errorMessage: 'Please enter your athlete goal');
    }
    return s.copyWith(isValid: true, errorMessage: null);
  }
}
