import 'package:equatable/equatable.dart';

abstract class OnboardingCompletionEvent extends Equatable {
  const OnboardingCompletionEvent();

  @override
  List<Object?> get props => [];
}

class OnGoHomePressed extends OnboardingCompletionEvent {
  const OnGoHomePressed();
}
