import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech/core/di/injection.dart';
import 'package:hamsatech/core/services/storage_service.dart';
import 'package:hamsatech/features/polar/data/services/polar_ble_service.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_bloc.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_event.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_state.dart';
import 'package:hamsatech/features/polar/presentation/screens/polar_device_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// POLAR-2 regression coverage: the native BLE scan was previously never
/// stopped when the pairing screen was disposed, or when the user tapped
/// "Continue without Polar" — only a 10s scan-timeout or a successful
/// connection stopped it. Both this screen's own permission check
/// (`permission_handler`) and the Polar plugin's scan/stopScan calls go
/// through real platform MethodChannels with no native side registered in
/// a test process, so both are mocked here — this is the app's own plugin
/// channel (`com.hamsatech/polar`), fully known and safe to fake, plus the
/// well-established `permission_handler` test-mocking channel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const polarChannel = MethodChannel('com.hamsatech/polar');
  const permissionChannel =
      MethodChannel('flutter.baseflow.com/permissions/methods');

  late PolarBloc bloc;
  late List<MethodCall> polarCalls;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    polarCalls = [];
    bloc = PolarBloc(PolarBleService());
    if (getIt.isRegistered<PolarBloc>()) {
      getIt.unregister<PolarBloc>();
    }
    getIt.registerSingleton<PolarBloc>(bloc);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(polarChannel, (call) async {
      polarCalls.add(call);
      return null;
    });
    // Always report BLUETOOTH_SCAN/BLUETOOTH_CONNECT as granted (index 1 =
    // PermissionStatus.granted) so the screen proceeds past its permission
    // gate straight into scanning, exactly like a real device that already
    // granted permission at app open (SplashScreen).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
      if (call.method == 'checkPermissionStatus') return 1;
      if (call.method == 'requestPermissions') {
        final permissions = (call.arguments as List).cast<int>();
        return {for (final p in permissions) p: 1};
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(polarChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    getIt.unregister<PolarBloc>();
    await bloc.close();
  });

  testWidgets('native scan is stopped when the pairing screen is disposed',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PolarDeviceScreen()));
    // Permission check + scan start are async (real Future-based platform
    // channel calls), not frame-driven — must run outside FakeAsync.
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && !bloc.state.isScanning; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();

    expect(bloc.state.isScanning, isTrue,
        reason: 'setup: screen should have started scanning');
    expect(polarCalls.map((c) => c.method), contains('scan'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(
      polarCalls.map((c) => c.method).where((m) => m == 'stopScan').length,
      greaterThanOrEqualTo(1),
      reason: 'POLAR-2: leaving the pairing screen must cancel the native '
          'scan, not leave it running in the background',
    );
  });

  testWidgets(
      'no duplicate scanner is started by disposal after scanning was '
      'already stopped some other way', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PolarDeviceScreen()));
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && !bloc.state.isScanning; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();
    polarCalls.clear();

    // Stop scanning directly (as the bloc itself would on a real connect or
    // scan error), then dispose — dispose's own stop dispatch must be a
    // harmless no-op, never a second/duplicate scan start.
    bloc.add(const PolarScanStopped());
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && bloc.state.isScanning; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    polarCalls.clear();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(polarCalls.map((c) => c.method), isNot(contains('scan')),
        reason: 'disposal must never start a new scan, only ever stop one');
  });

  testWidgets(
      'native scan is stopped when the user taps "Continue without Polar"',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/polar',
      routes: [
        GoRoute(
            path: '/polar', builder: (_, __) => const PolarDeviceScreen()),
        GoRoute(
            path: '/home', builder: (_, __) => const SizedBox.shrink()),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.runAsync(() async {
      for (var i = 0; i < 50 && !bloc.state.isScanning; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();

    // Reach the fallback UI (which renders the "Continue without Polar"
    // button) via a scan error rather than the real 10s scan timeout.
    bloc.add(const PolarScanErrorEvent('no adapter'));
    await tester.runAsync(() async {
      for (var i = 0;
          i < 50 && bloc.state.connectionStatus != PolarConnectionStatus.error;
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();
    await tester.pump();

    final continueButton = find.text('Continue without Polar');
    expect(continueButton, findsOneWidget,
        reason: 'setup: fallback UI should be showing after a scan error');

    polarCalls.clear();
    await tester.tap(continueButton);
    await tester.pump();

    expect(
      polarCalls.map((c) => c.method).where((m) => m == 'stopScan').length,
      greaterThanOrEqualTo(1),
      reason: 'POLAR-2: continuing without a device must stop the native '
          'scan — there is no other screen left to do it',
    );
  });
}
