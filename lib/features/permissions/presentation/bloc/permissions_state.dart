import 'package:equatable/equatable.dart';

enum PermissionsStatus {
  idle,
  loading,
  success,
  error,
}

class PermissionsState extends Equatable {
  const PermissionsState({
    this.status = PermissionsStatus.idle,
    this.message,
  });

  final PermissionsStatus status;
  final String? message;

  PermissionsState copyWith({
    PermissionsStatus? status,
    String? message,
  }) {
    return PermissionsState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
