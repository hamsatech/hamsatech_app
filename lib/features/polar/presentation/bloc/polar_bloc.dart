import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
    on<PolarBluetoothOffEvent>(_onBluetoothOff);
    on<PolarConnectTimedOutEvent>(_onConnectTimedOut);
    on<PolarDisconnectTimedOutEvent>(_onDisconnectTimedOut);

    _deviceSubscription = _service.deviceEvents.listen((event) {
      switch (event.status) {
        case PolarDeviceStatus.found:
          assert(
            event.deviceId != null,
            'PolarDeviceStatus.found must carry a non-null deviceId',
          );
          if (event.deviceId == null) return;
          add(PolarDeviceFoundEvent(
            deviceId: event.deviceId!,
            name: event.name ?? event.deviceId!,
            deviceType: event.deviceType,
          ));
        case PolarDeviceStatus.connected:
          assert(
            event.deviceId != null,
            'PolarDeviceStatus.connected must carry a non-null deviceId',
          );
          if (event.deviceId == null) return;
          add(PolarDeviceConnectedEvent(event.deviceId!));
        case PolarDeviceStatus.disconnected:
          assert(
            event.deviceId != null,
            'PolarDeviceStatus.disconnected must carry a non-null deviceId',
          );
          if (event.deviceId == null) return;
          add(PolarDeviceDisconnectedEvent(event.deviceId!));
        case PolarDeviceStatus.connecting:
          break;
        case PolarDeviceStatus.bluetoothOff:
          // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
          debugPrint('[PolarDebug] PolarBloc: bluetoothOff case reached, dispatching PolarBluetoothOffEvent');
          add(const PolarBluetoothOffEvent());
      }
    });
  }

  static const _kConnectTimeout = Duration(seconds: 15);
  static const _kDisconnectTimeout = Duration(seconds: 10);

  final PolarBleService _service;
  StreamSubscription<PolarDeviceEvent>? _deviceSubscription;
  StreamSubscription<HrReading>? _hrSubscription;
  Timer? _demoHrTimer;
  Timer? _connectTimeoutTimer;
  Timer? _disconnectTimeoutTimer;
  // Private re-entrancy guard for the disconnect flow only — connect already
  // has a real, public `connecting` status to guard against re-entry and
  // late completion; disconnect has no equivalent public state, so this
  // internal-only flag (never exposed via PolarState) plays that role
  // without introducing a new public connection state.
  bool _isDisconnecting = false;

  Future<void> _onScanStarted(
    PolarScanStarted event,
    Emitter<PolarState> emit,
  ) async {
    if (state.isScanning) return;
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
    if (state.discoveredDevices.any((d) => d.deviceId == event.deviceId))
      return;
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
    if (state.isConnecting || state.isConnected) return;
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
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = Timer(
      _kConnectTimeout,
      () => add(const PolarConnectTimedOutEvent()),
    );
    try {
      await _service.connectToDevice(event.deviceId);
    } catch (e) {
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = null;
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
    if (deviceId == null || state.isConnecting || _isDisconnecting) return;
    // Commit the re-entrancy guard synchronously, before the first await,
    // so a second concurrently-dispatched PolarDisconnectRequested can't
    // slip past the check above (mirrors why _onConnect's guard is safe).
    _isDisconnecting = true;
    _disconnectTimeoutTimer?.cancel();
    _disconnectTimeoutTimer = Timer(
      _kDisconnectTimeout,
      () => add(const PolarDisconnectTimedOutEvent()),
    );
    _demoHrTimer?.cancel();
    _demoHrTimer = null;
    await _hrSubscription?.cancel();
    _hrSubscription = null;
    try {
      await _service.stopHrStream();
      await _service.disconnectFromDevice(deviceId);
    } catch (_) {}
    // If the timeout (or a Bluetooth-off event) already resolved this
    // attempt while the calls above were in flight, don't overwrite it.
    if (!_isDisconnecting) return;
    _isDisconnecting = false;
    _disconnectTimeoutTimer?.cancel();
    _disconnectTimeoutTimer = null;
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

  Future<void> _onDeviceConnected(
    PolarDeviceConnectedEvent event,
    Emitter<PolarState> emit,
  ) async {
    // Ignore a late native success if the attempt already timed out or
    // Bluetooth was turned off in the meantime (status moved off "connecting").
    if (state.connectionStatus != PolarConnectionStatus.connecting) return;
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    try {
      await _service.stopScan();
    } catch (_) {}
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
    _isDisconnecting = false;
    _disconnectTimeoutTimer?.cancel();
    _disconnectTimeoutTimer = null;
    _hrSubscription?.cancel();
    _hrSubscription = null;
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.disconnected,
      isStreaming: false,
    ));
  }

  Future<void> _onBluetoothOff(
    PolarBluetoothOffEvent event,
    Emitter<PolarState> emit,
  ) async {
    // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
    debugPrint('[PolarDebug] PolarBloc._onBluetoothOff handler executing, about to emit error state');
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _disconnectTimeoutTimer?.cancel();
    _disconnectTimeoutTimer = null;
    _isDisconnecting = false;
    _demoHrTimer?.cancel();
    _demoHrTimer = null;
    await _hrSubscription?.cancel();
    _hrSubscription = null;
    try {
      await _service.stopHrStream();
    } catch (_) {}
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.error,
      discoveredDevices: const [],
      isStreaming: false,
      errorMessage: 'Bluetooth is turned off',
    ));
    // TEMPORARY DEBUG (Phase 0.2 bug trace) — remove after diagnosis.
    debugPrint(
        '[PolarDebug] PolarBloc._onBluetoothOff: state emitted, connectionStatus=${state.connectionStatus} errorMessage=${state.errorMessage}');
  }

  Future<void> _onConnectTimedOut(
    PolarConnectTimedOutEvent event,
    Emitter<PolarState> emit,
  ) async {
    // Idempotent: no-op if this attempt was already resolved by a real
    // connection or by Bluetooth turning off before the timer fired.
    if (state.connectionStatus != PolarConnectionStatus.connecting) return;
    _connectTimeoutTimer = null;
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.error,
      errorMessage: 'Connection timed out',
    ));
  }

  Future<void> _onDisconnectTimedOut(
    PolarDisconnectTimedOutEvent event,
    Emitter<PolarState> emit,
  ) async {
    // Idempotent: no-op if this attempt was already resolved by
    // _onDisconnect's own completion, native confirmation, or Bluetooth off.
    if (!_isDisconnecting) return;
    _isDisconnecting = false;
    _disconnectTimeoutTimer = null;
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.error,
      isStreaming: false,
      errorMessage: 'Disconnect timed out',
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
    _connectTimeoutTimer?.cancel();
    _disconnectTimeoutTimer?.cancel();
    _deviceSubscription?.cancel();
    _hrSubscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
