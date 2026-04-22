import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.phoneOrEmail,
    required this.token,
  });

  final String id;
  final String phoneOrEmail;
  final String token;

  @override
  List<Object?> get props => [id, phoneOrEmail, token];
}
