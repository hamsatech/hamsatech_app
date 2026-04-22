import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthOtpSending extends AuthState {
  const AuthOtpSending();
}

class AuthOtpSent extends AuthState {
  const AuthOtpSent(this.phoneOrEmail);
  final String phoneOrEmail;
  @override
  List<Object?> get props => [phoneOrEmail];
}

class AuthVerifying extends AuthState {
  const AuthVerifying();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
