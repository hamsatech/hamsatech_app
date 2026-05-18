import 'package:equatable/equatable.dart';

enum OnboardingGender { male, female, other, unknown }

class OnboardingStep1State extends Equatable {
  final String name;
  final String age;
  final OnboardingGender gender;
  final String city;
  // UI text / labels must come from state (no hardcoded UI strings)
  final String stepTitle;
  final double progress;

  final String heading;
  final String subtitle;

  final String nameLabel;
  final String nameHint;

  final String ageLabel;
  final String ageHint;

  final String genderLabel;
  final List<String> genderOptions;

  final String cityLabel;
  final String cityHint;

  final String ctaLabel;

  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submissionSuccess;

  const OnboardingStep1State({
    this.name = '',
    this.age = '',
    this.gender = OnboardingGender.unknown,
    this.city = '',
    this.stepTitle = 'STEP 1 OF 4',
    this.progress = 0.2,

    this.heading = 'Welcome to Astra Performance.',
    this.subtitle = 'Let\'s build your baseline—connect your sensor and complete a quick assessment so we can show you what\'s driving your results.',

    this.nameLabel = 'Full Name',
    this.nameHint = 'e.g. Jane Doe',

    this.ageLabel = 'Age',
    this.ageHint = 'Enter your age',

    this.genderLabel = 'Gender',
    this.genderOptions = const ['male', 'female', 'other'],

    this.cityLabel = 'City',
    this.cityHint = 'Where do you live?',

    this.ctaLabel = 'Continue to Step 2',

    this.isValid = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submissionSuccess = false,
  });

  OnboardingStep1State copyWith({
    String? name,
    String? age,
    OnboardingGender? gender,
    String? city,
    String? stepTitle,
    double? progress,

    String? heading,
    String? subtitle,

    String? nameLabel,
    String? nameHint,

    String? ageLabel,
    String? ageHint,

    String? genderLabel,
    List<String>? genderOptions,

    String? cityLabel,
    String? cityHint,

    String? ctaLabel,

    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
    bool? submissionSuccess,
  }) {
    return OnboardingStep1State(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,

      heading: heading ?? this.heading,
      subtitle: subtitle ?? this.subtitle,

      nameLabel: nameLabel ?? this.nameLabel,
      nameHint: nameHint ?? this.nameHint,

      ageLabel: ageLabel ?? this.ageLabel,
      ageHint: ageHint ?? this.ageHint,

      genderLabel: genderLabel ?? this.genderLabel,
      genderOptions: genderOptions ?? this.genderOptions,

      cityLabel: cityLabel ?? this.cityLabel,
      cityHint: cityHint ?? this.cityHint,

      ctaLabel: ctaLabel ?? this.ctaLabel,

      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  List<Object?> get props => [
        name,
        age,
        gender,
        city,
        stepTitle,
        progress,
        heading,
        subtitle,
        nameLabel,
        nameHint,
        ageLabel,
        ageHint,
        genderLabel,
        genderOptions,
        cityLabel,
        cityHint,
        ctaLabel,
        isValid,
        isSubmitting,
        errorMessage,
        submissionSuccess,
      ];
}
