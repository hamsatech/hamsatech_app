import 'package:equatable/equatable.dart';
import '../../domain/models/hr_reading.dart';

abstract class PolarEvent extends Equatable {
  const PolarEvent();

  @override
  List<Object?> get props => [];
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
