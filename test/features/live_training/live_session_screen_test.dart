import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/live_training/bloc/live_training_state.dart';
import 'package:hamsatech/features/live_training/presentation/screens/live_session_screen.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_state.dart';

void main() {
  group('isNewPolarDisconnect', () {
    test('true when status transitions into disconnected', () {
      expect(
        isNewPolarDisconnect(
          PolarConnectionStatus.connected,
          PolarConnectionStatus.disconnected,
        ),
        isTrue,
      );
    });

    test('false when status was already disconnected (no new transition)', () {
      expect(
        isNewPolarDisconnect(
          PolarConnectionStatus.disconnected,
          PolarConnectionStatus.disconnected,
        ),
        isFalse,
        reason: 'must not fire repeatedly for the same disconnected status',
      );
    });

    test('false when transitioning to a non-disconnected status', () {
      expect(
        isNewPolarDisconnect(
          PolarConnectionStatus.connecting,
          PolarConnectionStatus.connected,
        ),
        isFalse,
      );
    });

    test(
        'false when transitioning into error (Bluetooth off), not disconnected',
        () {
      expect(
        isNewPolarDisconnect(
          PolarConnectionStatus.connected,
          PolarConnectionStatus.error,
        ),
        isFalse,
      );
    });
  });

  group('isLiveSessionStillActive', () {
    test('true while a session is actively in progress', () {
      const state = LiveSessionActiveState(
        sessionId: 's1',
        sessionTitle: 'Test Session',
        elapsedSeconds: 10,
        isPaused: false,
        currentSeriesIndex: 0,
        totalSeries: 3,
        shotsPerSeries: 10,
        baselineHr: 65,
      );
      expect(isLiveSessionStillActive(state), isTrue);
    });

    test(
        'false once the session has moved into reflection '
        '(this is what suppresses a false warning during intentional cleanup)',
        () {
      const state = ReflectingState(sessionId: 's1', elapsedSeconds: 100);
      expect(isLiveSessionStillActive(state), isFalse);
    });

    test('false before any session has started', () {
      const state = LiveTrainingInitial();
      expect(isLiveSessionStillActive(state), isFalse);
    });

    test('false after the reflection has been saved', () {
      const state = ReflectionSavedState();
      expect(isLiveSessionStillActive(state), isFalse);
    });
  });
}
