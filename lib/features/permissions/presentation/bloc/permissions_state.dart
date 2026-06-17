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
    this.bluetoothGranted = false,
    this.notificationsGranted = false,
    this.microphoneGranted = false,
    this.bluetoothLoading = false,
    this.notificationsLoading = false,
    this.microphoneLoading = false,
  });

  final PermissionsStatus status;
  final String? message;

  final bool bluetoothGranted;
  final bool notificationsGranted;
  final bool microphoneGranted;

  final bool bluetoothLoading;
  final bool notificationsLoading;
  final bool microphoneLoading;

  PermissionsState copyWith({
    PermissionsStatus? status,
    String? message,
    bool? bluetoothGranted,
    bool? notificationsGranted,
    bool? microphoneGranted,
    bool? bluetoothLoading,
    bool? notificationsLoading,
    bool? microphoneLoading,
  }) {
    return PermissionsState(
      status: status ?? this.status,
      message: message ?? this.message,
      bluetoothGranted: bluetoothGranted ?? this.bluetoothGranted,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      bluetoothLoading: bluetoothLoading ?? this.bluetoothLoading,
      notificationsLoading: notificationsLoading ?? this.notificationsLoading,
      microphoneLoading: microphoneLoading ?? this.microphoneLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        bluetoothGranted,
        notificationsGranted,
        microphoneGranted,
        bluetoothLoading,
        notificationsLoading,
        microphoneLoading,
      ];
}
