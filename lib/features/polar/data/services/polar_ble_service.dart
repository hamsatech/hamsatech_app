import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/hr_reading.dart';

enum PolarDeviceStatus {
  found,
  connecting,
  connected,
  disconnected,
  bluetoothOff,
}

class PolarDeviceEvent {
  final PolarDeviceStatus status;
  // Null for events not tied to a specific device (e.g. bluetoothOff).
  final String? deviceId;
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
    // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
    debugPrint(
        '[PolarDebug] PolarBleService() constructor running, instance=${identityHashCode(this)}, channel=${_methodChannel.name}, at ${DateTime.now()}');
    _methodChannel.setMethodCallHandler((call) async {
      // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
      debugPrint(
          '[PolarDebug] handler(instance=${identityHashCode(this)}) received native call: method=${call.method} args=${call.arguments} at ${DateTime.now()}');
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
            PolarDeviceEvent(
                PolarDeviceStatus.connected, call.arguments as String),
          );
        case 'deviceConnecting':
          _deviceEventController.add(
            PolarDeviceEvent(
                PolarDeviceStatus.connecting, call.arguments as String),
          );
        case 'deviceDisconnected':
          _deviceEventController.add(
            PolarDeviceEvent(
                PolarDeviceStatus.disconnected, call.arguments as String),
          );
        case 'blePowerStateChanged':
          final powered = call.arguments as bool;
          // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
          debugPrint('[PolarDebug] blePowerStateChanged case reached, powered=$powered');
          if (!powered) {
            _deviceEventController.add(
              const PolarDeviceEvent(PolarDeviceStatus.bluetoothOff, null),
            );
            debugPrint('[PolarDebug] bluetoothOff PolarDeviceEvent added to controller');
          }
      }
    });
    // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
    debugPrint(
        '[PolarDebug] setMethodCallHandler registration call completed, instance=${identityHashCode(this)}');
  }

  Stream<PolarDeviceEvent> get deviceEvents => _deviceEventController.stream;

  // Computed once and cached: EventChannel.receiveBroadcastStream() performs
  // a fresh native 'listen' registration on every call, and the native side
  // (PolarPlugin.kt) holds only a single EventSink reference — a second
  // registration silently replaces the first, starving whichever listener
  // subscribed earlier. Caching this Stream lets multiple independent
  // .listen() calls (PolarBloc, HrTelemetryService) share one underlying
  // broadcast controller and one native registration instead.
  late final Stream<HrReading> _hrStream = _hrEventChannel
      .receiveBroadcastStream()
      .map((event) => HrReading.fromMap(event as Map<dynamic, dynamic>));

  Stream<HrReading> get hrStream => _hrStream;

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
