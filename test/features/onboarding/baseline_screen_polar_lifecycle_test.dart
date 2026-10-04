import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/core/di/injection.dart';
import 'package:hamsatech/features/onboarding/presentation/screens/baseline_screen.dart';
import 'package:hamsatech/features/polar/data/services/polar_ble_service.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_bloc.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_event.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_state.dart';

/// POLAR-1 regression coverage: baseline capture starts the native HR
/// stream but historically never stopped it on any exit path (completion,
/// back navigation, or any other disposal) — it kept running for the rest
/// of onboarding. `BaselineScreen` is a real, public widget wired through
/// GetIt (`getIt<PolarBloc>()`), so these are genuine widget tests, not
/// pure-function ones — there's no pure decision to extract here, the fix
/// lives entirely in State.dispose(). A real `PolarBloc` reaches a
/// connected+streaming state via `PolarDemoConnectRequested` (the same
/// hardware-free technique used in polar_bloc_stop_stream_test.dart), so no
/// platform-channel mocking is needed.
///
/// `PolarBloc`'s event processing is real Stream/async work, not Flutter
/// frame scheduling — `tester.pump()` alone does not drain it under
/// `testWidgets`'s FakeAsync zone, so waits below run inside
/// `tester.runAsync()` and poll `bloc.state` directly (not
/// `bloc.stream.firstWhere`, which would race against a transition that
/// may already have completed during a preceding pump).
Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  int maxIterations = 50,
}) {
  return tester.runAsync(() async {
    for (var i = 0; i < maxIterations && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PolarBloc bloc;

  setUp(() {
    bloc = PolarBloc(PolarBleService());
    if (getIt.isRegistered<PolarBloc>()) {
      getIt.unregister<PolarBloc>();
    }
    getIt.registerSingleton<PolarBloc>(bloc);
  });

  tearDown(() async {
    getIt.unregister<PolarBloc>();
    await bloc.close();
  });

  testWidgets(
    'HR stream stops when baseline capture is disposed '
    '(covers normal completion, back navigation, and any other exit — '
    'all of them tear down this same State via dispose())',
    (tester) async {
      bloc.add(const PolarDemoConnectRequested());
      await _waitUntil(tester, () => bloc.state.isStreaming);
      expect(bloc.state.isStreaming, isTrue);

      await tester.pumpWidget(const MaterialApp(home: BaselineScreen()));
      await tester.pump();
      expect(bloc.state.isStreaming, isTrue,
          reason: 'still on the capture screen — stream must still be live');

      // Removing the widget from the tree runs dispose(), exactly as
      // context.go('/baseline/result') or a back-navigation would.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await _waitUntil(tester, () => !bloc.state.isStreaming);

      expect(bloc.state.isStreaming, isFalse,
          reason: 'POLAR-1: leaving baseline capture must stop the native '
              'HR stream, not leave it running for the rest of onboarding');
      // Stopping the stream must never also disconnect the device.
      expect(bloc.state.connectionStatus, PolarConnectionStatus.connected);
    },
  );

  testWidgets(
    'disposing baseline capture is a safe no-op when no stream was ever started',
    (tester) async {
      expect(bloc.state.isStreaming, isFalse);

      await tester.pumpWidget(const MaterialApp(home: BaselineScreen()));
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(bloc.state.isStreaming, isFalse);
    },
  );
}
