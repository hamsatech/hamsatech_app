import 'package:equatable/equatable.dart';

class MentalSocialProfileState extends Equatable {
  final String friendCircle;
  final String angerPattern;
  final String sadnessPattern;
  final String reasonForShooting;
  final String athleteGoal;

  final String stepTitle;
  final double progress;

  final String heading;
  final String subtitle;

  final String friendCircleLabel;
  final String friendCircleHint;

  final String angerPatternLabel;
  final String angerPatternHint;

  final String sadnessPatternLabel;
  final String sadnessPatternHint;

  final String reasonForShootingLabel;
  final String reasonForShootingHint;

  final String athleteGoalLabel;
  final String athleteGoalHint;

  final String ctaLabel;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;
  final bool isSubmitting;

  const MentalSocialProfileState({
    this.friendCircle = '',
    this.angerPattern = '',
    this.sadnessPattern = '',
    this.reasonForShooting = '',
    this.athleteGoal = '',
    this.stepTitle = 'STEP 6 OF 6',
    this.progress = 6 / 6,
    this.heading = 'Mental & Social Profile',
    this.subtitle = 'Understanding your mindset helps us coach you better.',
    this.friendCircleLabel = 'Friend Circle',
    this.friendCircleHint = 'e.g. Small and close-knit',
    this.angerPatternLabel = 'Anger Pattern',
    this.angerPatternHint = 'How do you handle anger?',
    this.sadnessPatternLabel = 'Sadness Pattern',
    this.sadnessPatternHint = 'How do you handle setbacks?',
    this.reasonForShootingLabel = 'Reason For Shooting',
    this.reasonForShootingHint = 'Why do you love this sport?',
    this.athleteGoalLabel = 'Athlete Goal',
    this.athleteGoalHint = 'Your ultimate athlete goal',
    this.ctaLabel = 'Submit',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
    this.isSubmitting = false,
  });

  MentalSocialProfileState copyWith({
    String? friendCircle,
    String? angerPattern,
    String? sadnessPattern,
    String? reasonForShooting,
    String? athleteGoal,
    String? stepTitle,
    double? progress,
    String? heading,
    String? subtitle,
    String? friendCircleLabel,
    String? friendCircleHint,
    String? angerPatternLabel,
    String? angerPatternHint,
    String? sadnessPatternLabel,
    String? sadnessPatternHint,
    String? reasonForShootingLabel,
    String? reasonForShootingHint,
    String? athleteGoalLabel,
    String? athleteGoalHint,
    String? ctaLabel,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
    bool? isSubmitting,
  }) {
    return MentalSocialProfileState(
      friendCircle: friendCircle ?? this.friendCircle,
      angerPattern: angerPattern ?? this.angerPattern,
      sadnessPattern: sadnessPattern ?? this.sadnessPattern,
      reasonForShooting: reasonForShooting ?? this.reasonForShooting,
      athleteGoal: athleteGoal ?? this.athleteGoal,
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      heading: heading ?? this.heading,
      subtitle: subtitle ?? this.subtitle,
      friendCircleLabel: friendCircleLabel ?? this.friendCircleLabel,
      friendCircleHint: friendCircleHint ?? this.friendCircleHint,
      angerPatternLabel: angerPatternLabel ?? this.angerPatternLabel,
      angerPatternHint: angerPatternHint ?? this.angerPatternHint,
      sadnessPatternLabel: sadnessPatternLabel ?? this.sadnessPatternLabel,
      sadnessPatternHint: sadnessPatternHint ?? this.sadnessPatternHint,
      reasonForShootingLabel:
          reasonForShootingLabel ?? this.reasonForShootingLabel,
      reasonForShootingHint:
          reasonForShootingHint ?? this.reasonForShootingHint,
      athleteGoalLabel: athleteGoalLabel ?? this.athleteGoalLabel,
      athleteGoalHint: athleteGoalHint ?? this.athleteGoalHint,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        friendCircle,
        angerPattern,
        sadnessPattern,
        reasonForShooting,
        athleteGoal,
        stepTitle,
        progress,
        heading,
        subtitle,
        friendCircleLabel,
        friendCircleHint,
        angerPatternLabel,
        angerPatternHint,
        sadnessPatternLabel,
        sadnessPatternHint,
        reasonForShootingLabel,
        reasonForShootingHint,
        athleteGoalLabel,
        athleteGoalHint,
        ctaLabel,
        isValid,
        errorMessage,
        submissionSuccess,
        isSubmitting,
      ];
}
