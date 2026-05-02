import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/models/hr_reading.dart';

enum PolarDeviceStatus { connecting, connected, disconnected }

class PolarDeviceEvent {
  final PolarDeviceStatus status;
  final String deviceId;
  const PolarDeviceEvent(this.status, this.deviceId);
}

class PolarBleService {
  static const _methodChannel = MethodChannel('com.hamsatech/polar');
  static const _hrEventChannel = EventChannel('com.hamsatech/polar_hr_stream');

  final _deviceEventController = StreamController<PolarDeviceEvent>.broadcast();

  PolarBleService() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'deviceConnected':
          _deviceEventController.add(
            PolarDeviceEvent(PolarDeviceStatus.connected, call.arguments as String),
          );
        case 'deviceConnecting':
          _deviceEventController.add(
            PolarDeviceEvent(PolarDeviceStatus.connecting, call.arguments as String),
          );
        case 'deviceDisconnected':
          _deviceEventController.add(
            PolarDeviceEvent(PolarDeviceStatus.disconnected, call.arguments as String),
          );
      }
    });
  }

  Stream<PolarDeviceEvent> get deviceEvents => _deviceEventController.stream;

  Stream<HrReading> get hrStream => _hrEventChannel
      .receiveBroadcastStream()
      .map((event) => HrReading.fromMap(event as Map<dynamic, dynamic>));

  Future<void> connectToDevice(String deviceId) =>
      _methodChannel.invokeMethod('connect', {'deviceId': deviceId});

  Future<void> disconnectFromDevice(String deviceId) =>
      _methodChannel.invokeMethod('disconnect', {'deviceId': deviceId});

  Future<void> startHrStream(String deviceId) =>
      _methodChannel.invokeMethod('startHrStream', {'deviceId': deviceId});

  Future<void> stopHrStream() =>
      _methodChannel.invokeMethod('stopHrStream');

  void dispose() => _deviceEventController.close();
}
