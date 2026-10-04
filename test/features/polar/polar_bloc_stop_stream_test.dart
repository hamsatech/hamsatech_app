import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/polar/data/services/polar_ble_service.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_bloc.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_event.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'PolarStopHrStreamRequested stops streaming without disconnecting '
      'the device, and is safe to dispatch more than once', () async {
    final bloc = PolarBloc(PolarBleService());
    addTearDown(bloc.close);

    // Demo-connect is the bloc's own real, public, hardware-free path to a
    // genuine connected+streaming state (no native platform channel
    // response required) — used here instead of reaching into private
    // bloc internals.
    bloc.add(const PolarDemoConnectRequested());
    await bloc.stream.firstWhere((s) => s.isStreaming);

    expect(bloc.state.connectionStatus, PolarConnectionStatus.connected);
    expect(bloc.state.connectedDeviceId, isNotNull);
    expect(bloc.state.isStreaming, isTrue);

    bloc.add(const PolarStopHrStreamRequested());
    await bloc.stream.firstWhere((s) => !s.isStreaming);

    expect(bloc.state.isStreaming, isFalse);
    // Distinct-actions requirement: stopping the stream must not also
    // disconnect the device.
    expect(bloc.state.connectionStatus, PolarConnectionStatus.connected);
    expect(bloc.state.connectedDeviceId, isNotNull);

    // Idempotency requirement: dispatching it again must not throw and
    // must not change the already-stopped, still-connected state.
    bloc.add(const PolarStopHrStreamRequested());
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(bloc.state.isStreaming, isFalse);
    expect(bloc.state.connectionStatus, PolarConnectionStatus.connected);
  });

  test(
      'PolarScanErrorEvent (native scan failure, e.g. missing permission or '
      'BLE adapter error) surfaces as a real error state instead of being '
      'swallowed into a silent empty scan', () async {
    final bloc = PolarBloc(PolarBleService());
    addTearDown(bloc.close);

    bloc.add(const PolarScanErrorEvent('SecurityException: BLUETOOTH_SCAN permission not granted'));
    await bloc.stream.firstWhere(
        (s) => s.connectionStatus == PolarConnectionStatus.error);

    expect(bloc.state.connectionStatus, PolarConnectionStatus.error);
    expect(bloc.state.errorMessage, contains('BLUETOOTH_SCAN permission not granted'));
  });

  test(
      'POLAR-4: a second PolarConnectRequested for the same device while one '
      'is already in flight is a safe no-op — the Reconnect button can never '
      'start two concurrent connection attempts, even on a double-tap',
      () async {
    // Without a mock, the native "connect" call fails instantly (no plugin
    // registered in a test process), and the bloc's own catch block moves
    // straight to an error state — too transient to observe "connecting"
    // at all. Mocking the channel to hang mid-connect (never resolving)
    // keeps the bloc genuinely in "connecting" for the test's lifetime,
    // which is what actually exercises the guard against a second,
    // overlapping attempt.
    const channel = MethodChannel('com.hamsatech/polar');
    var connectCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'connect') {
        connectCalls++;
        return Completer<Object?>().future; // never resolves
      }
      return Future<Object?>.value();
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final bloc = PolarBloc(PolarBleService());
    addTearDown(bloc.close);

    // The device isn't actually registered as "discovered" — connect still
    // proceeds (falls back to a minimal PolarDiscoveredDevice), matching
    // exactly how the live-session Reconnect button calls it: by a known
    // deviceId carried over from PolarState, not from a fresh scan result.
    bloc.add(const PolarConnectRequested('known-device-id'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state.connectionStatus, PolarConnectionStatus.connecting);
    expect(connectCalls, 1);

    bloc.add(const PolarConnectRequested('known-device-id'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // The guard (`state.isConnecting || state.isConnected` in
    // PolarBloc._onConnect) means the second dispatch returns immediately
    // without ever reaching the native call a second time.
    expect(connectCalls, 1,
        reason: 'a second overlapping attempt must never reach the native '
            'connect call at all');
    expect(bloc.state.connectionStatus, PolarConnectionStatus.connecting);
    expect(bloc.state.connectedDeviceId, 'known-device-id');
  });
}
