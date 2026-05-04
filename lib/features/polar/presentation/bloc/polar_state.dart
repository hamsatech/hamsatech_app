import 'package:equatable/equatable.dart';
import '../../domain/models/hr_reading.dart';

enum PolarConnectionStatus { initial, scanning, connecting, connected, disconnected, error }

class PolarDiscoveredDevice extends Equatable {
  final String deviceId;
  final String name;
  final String? deviceType;

  const PolarDiscoveredDevice({
    required this.deviceId,
    required this.name,
    this.deviceType,
  });

  @override
  List<Object?> get props => [deviceId, name, deviceType];
}

class PolarState extends Equatable {
  final PolarConnectionStatus connectionStatus;
  final List<PolarDiscoveredDevice> discoveredDevices;
  final String? connectedDeviceId;
  final String? connectedDeviceName;
  final bool isStreaming;
  final HrReading? latestReading;
  final List<HrReading> hrHistory;
  final String? errorMessage;

  const PolarState({
    this.connectionStatus = PolarConnectionStatus.initial,
    this.discoveredDevices = const [],
    this.connectedDeviceId,
    this.connectedDeviceName,
    this.isStreaming = false,
    this.latestReading,
    this.hrHistory = const [],
    this.errorMessage,
  });

  PolarState copyWith({
    PolarConnectionStatus? connectionStatus,
    List<PolarDiscoveredDevice>? discoveredDevices,
    String? connectedDeviceId,
    String? connectedDeviceName,
    bool? isStreaming,
    HrReading? latestReading,
    List<HrReading>? hrHistory,
    String? errorMessage,
  }) {
    return PolarState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      isStreaming: isStreaming ?? this.isStreaming,
      latestReading: latestReading ?? this.latestReading,
      hrHistory: hrHistory ?? this.hrHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => connectionStatus == PolarConnectionStatus.connected;
  bool get isScanning => connectionStatus == PolarConnectionStatus.scanning;
  bool get isConnecting => connectionStatus == PolarConnectionStatus.connecting;

  @override
  List<Object?> get props => [
        connectionStatus,
        discoveredDevices,
        connectedDeviceId,
        connectedDeviceName,
        isStreaming,
        latestReading,
        hrHistory,
        errorMessage,
      ];
}
