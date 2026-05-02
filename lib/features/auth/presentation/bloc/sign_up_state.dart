import 'package:equatable/equatable.dart';

enum SignUpStatus { idle, loading, navigateToPhone, comingSoon, failure }

class SignUpState extends Equatable {
  const SignUpState({
    this.status = SignUpStatus.idle,
    this.errorMessage,
  });

  final SignUpStatus status;
  final String? errorMessage;

  SignUpState copyWith({
    SignUpStatus? status,
    String? errorMessage,
  }) =>
      SignUpState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, errorMessage];
}
