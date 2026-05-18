import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/polar_ble_service.dart';
import '../../domain/models/hr_reading.dart';
import 'polar_event.dart';
import 'polar_state.dart';

class PolarBloc extends Bloc<PolarEvent, PolarState> {
  PolarBloc(this._service) : super(const PolarState()) {
    on<PolarScanStarted>(_onScanStarted);
    on<PolarScanStopped>(_onScanStopped);
    on<PolarConnectRequested>(_onConnect);
    on<PolarDisconnectRequested>(_onDisconnect);
    on<PolarStartHrStreamRequested>(_onStartHrStream);
    on<PolarStopHrStreamRequested>(_onStopHrStream);
    on<PolarDeviceFoundEvent>(_onDeviceFound);
    on<PolarDeviceConnectedEvent>(_onDeviceConnected);
    on<PolarDeviceDisconnectedEvent>(_onDeviceDisconnected);
    on<PolarHrReceivedEvent>(_onHrReceived);
    on<PolarHrErrorEvent>(_onHrError);
    on<PolarDemoConnectRequested>(_onDemoConnect);

    _deviceSubscription = _service.deviceEvents.listen((event) {
      switch (event.status) {
        case PolarDeviceStatus.found:
          add(PolarDeviceFoundEvent(
            deviceId: event.deviceId,
            name: event.name ?? event.deviceId,
            deviceType: event.deviceType,
          ));
        case PolarDeviceStatus.connected:
          add(PolarDeviceConnectedEvent(event.deviceId));
        case PolarDeviceStatus.disconnected:
          add(PolarDeviceDisconnectedEvent(event.deviceId));
        case PolarDeviceStatus.connecting:
          break;
      }
    });
  }

  final PolarBleService _service;
  StreamSubscription<PolarDeviceEvent>? _deviceSubscription;
  StreamSubscription<HrReading>? _hrSubscription;
  Timer? _demoHrTimer;

  Future<void> _onScanStarted(
    PolarScanStarted event,
    Emitter<PolarState> emit,
  ) async {
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.scanning,
      discoveredDevices: [],
      errorMessage: null,
    ));
    try {
      await _service.scanForDevices();
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: PolarConnectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onScanStopped(
    PolarScanStopped event,
    Emitter<PolarState> emit,
  ) async {
    try {
      await _service.stopScan();
    } catch (_) {}
    if (state.isScanning) {
      emit(state.copyWith(connectionStatus: PolarConnectionStatus.initial));
    }
  }

  void _onDeviceFound(
    PolarDeviceFoundEvent event,
    Emitter<PolarState> emit,
  ) {
    if (state.discoveredDevices.any((d) => d.deviceId == event.deviceId)) return;
    emit(state.copyWith(
      discoveredDevices: [
        ...state.discoveredDevices,
        PolarDiscoveredDevice(
          deviceId: event.deviceId,
          name: event.name,
          deviceType: event.deviceType,
        ),
      ],
    ));
  }

  Future<void> _onConnect(
    PolarConnectRequested event,
    Emitter<PolarState> emit,
  ) async {
    final device = state.discoveredDevices.firstWhere(
      (d) => d.deviceId == event.deviceId,
      orElse: () =>
          PolarDiscoveredDevice(deviceId: event.deviceId, name: event.deviceId),
    );
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.connecting,
      connectedDeviceId: event.deviceId,
      connectedDeviceName: device.name,
      errorMessage: null,
    ));
    try {
      await _service.connectToDevice(event.deviceId);
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: PolarConnectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDisconnect(
    PolarDisconnectRequested event,
    Emitter<PolarState> emit,
  ) async {
    final deviceId = state.connectedDeviceId;
    if (deviceId == null) return;
    _demoHrTimer?.cancel();
    _demoHrTimer = null;
    await _hrSubscription?.cancel();
    _hrSubscription = null;
    try {
      await _service.stopHrStream();
      await _service.disconnectFromDevice(deviceId);
    } catch (_) {}
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.disconnected,
      isStreaming: false,
    ));
  }

  Future<void> _onStartHrStream(
    PolarStartHrStreamRequested event,
    Emitter<PolarState> emit,
  ) async {
    final deviceId = state.connectedDeviceId;
    if (deviceId == null || !state.isConnected) return;
    try {
      await _service.startHrStream(deviceId);
      await _hrSubscription?.cancel();
      _hrSubscription = _service.hrStream.listen(
        (reading) => add(PolarHrReceivedEvent(reading)),
        onError: (e) => add(PolarHrErrorEvent(e.toString())),
      );
      emit(state.copyWith(isStreaming: true));
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: PolarConnectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStopHrStream(
    PolarStopHrStreamRequested event,
    Emitter<PolarState> emit,
  ) async {
    await _hrSubscription?.cancel();
    _hrSubscription = null;
    try {
      await _service.stopHrStream();
    } catch (_) {}
    emit(state.copyWith(isStreaming: false));
  }

  void _onDeviceConnected(
    PolarDeviceConnectedEvent event,
    Emitter<PolarState> emit,
  ) {
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.connected,
      connectedDeviceId: event.deviceId,
      errorMessage: null,
    ));
  }

  void _onDeviceDisconnected(
    PolarDeviceDisconnectedEvent event,
    Emitter<PolarState> emit,
  ) {
    _hrSubscription?.cancel();
    _hrSubscription = null;
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.disconnected,
      isStreaming: false,
    ));
  }

  void _onHrReceived(
    PolarHrReceivedEvent event,
    Emitter<PolarState> emit,
  ) {
    final history = [...state.hrHistory, event.reading];
    if (history.length > 300) history.removeAt(0);
    emit(state.copyWith(
      latestReading: event.reading,
      hrHistory: history,
    ));
  }

  void _onHrError(
    PolarHrErrorEvent event,
    Emitter<PolarState> emit,
  ) {
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.error,
      errorMessage: event.message,
    ));
  }

  Future<void> _onDemoConnect(
    PolarDemoConnectRequested event,
    Emitter<PolarState> emit,
  ) async {
    _demoHrTimer?.cancel();
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.connected,
      connectedDeviceId: 'demo-polar-h10',
      connectedDeviceName: 'Polar H10 (Demo)',
      isStreaming: true,
      errorMessage: null,
    ));
    final random = math.Random();
    _demoHrTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(PolarHrReceivedEvent(HrReading(
        bpm: 65 + random.nextInt(16),
        rrIntervals: const [],
        sensorContact: true,
        timestamp: DateTime.now(),
      )));
    });
  }

  @override
  Future<void> close() {
    _demoHrTimer?.cancel();
    _deviceSubscription?.cancel();
    _hrSubscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
