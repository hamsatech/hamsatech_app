import 'package:equatable/equatable.dart';

/// A single academy option for the Step 2 picker, as returned by
/// GET /api/v2/academies (AcademyResponse: academyId, academyName).
class AcademyOption extends Equatable {
  final String id;
  final String name;

  const AcademyOption({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class OnboardingStep2State extends Equatable {
  final String discipline;
  final String experience;
  final int yearsShoot;
  final String academy;
  final String? academyId;
  final List<AcademyOption> academies;
  final bool isSubmitting;

  final String stepTitle;
  final double progress;
  final String heading;
  final String subtitle;

  final String disciplineLabel;
  final String disciplineHint;
  final String disciplineHelperText;
  final List<String> disciplineOptions;

  final String experienceLabel;
  final List<String> experienceOptions;

  final String yearsLabel;

  final String academyLabel;
  final String academyOptionalText;
  final String academyHint;

  final String ctaLabel;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;

  const OnboardingStep2State({
    this.discipline = '',
    this.experience = '',
    this.yearsShoot = 0,
    this.academy = '',
    this.academyId,
    this.academies = const [],
    this.isSubmitting = false,
    this.stepTitle = 'STEP 2 OF 6',
    this.progress = 2 / 6,
    this.heading = 'Your Athletic Background',
    this.subtitle =
        'Help us understand your sport history and current training setup.',
    this.disciplineLabel = 'Discipline',
    this.disciplineHint = 'Air Pistol',
    this.disciplineHelperText = 'select your primary shooting event',
    this.disciplineOptions = const [
      'Air Pistol',
      'Air Rifle',
      '10m Air Pistol',
      '25m Pistol',
      '50m Rifle 3 Positions',
      'Trap',
      'Skeet',
      'Double Trap',
    ],
    this.experienceLabel = 'Experience Level',
    this.experienceOptions = const ['Beginner', 'Intermediate', 'Advance'],
    this.yearsLabel = 'Years shooting',
    this.academyLabel = 'Academy / Club',
    this.academyOptionalText = 'optional',
    this.academyHint = 'Enter your academy or club',
    this.ctaLabel = 'Continue to Step 3',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
  });

  OnboardingStep2State copyWith({
    String? discipline,
    String? experience,
    int? yearsShoot,
    String? academy,
    String? academyId,
    List<AcademyOption>? academies,
    bool? isSubmitting,
    String? stepTitle,
    double? progress,
    String? heading,
    String? subtitle,
    String? disciplineLabel,
    String? disciplineHint,
    String? disciplineHelperText,
    List<String>? disciplineOptions,
    String? experienceLabel,
    List<String>? experienceOptions,
    String? yearsLabel,
    String? academyLabel,
    String? academyOptionalText,
    String? academyHint,
    String? ctaLabel,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
  }) {
    return OnboardingStep2State(
      discipline: discipline ?? this.discipline,
      experience: experience ?? this.experience,
      yearsShoot: yearsShoot ?? this.yearsShoot,
      academy: academy ?? this.academy,
      academyId: academyId ?? this.academyId,
      academies: academies ?? this.academies,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      heading: heading ?? this.heading,
      subtitle: subtitle ?? this.subtitle,
      disciplineLabel: disciplineLabel ?? this.disciplineLabel,
      disciplineHint: disciplineHint ?? this.disciplineHint,
      disciplineHelperText: disciplineHelperText ?? this.disciplineHelperText,
      disciplineOptions: disciplineOptions ?? this.disciplineOptions,
      experienceLabel: experienceLabel ?? this.experienceLabel,
      experienceOptions: experienceOptions ?? this.experienceOptions,
      yearsLabel: yearsLabel ?? this.yearsLabel,
      academyLabel: academyLabel ?? this.academyLabel,
      academyOptionalText: academyOptionalText ?? this.academyOptionalText,
      academyHint: academyHint ?? this.academyHint,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  List<Object?> get props => [
        discipline,
        experience,
        yearsShoot,
        academy,
        academyId,
        academies,
        isSubmitting,
        stepTitle,
        progress,
        heading,
        subtitle,
        disciplineLabel,
        disciplineHint,
        disciplineHelperText,
        disciplineOptions,
        experienceLabel,
        experienceOptions,
        yearsLabel,
        academyLabel,
        academyOptionalText,
        academyHint,
        ctaLabel,
        isValid,
        errorMessage,
        submissionSuccess,
      ];
}
