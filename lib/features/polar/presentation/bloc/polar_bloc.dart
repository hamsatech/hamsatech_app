import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/polar_ble_service.dart';
import '../../domain/models/hr_reading.dart';
import 'polar_event.dart';
import 'polar_state.dart';

class PolarBloc extends Bloc<PolarEvent, PolarState> {
  PolarBloc(this._service) : super(const PolarState()) {
    on<PolarConnectRequested>(_onConnect);
    on<PolarDisconnectRequested>(_onDisconnect);
    on<PolarStartHrStreamRequested>(_onStartHrStream);
    on<PolarStopHrStreamRequested>(_onStopHrStream);
    on<PolarDeviceConnectedEvent>(_onDeviceConnected);
    on<PolarDeviceDisconnectedEvent>(_onDeviceDisconnected);
    on<PolarHrReceivedEvent>(_onHrReceived);
    on<PolarHrErrorEvent>(_onHrError);

    _deviceSubscription = _service.deviceEvents.listen((event) {
      if (event.status == PolarDeviceStatus.connected) {
        add(PolarDeviceConnectedEvent(event.deviceId));
      } else if (event.status == PolarDeviceStatus.disconnected) {
        add(PolarDeviceDisconnectedEvent(event.deviceId));
      }
    });
  }

  final PolarBleService _service;
  StreamSubscription<PolarDeviceEvent>? _deviceSubscription;
  StreamSubscription<HrReading>? _hrSubscription;

  Future<void> _onConnect(
    PolarConnectRequested event,
    Emitter<PolarState> emit,
  ) async {
    emit(state.copyWith(
      connectionStatus: PolarConnectionStatus.connecting,
      connectedDeviceId: event.deviceId,
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

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    _hrSubscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
