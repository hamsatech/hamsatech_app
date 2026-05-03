import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/models/hr_reading.dart';

enum PolarDeviceStatus { found, connecting, connected, disconnected }

class PolarDeviceEvent {
  final PolarDeviceStatus status;
  final String deviceId;
  final String? name;
  final String? deviceType;

  const PolarDeviceEvent(
    this.status,
    this.deviceId, {
    this.name,
    this.deviceType,
  });
}

class PolarBleService {
  static const _methodChannel = MethodChannel('com.hamsatech/polar');
  static const _hrEventChannel = EventChannel('com.hamsatech/polar_hr_stream');

  final _deviceEventController = StreamController<PolarDeviceEvent>.broadcast();

  PolarBleService() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'deviceFound':
          final args = call.arguments as Map<dynamic, dynamic>;
          _deviceEventController.add(PolarDeviceEvent(
            PolarDeviceStatus.found,
            args['deviceId'] as String,
            name: args['name'] as String?,
            deviceType: args['type'] as String?,
          ));
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

  Future<void> scanForDevices() => _methodChannel.invokeMethod('scan');

  Future<void> stopScan() => _methodChannel.invokeMethod('stopScan');

  Future<void> connectToDevice(String deviceId) =>
      _methodChannel.invokeMethod('connect', {'deviceId': deviceId});

  Future<void> disconnectFromDevice(String deviceId) =>
      _methodChannel.invokeMethod('disconnect', {'deviceId': deviceId});

  Future<void> startHrStream(String deviceId) =>
      _methodChannel.invokeMethod('startHrStream', {'deviceId': deviceId});

  Future<void> stopHrStream() => _methodChannel.invokeMethod('stopHrStream');

  void dispose() => _deviceEventController.close();
}
