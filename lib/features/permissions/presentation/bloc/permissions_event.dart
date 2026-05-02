import 'package:equatable/equatable.dart';

abstract class PermissionsEvent extends Equatable {
  const PermissionsEvent();

  @override
  List<Object?> get props => [];
}

class OnBluetoothTapped extends PermissionsEvent {
  const OnBluetoothTapped();
}

class OnNotificationsTapped extends PermissionsEvent {
  const OnNotificationsTapped();
}

class OnMicrophoneTapped extends PermissionsEvent {
  const OnMicrophoneTapped();
}

class OnContinuePressed extends PermissionsEvent {
  const OnContinuePressed();
}
