import 'package:flutter_test/flutter_test.dart';
import 'package:hamsatech/features/live_training/bloc/live_training_state.dart';
import 'package:hamsatech/features/live_training/presentation/screens/live_session_screen.dart';
import 'package:hamsatech/features/polar/presentation/bloc/polar_state.dart';

const _activeState = LiveSessionActiveState(
  sessionId: 's1',
  sessionTitle: 'Test Session',
  elapsedSeconds: 10,
  isPaused: false,
  currentSeriesIndex: 0,
  totalSeries: 3,
  shotsPerSeries: 10,
  baselineHr: 65,
);
const _reflectingState = ReflectingState(sessionId: 's1', elapsedSeconds: 100);

void main() {
  group('shouldShowPolarReconnectBanner (POLAR-4/POLAR-5)', () {
    test('true once a device has connected, the session is active, and it '
        'is now disconnected', () {
      expect(
        shouldShowPolarReconnectBanner(
          hadPolarConnection: true,
          liveState: _activeState,
          polarStatus: PolarConnectionStatus.disconnected,
        ),
        isTrue,
      );
    });

    test('true while actively reconnecting (connecting status)', () {
      expect(
        shouldShowPolarReconnectBanner(
          hadPolarConnection: true,
          liveState: _activeState,
          polarStatus: PolarConnectionStatus.connecting,
        ),
        isTrue,
      );
    });

    test('false once reconnected — never claims disconnected while actually '
        'connected', () {
      expect(
        shouldShowPolarReconnectBanner(
          hadPolarConnection: true,
          liveState: _activeState,
          polarStatus: PolarConnectionStatus.connected,
        ),
        isFalse,
      );
    });

    test('false when no Polar device was ever connected this session — a '
        'session with no device paired must never show a spurious notice', () {
      expect(
        shouldShowPolarReconnectBanner(
          hadPolarConnection: false,
          liveState: _activeState,
          polarStatus: PolarConnectionStatus.disconnected,
        ),
        isFalse,
      );
    });

    test('false once the session has moved past active (e.g. reflecting) — '
        'suppresses a stale banner during intentional end-of-session cleanup', () {
      expect(
        shouldShowPolarReconnectBanner(
          hadPolarConnection: true,
          liveState: _reflectingState,
          polarStatus: PolarConnectionStatus.disconnected,
        ),
        isFalse,
      );
    });
  });

  group('shouldResumeHrStreamingAfterReconnect (POLAR-4 — never duplicate '
      'the HR subscription)', () {
    test('true when a reconnect is confirmed and streaming is not already '
        'running, while the session is still active', () {
      expect(
        shouldResumeHrStreamingAfterReconnect(
          isConnected: true,
          isStreaming: false,
          liveState: _activeState,
        ),
        isTrue,
      );
    });

    test('false when already streaming — must never start a second, '
        'duplicate HR subscription', () {
      expect(
        shouldResumeHrStreamingAfterReconnect(
          isConnected: true,
          isStreaming: true,
          liveState: _activeState,
        ),
        isFalse,
      );
    });

    test('false when not actually connected — must never assume/claim a '
        'connection that has not been confirmed', () {
      expect(
        shouldResumeHrStreamingAfterReconnect(
          isConnected: false,
          isStreaming: false,
          liveState: _activeState,
        ),
        isFalse,
      );
    });

    test('false once the session is no longer active (e.g. reflecting)', () {
      expect(
        shouldResumeHrStreamingAfterReconnect(
          isConnected: true,
          isStreaming: false,
          liveState: _reflectingState,
        ),
        isFalse,
      );
    });
  });
}
