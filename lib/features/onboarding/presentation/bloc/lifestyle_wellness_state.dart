import 'package:equatable/equatable.dart';

class LifestyleWellnessState extends Equatable {
  final String dietType;
  final String outsideFoodFrequency;
  final String sleepTime;
  final String wakeTime;

  final String stepTitle;
  final double progress;

  final String heading;
  final String subtitle;

  final String dietTypeLabel;
  final String dietTypeHint;

  final String outsideFoodFrequencyLabel;
  final String outsideFoodFrequencyHint;

  final String sleepTimeLabel;
  final String sleepTimeHint;

  final String wakeTimeLabel;
  final String wakeTimeHint;

  final String ctaLabel;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;
  final bool isSubmitting;

  const LifestyleWellnessState({
    this.dietType = '',
    this.outsideFoodFrequency = '',
    this.sleepTime = '',
    this.wakeTime = '',
    this.stepTitle = 'STEP 5 OF 6',
    this.progress = 5 / 6,
    this.heading = 'Lifestyle & Wellness',
    this.subtitle = 'Good rest and nutrition are key to performance.',
    this.dietTypeLabel = 'Diet Type',
    this.dietTypeHint = 'e.g. Vegetarian',
    this.outsideFoodFrequencyLabel = 'Outside Food Frequency',
    this.outsideFoodFrequencyHint = 'e.g. Rarely / 2-3 times a week',
    this.sleepTimeLabel = 'Sleep Time',
    this.sleepTimeHint = 'e.g. 10:30 PM',
    this.wakeTimeLabel = 'Wake Time',
    this.wakeTimeHint = 'e.g. 6:00 AM',
    this.ctaLabel = 'Continue to Step 6',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
    this.isSubmitting = false,
  });

  LifestyleWellnessState copyWith({
    String? dietType,
    String? outsideFoodFrequency,
    String? sleepTime,
    String? wakeTime,
    String? stepTitle,
    double? progress,
    String? heading,
    String? subtitle,
    String? dietTypeLabel,
    String? dietTypeHint,
    String? outsideFoodFrequencyLabel,
    String? outsideFoodFrequencyHint,
    String? sleepTimeLabel,
    String? sleepTimeHint,
    String? wakeTimeLabel,
    String? wakeTimeHint,
    String? ctaLabel,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
    bool? isSubmitting,
  }) {
    return LifestyleWellnessState(
      dietType: dietType ?? this.dietType,
      outsideFoodFrequency:
          outsideFoodFrequency ?? this.outsideFoodFrequency,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      heading: heading ?? this.heading,
      subtitle: subtitle ?? this.subtitle,
      dietTypeLabel: dietTypeLabel ?? this.dietTypeLabel,
      dietTypeHint: dietTypeHint ?? this.dietTypeHint,
      outsideFoodFrequencyLabel:
          outsideFoodFrequencyLabel ?? this.outsideFoodFrequencyLabel,
      outsideFoodFrequencyHint:
          outsideFoodFrequencyHint ?? this.outsideFoodFrequencyHint,
      sleepTimeLabel: sleepTimeLabel ?? this.sleepTimeLabel,
      sleepTimeHint: sleepTimeHint ?? this.sleepTimeHint,
      wakeTimeLabel: wakeTimeLabel ?? this.wakeTimeLabel,
      wakeTimeHint: wakeTimeHint ?? this.wakeTimeHint,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        dietType,
        outsideFoodFrequency,
        sleepTime,
        wakeTime,
        stepTitle,
        progress,
        heading,
        subtitle,
        dietTypeLabel,
        dietTypeHint,
        outsideFoodFrequencyLabel,
        outsideFoodFrequencyHint,
        sleepTimeLabel,
        sleepTimeHint,
        wakeTimeLabel,
        wakeTimeHint,
        ctaLabel,
        isValid,
        errorMessage,
        submissionSuccess,
        isSubmitting,
      ];
}
