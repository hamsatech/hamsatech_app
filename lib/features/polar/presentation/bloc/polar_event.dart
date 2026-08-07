import 'package:equatable/equatable.dart';
import '../../domain/models/hr_reading.dart';

abstract class PolarEvent extends Equatable {
  const PolarEvent();

  @override
  List<Object?> get props => [];
}

class PolarScanStarted extends PolarEvent {
  const PolarScanStarted();
}

class PolarScanStopped extends PolarEvent {
  const PolarScanStopped();
}

class PolarConnectRequested extends PolarEvent {
  const PolarConnectRequested(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}

class PolarDisconnectRequested extends PolarEvent {
  const PolarDisconnectRequested();
}

class PolarStartHrStreamRequested extends PolarEvent {
  const PolarStartHrStreamRequested();
}

class PolarStopHrStreamRequested extends PolarEvent {
  const PolarStopHrStreamRequested();
}

// Internal events from native callbacks
class PolarDeviceFoundEvent extends PolarEvent {
  const PolarDeviceFoundEvent({
    required this.deviceId,
    required this.name,
    this.deviceType,
  });
  final String deviceId;
  final String name;
  final String? deviceType;
  @override
  List<Object?> get props => [deviceId, name, deviceType];
}

class PolarDeviceConnectedEvent extends PolarEvent {
  const PolarDeviceConnectedEvent(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}

class PolarDeviceDisconnectedEvent extends PolarEvent {
  const PolarDeviceDisconnectedEvent(this.deviceId);
  final String deviceId;
  @override
  List<Object?> get props => [deviceId];
}

class PolarBluetoothOffEvent extends PolarEvent {
  const PolarBluetoothOffEvent();
}

class PolarConnectTimedOutEvent extends PolarEvent {
  const PolarConnectTimedOutEvent();
}

class PolarDisconnectTimedOutEvent extends PolarEvent {
  const PolarDisconnectTimedOutEvent();
}

class PolarHrReceivedEvent extends PolarEvent {
  const PolarHrReceivedEvent(this.reading);
  final HrReading reading;
  @override
  List<Object?> get props => [reading];
}

class PolarHrErrorEvent extends PolarEvent {
  const PolarHrErrorEvent(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class PolarDemoConnectRequested extends PolarEvent {
  const PolarDemoConnectRequested();
}
