import 'package:equatable/equatable.dart';

class AcademicProfileState extends Equatable {
  final String className;
  final String schoolName;
  final String academicPerformance;

  // UI text / labels must come from state (no hardcoded UI strings)
  final String stepTitle;
  final double progress;

  final String heading;
  final String subtitle;

  final String classLabel;
  final String classHint;

  final String schoolNameLabel;
  final String schoolNameHint;

  final String academicPerformanceLabel;
  final String academicPerformanceHint;

  final String ctaLabel;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;
  final bool isSubmitting;

  const AcademicProfileState({
    this.className = '',
    this.schoolName = '',
    this.academicPerformance = '',
    this.stepTitle = 'STEP 4 OF 6',
    this.progress = 4 / 6,
    this.heading = 'Academic Profile',
    this.subtitle = 'Tell us about your academic background.',
    this.classLabel = 'Class',
    this.classHint = 'e.g. 10th Grade',
    this.schoolNameLabel = 'School Name',
    this.schoolNameHint = 'e.g. Springfield High School',
    this.academicPerformanceLabel = 'Academic Performance',
    this.academicPerformanceHint = 'e.g. Above Average',
    this.ctaLabel = 'Continue to Step 5',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
    this.isSubmitting = false,
  });

  AcademicProfileState copyWith({
    String? className,
    String? schoolName,
    String? academicPerformance,
    String? stepTitle,
    double? progress,
    String? heading,
    String? subtitle,
    String? classLabel,
    String? classHint,
    String? schoolNameLabel,
    String? schoolNameHint,
    String? academicPerformanceLabel,
    String? academicPerformanceHint,
    String? ctaLabel,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
    bool? isSubmitting,
  }) {
    return AcademicProfileState(
      className: className ?? this.className,
      schoolName: schoolName ?? this.schoolName,
      academicPerformance: academicPerformance ?? this.academicPerformance,
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      heading: heading ?? this.heading,
      subtitle: subtitle ?? this.subtitle,
      classLabel: classLabel ?? this.classLabel,
      classHint: classHint ?? this.classHint,
      schoolNameLabel: schoolNameLabel ?? this.schoolNameLabel,
      schoolNameHint: schoolNameHint ?? this.schoolNameHint,
      academicPerformanceLabel:
          academicPerformanceLabel ?? this.academicPerformanceLabel,
      academicPerformanceHint:
          academicPerformanceHint ?? this.academicPerformanceHint,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        className,
        schoolName,
        academicPerformance,
        stepTitle,
        progress,
        heading,
        subtitle,
        classLabel,
        classHint,
        schoolNameLabel,
        schoolNameHint,
        academicPerformanceLabel,
        academicPerformanceHint,
        ctaLabel,
        isValid,
        errorMessage,
        submissionSuccess,
        isSubmitting,
      ];
}
