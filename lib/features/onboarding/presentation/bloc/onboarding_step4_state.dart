import 'package:equatable/equatable.dart';

class OnboardingStep4State extends Equatable {
  final String stepTitle;
  final double progress;

  final String title;
  final String subtitle;

  final String goal30Label;
  final String goal30Hint;
  final String goal30Tag;
  final String goal30Value;

  final String goal6MonthLabel;
  final String goal6MonthHint;
  final String goal6MonthTag;
  final String goal6MonthValue;

  final String tipText;
  final String ctaText;
  final String helperText;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;

  const OnboardingStep4State({
    this.stepTitle = 'STEP 4 OF 4',
    this.progress = 1.0,
    this.title = 'Set your goals',
    this.subtitle =
        'Specific goals give your training direction. We\'ll help you track progress and adjust.',
    this.goal30Label = '30-day target',
    this.goal30Hint = 'Example: Average 575+ in competition',
    this.goal30Tag = 'Next 30 days',
    this.goal30Value = '',
    this.goal6MonthLabel = '6-month target',
    this.goal6MonthHint = 'Example: Compete at nationals with 590+ average',
    this.goal6MonthTag = '6 months',
    this.goal6MonthValue = '',
    this.tipText =
        '💡 Tip: Best goals are specific and measurable. Examples: "Score 580+ at State Meet" or "Reduce heart rate variance by 15%."',
    this.ctaText = 'Continue',
    this.helperText = 'You can update your goals anytime',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
  });

  OnboardingStep4State copyWith({
    String? stepTitle,
    double? progress,
    String? title,
    String? subtitle,
    String? goal30Label,
    String? goal30Hint,
    String? goal30Tag,
    String? goal30Value,
    String? goal6MonthLabel,
    String? goal6MonthHint,
    String? goal6MonthTag,
    String? goal6MonthValue,
    String? tipText,
    String? ctaText,
    String? helperText,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
  }) {
    return OnboardingStep4State(
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      goal30Label: goal30Label ?? this.goal30Label,
      goal30Hint: goal30Hint ?? this.goal30Hint,
      goal30Tag: goal30Tag ?? this.goal30Tag,
      goal30Value: goal30Value ?? this.goal30Value,
      goal6MonthLabel: goal6MonthLabel ?? this.goal6MonthLabel,
      goal6MonthHint: goal6MonthHint ?? this.goal6MonthHint,
      goal6MonthTag: goal6MonthTag ?? this.goal6MonthTag,
      goal6MonthValue: goal6MonthValue ?? this.goal6MonthValue,
      tipText: tipText ?? this.tipText,
      ctaText: ctaText ?? this.ctaText,
      helperText: helperText ?? this.helperText,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  List<Object?> get props => [
        stepTitle,
        progress,
        title,
        subtitle,
        goal30Label,
        goal30Hint,
        goal30Tag,
        goal30Value,
        goal6MonthLabel,
        goal6MonthHint,
        goal6MonthTag,
        goal6MonthValue,
        tipText,
        ctaText,
        helperText,
        isValid,
        errorMessage,
        submissionSuccess,
      ];
}
