import 'package:equatable/equatable.dart';
import 'performance_factor_model.dart';

class OnboardingStep3State extends Equatable {
  final String stepTitle;
  final double progress;

  final String title;
  final String subtitle;

  final String avgScoreLabel;
  final String avgScoreHint;
  final String avgScore;

  final String targetScoreLabel;
  final String targetScoreHint;
  final String targetScore;

  final String factorTitle;
  final String factorSubtitle;
  final List<PerformanceFactorModel> factorOptions;
  final List<String> selectedFactors;
  final int maxFactorSelection;

  final String ctaLabel;

  final bool isValid;
  final String? errorMessage;
  final bool submissionSuccess;

  const OnboardingStep3State({
    this.stepTitle = 'STEP 3 OF 5',
    this.progress = 0.6,
    this.title = 'Where are you now?',
    this.subtitle =
        'Help us understand your current performance and the mental blocks holding you back.',
    this.avgScoreLabel = 'Average practice score',
    this.avgScoreHint = 'e.g. 560',
    this.avgScore = '',
    this.targetScoreLabel = 'Target score',
    this.targetScoreHint = 'e.g. 560',
    this.targetScore = '',
    this.factorTitle = 'Performance factors',
    this.factorSubtitle =
        'What affects your performance the most? (Pick up to 3)',
    this.factorOptions = const [
      PerformanceFactorModel(id: 'nervousness', label: 'Nervousness in competition'),
      PerformanceFactorModel(id: 'overthinking', label: 'Overthinking scores'),
      PerformanceFactorModel(id: 'poor_sleep', label: 'Poor sleep'),
      PerformanceFactorModel(id: 'distractions', label: 'Distractions'),
      PerformanceFactorModel(id: 'fear_losing', label: 'Fear of losing'),
      PerformanceFactorModel(id: 'lack_focus', label: 'Lack of focus'),
    ],
    this.selectedFactors = const [],
    this.maxFactorSelection = 3,
    this.ctaLabel = 'Continue to Step 4',
    this.isValid = false,
    this.errorMessage,
    this.submissionSuccess = false,
  });

  OnboardingStep3State copyWith({
    String? stepTitle,
    double? progress,
    String? title,
    String? subtitle,
    String? avgScoreLabel,
    String? avgScoreHint,
    String? avgScore,
    String? targetScoreLabel,
    String? targetScoreHint,
    String? targetScore,
    String? factorTitle,
    String? factorSubtitle,
    List<PerformanceFactorModel>? factorOptions,
    List<String>? selectedFactors,
    int? maxFactorSelection,
    String? ctaLabel,
    bool? isValid,
    String? errorMessage,
    bool? submissionSuccess,
  }) {
    return OnboardingStep3State(
      stepTitle: stepTitle ?? this.stepTitle,
      progress: progress ?? this.progress,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      avgScoreLabel: avgScoreLabel ?? this.avgScoreLabel,
      avgScoreHint: avgScoreHint ?? this.avgScoreHint,
      avgScore: avgScore ?? this.avgScore,
      targetScoreLabel: targetScoreLabel ?? this.targetScoreLabel,
      targetScoreHint: targetScoreHint ?? this.targetScoreHint,
      targetScore: targetScore ?? this.targetScore,
      factorTitle: factorTitle ?? this.factorTitle,
      factorSubtitle: factorSubtitle ?? this.factorSubtitle,
      factorOptions: factorOptions ?? this.factorOptions,
      selectedFactors: selectedFactors ?? this.selectedFactors,
      maxFactorSelection: maxFactorSelection ?? this.maxFactorSelection,
      ctaLabel: ctaLabel ?? this.ctaLabel,
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
        avgScoreLabel,
        avgScoreHint,
        avgScore,
        targetScoreLabel,
        targetScoreHint,
        targetScore,
        factorTitle,
        factorSubtitle,
        factorOptions,
        selectedFactors,
        maxFactorSelection,
        ctaLabel,
        isValid,
        errorMessage,
        submissionSuccess,
      ];
}
