import 'package:equatable/equatable.dart';

abstract class OnboardingStep3Event extends Equatable {
  const OnboardingStep3Event();

  @override
  List<Object?> get props => [];
}

class OnAvgScoreChanged extends OnboardingStep3Event {
  final String value;
  const OnAvgScoreChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnTargetScoreChanged extends OnboardingStep3Event {
  final String value;
  const OnTargetScoreChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnFactorToggled extends OnboardingStep3Event {
  final String factorId;
  const OnFactorToggled(this.factorId);

  @override
  List<Object?> get props => [factorId];
}

class OnStep3Submit extends OnboardingStep3Event {
  const OnStep3Submit();
}
