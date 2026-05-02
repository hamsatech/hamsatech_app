import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpContinueTapped extends SignUpEvent {
  const SignUpContinueTapped();
}

class SignUpGoogleTapped extends SignUpEvent {
  const SignUpGoogleTapped();
}

class SignUpAppleTapped extends SignUpEvent {
  const SignUpAppleTapped();
}
