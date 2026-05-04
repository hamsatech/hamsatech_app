import 'package:equatable/equatable.dart';

abstract class BaselineEvent extends Equatable {
  const BaselineEvent();

  @override
  List<Object?> get props => [];
}

class OnStartPressed extends BaselineEvent {
  const OnStartPressed();
}

// Fired by the internal Timer.periodic every second
class OnTick extends BaselineEvent {
  const OnTick();
}

// Dispatched by the BLoC itself when the timer reaches zero
class OnCaptureCompleted extends BaselineEvent {
  const OnCaptureCompleted();
}

// Fired when the user taps "Continue" on the success screen
class OnContinuePressed extends BaselineEvent {
  const OnContinuePressed();
}
