import 'package:equatable/equatable.dart';
import '../../domain/models/hr_reading.dart';

enum PolarConnectionStatus { initial, connecting, connected, disconnected, error }

class PolarState extends Equatable {
  final PolarConnectionStatus connectionStatus;
  final String? connectedDeviceId;
  final bool isStreaming;
  final HrReading? latestReading;
  final List<HrReading> hrHistory;
  final String? errorMessage;

  const PolarState({
    this.connectionStatus = PolarConnectionStatus.initial,
    this.connectedDeviceId,
    this.isStreaming = false,
    this.latestReading,
    this.hrHistory = const [],
    this.errorMessage,
  });

  PolarState copyWith({
    PolarConnectionStatus? connectionStatus,
    String? connectedDeviceId,
    bool? isStreaming,
    HrReading? latestReading,
    List<HrReading>? hrHistory,
    String? errorMessage,
  }) {
    return PolarState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      isStreaming: isStreaming ?? this.isStreaming,
      latestReading: latestReading ?? this.latestReading,
      hrHistory: hrHistory ?? this.hrHistory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => connectionStatus == PolarConnectionStatus.connected;

  @override
  List<Object?> get props => [
        connectionStatus,
        connectedDeviceId,
        isStreaming,
        latestReading,
        hrHistory,
        errorMessage,
      ];
}
