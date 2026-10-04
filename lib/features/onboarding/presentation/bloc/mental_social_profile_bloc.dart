import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
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
    on<OnLoadOnboarding>(_onLoadOnboarding);
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

  Future<void> _onLoadOnboarding(
    OnLoadOnboarding event,
    Emitter<MentalSocialProfileState> emit,
  ) async {
    try {
      final res = await ApiService.instance.getOnboardingStatus();
      final data = res.data as Map<String, dynamic>;

      final friendCircle = data['friend_circle'] as String?;
      final angerPattern = data['anger_pattern'] as String?;
      final sadnessPattern = data['sadness_pattern'] as String?;
      final reasonForShooting = data['reason_for_shooting'] as String?;
      final athleteGoal = data['athlete_goal'] as String?;

      if (friendCircle == null &&
          angerPattern == null &&
          sadnessPattern == null &&
          reasonForShooting == null &&
          athleteGoal == null) {
        return;
      }

      final next = state.copyWith(
        friendCircle: friendCircle ?? state.friendCircle,
        angerPattern: angerPattern ?? state.angerPattern,
        sadnessPattern: sadnessPattern ?? state.sadnessPattern,
        reasonForShooting: reasonForShooting ?? state.reasonForShooting,
        athleteGoal: athleteGoal ?? state.athleteGoal,
      );
      emit(_validate(next));
      debugPrint('[MENTAL SOCIAL PROFILE] prefilled from GET /onboarding');
    } catch (e) {
      debugPrint(
          '[MENTAL SOCIAL PROFILE] GET onboarding failed (non-fatal): $e');
    }
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

    emit(validated.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await ApiService.instance.saveOnboardingStep6(
        friendCircle: validated.friendCircle,
        angerPattern: validated.angerPattern,
        sadnessPattern: validated.sadnessPattern,
        reasonForShooting: validated.reasonForShooting,
        athleteGoal: validated.athleteGoal,
      );
      emit(validated.copyWith(isSubmitting: false, submissionSuccess: true));
    } catch (e) {
      debugPrint('[MENTAL SOCIAL PROFILE] PUT step-6 failed: $e');
      emit(validated.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
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
