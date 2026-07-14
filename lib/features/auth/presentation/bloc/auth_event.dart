import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSendOtpRequested extends AuthEvent {
  const AuthSendOtpRequested(this.phoneOrEmail);
  final String phoneOrEmail;
  @override
  List<Object?> get props => [phoneOrEmail];
}

class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested({
    required this.phoneOrEmail,
    required this.otp,
  });
  final String phoneOrEmail;
  final String otp;
  @override
  List<Object?> get props => [phoneOrEmail, otp];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGetProfileRequested extends AuthEvent {
  const AuthGetProfileRequested(this.athleteId);
  final String athleteId;
  @override
  List<Object?> get props => [athleteId];
}

class AuthUpdateProfileRequested extends AuthEvent {
  const AuthUpdateProfileRequested({
    required this.athleteId,
    required this.updates,
  });
  final String athleteId;
  final Map<String, dynamic> updates;
  @override
  List<Object?> get props => [athleteId, updates];
}
