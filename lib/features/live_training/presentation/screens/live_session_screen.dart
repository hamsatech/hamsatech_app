import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../../polar/presentation/bloc/polar_event.dart';
import '../../../polar/presentation/bloc/polar_state.dart';
import '../../bloc/live_training_bloc.dart';
import '../../bloc/live_training_event.dart';
import '../../bloc/live_training_state.dart';
import '../widgets/hr_analytics_card.dart';
import '../widgets/live_header.dart';

/// True exactly when the Polar connection just transitioned into
/// `disconnected` — not on repeat emissions of an already-disconnected
/// status, and not for any other status change. Pure/testable in
/// isolation from widgets or platform channels.
@visibleForTesting
bool isNewPolarDisconnect(
  PolarConnectionStatus previous,
  PolarConnectionStatus current,
) {
  return previous != current && current == PolarConnectionStatus.disconnected;
}

/// True while a training session is genuinely still in progress. Used to
/// suppress a disconnect warning once the session has already moved past
/// `LiveSessionActiveState` (e.g. into `ReflectingState` during normal
/// end-of-session cleanup) — an unexpected disconnect should only be
/// surfaced while it can actually still affect the live session.
@visibleForTesting
bool isLiveSessionStillActive(LiveTrainingState state) {
  return state is LiveSessionActiveState;
}

/// True whenever the persistent disconnect/reconnect banner (POLAR-4)
/// should be visible: only once this session has actually seen a real
/// Polar connection (a session with no device paired must never show a
/// spurious "disconnected" notice), only while the session itself is still
/// active, and only while the device is genuinely not connected right now.
@visibleForTesting
bool shouldShowPolarReconnectBanner({
  required bool hadPolarConnection,
  required LiveTrainingState liveState,
  required PolarConnectionStatus polarStatus,
}) {
  return hadPolarConnection &&
      isLiveSessionStillActive(liveState) &&
      polarStatus != PolarConnectionStatus.connected;
}

/// True exactly when a reconnect (manual tap or automatic) has just been
/// confirmed by the bloc's real, native-sourced `isConnected` — never
/// assumed — and HR streaming isn't already running. Guards against
/// starting a second, duplicate HR subscription: the very first connection
/// of the session already starts streaming from `initState`, so this can
/// only ever fire again after a genuine disconnect/reconnect cycle.
@visibleForTesting
bool shouldResumeHrStreamingAfterReconnect({
  required bool isConnected,
  required bool isStreaming,
  required LiveTrainingState liveState,
}) {
  return isConnected && !isStreaming && isLiveSessionStillActive(liveState);
}

class LiveSessionScreen extends StatelessWidget {
  const LiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LiveTrainingBloc>()),
        BlocProvider.value(value: getIt<PolarBloc>()),
      ],
      child: const _LiveSessionView(),
    );
  }
}

class _LiveSessionView extends StatefulWidget {
  const _LiveSessionView();

  @override
  State<_LiveSessionView> createState() => _LiveSessionViewState();
}

class _LiveSessionViewState extends State<_LiveSessionView>
    with WidgetsBindingObserver {
  // True once this session has observed a real Polar connection — gates the
  // disconnect/reconnect banner so a session with no device paired at all
  // never shows a spurious "disconnected" notice.
  bool _hadPolarConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveTrainingBloc>().add(const LiveTrainingStartRequested());
      _startPolarHrStreamIfConnected();
    });
  }

  // Live Training assumes a Polar device may already be connected from an
  // earlier pairing/baseline screen — it doesn't scan or connect itself,
  // it only (re)starts HR streaming on the existing connection, if any.
  void _startPolarHrStreamIfConnected() {
    final polarBloc = context.read<PolarBloc>();
    final polarState = polarBloc.state;
    if (polarState.connectedDeviceId != null && polarState.isConnected) {
      debugPrint('[PolarLiveTraining] Starting HR stream');
      _hadPolarConnection = true;
      polarBloc.add(const PolarStartHrStreamRequested());
    } else {
      debugPrint('[PolarLiveTraining] No connected Polar device');
    }
  }

  // App backgrounded/foregrounded during a live session: mirrors the same
  // pause/resume pattern already used on the Polar pairing screen
  // (PolarDeviceScreen.didChangeAppLifecycleState) rather than inventing a
  // new one. Stopping on pause avoids leaving a native BLE stream running
  // unobserved while backgrounded (where the OS may throttle or silently
  // drop it anyway); resuming is guarded on `!isStreaming`, so a resume
  // event arriving while a stream is already active (e.g. the app was
  // barely backgrounded at all) can never start a second, duplicate
  // subscription. The session itself (LiveTrainingBloc's timer/series/
  // sessionId) is entirely independent of Polar streaming state, so it is
  // never touched here and is preserved across the gap automatically.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final polarBloc = context.read<PolarBloc>();
    if (state == AppLifecycleState.paused && polarBloc.state.isStreaming) {
      polarBloc.add(const PolarStopHrStreamRequested());
    } else if (state == AppLifecycleState.resumed &&
        polarBloc.state.isConnected &&
        !polarBloc.state.isStreaming) {
      polarBloc.add(const PolarStartHrStreamRequested());
    }
  }

  // Safety net for leaving the live session without going through the
  // normal End Session button (back navigation, etc.) — stops native HR
  // streaming without disconnecting the device. Reads the singleton
  // directly (not `context.read`) since it must be safe to call during
  // dispose; guarded on `isStreaming` so it's a no-op if the normal
  // ReflectingState path already stopped it, keeping both triggers
  // idempotent with each other.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final polarBloc = getIt<PolarBloc>();
    if (polarBloc.state.isStreaming) {
      polarBloc.add(const PolarStopHrStreamRequested());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PolarBloc, PolarState>(
      listener: (context, polarState) {
        final liveState = context.read<LiveTrainingBloc>().state;
        if (!polarState.isConnected) return;
        // Reconnect confirmed by the real native callback (never assumed) —
        // resume streaming only now, and only if it isn't already running
        // (the very first connection already started it from initState, so
        // this only ever fires again after a genuine disconnect/reconnect
        // cycle; the bloc's own `_hrSubscription?.cancel()` before
        // resubscribing makes a second call here safe either way).
        _hadPolarConnection = true;
        if (shouldResumeHrStreamingAfterReconnect(
          isConnected: polarState.isConnected,
          isStreaming: polarState.isStreaming,
          liveState: liveState,
        )) {
          context.read<PolarBloc>().add(const PolarStartHrStreamRequested());
        }
      },
      child: BlocConsumer<LiveTrainingBloc, LiveTrainingState>(
        listener: (context, state) {
          if (state is ReflectingState) {
            // Explicitly stop native HR streaming now that the session has
            // ended — distinct from disconnecting the device, which stays
            // connected. Existing HR data collection/flush already
            // happened synchronously before this state was reached
            // (LiveTrainingBloc._onEndRequested/_onSeriesCompleted).
            context.read<PolarBloc>().add(const PolarStopHrStreamRequested());
            context.pushReplacement('/session/reflect');
          }
        },
        builder: (context, liveState) {
          final s = liveState is LiveSessionActiveState ? liveState : null;
          return Scaffold(
            backgroundColor: const Color(0xFFF5FDFF),
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────
                  LiveHeader(
                    sessionTitle: s?.sessionTitle ?? '',
                    formattedElapsed: s?.formattedElapsed ?? '0:00',
                    isPaused: s?.isPaused ?? false,
                  ),
                  const Divider(height: 1, color: Color(0xFFCAE8EE)),

                  // ── Disconnect / reconnect banner ─────────────────────
                  BlocBuilder<PolarBloc, PolarState>(
                    buildWhen: (previous, current) =>
                        previous.connectionStatus != current.connectionStatus,
                    builder: (context, polarState) {
                      final showBanner = shouldShowPolarReconnectBanner(
                        hadPolarConnection: _hadPolarConnection,
                        liveState: liveState,
                        polarStatus: polarState.connectionStatus,
                      );
                      if (!showBanner) return const SizedBox.shrink();
                      return _PolarReconnectBanner(polarState: polarState);
                    },
                  ),

                  // ── Scrollable body ───────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HrAnalyticsCard(
                            baselineHr: s?.baselineHr ?? 65,
                            simulatedHr: s?.simulatedHr,
                            simulatedHrHistory:
                                s?.simulatedHrHistory ?? const [],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom action bar ─────────────────────────────────
                  _BottomActionBar(isPaused: s?.isPaused ?? false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Disconnect / reconnect banner ─────────────────────────────────────────

/// Persistent (not a transient SnackBar) so the Reconnect action stays
/// available for as long as the device is actually disconnected — the
/// wording and action reflect the bloc's real, native-confirmed
/// [PolarConnectionStatus] only; this never claims the device is connected
/// on its own.
class _PolarReconnectBanner extends StatelessWidget {
  const _PolarReconnectBanner({required this.polarState});

  final PolarState polarState;

  @override
  Widget build(BuildContext context) {
    final isReconnecting =
        polarState.connectionStatus == PolarConnectionStatus.connecting;
    final deviceLabel = polarState.connectedDeviceName ?? 'Polar device';
    final label = isReconnecting
        ? 'Reconnecting to $deviceLabel…'
        : (polarState.errorMessage ??
            '$deviceLabel disconnected. Heart rate isn\'t being tracked.');

    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF2F2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isReconnecting
                ? Icons.bluetooth_searching_rounded
                : Icons.bluetooth_disabled_rounded,
            color: const Color(0xFFB91C1C),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isReconnecting)
            TextButton(
              // Reconnects only to the already-known device id — never a
              // fresh scan (Live Training doesn't scan/connect on its own,
              // consistent with how it first acquired this connection).
              // The bloc's own `_onConnect` guard (isConnecting || isConnected)
              // makes a second tap while an attempt is already in flight a
              // safe no-op, so this can never start more than one attempt
              // at a time.
              onPressed: polarState.connectedDeviceId == null
                  ? null
                  : () => context.read<PolarBloc>().add(
                      PolarConnectRequested(polarState.connectedDeviceId!)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reconnect',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Bottom action bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.isPaused});

  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCAE8EE))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          // Pause / Resume
          Expanded(
            child: TextButton.icon(
              onPressed: () => context
                  .read<LiveTrainingBloc>()
                  .add(const LiveTrainingPauseToggled()),
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 18,
              ),
              label: Text(isPaused ? 'Resume' : 'Pause'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2A5562),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // End session
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context
                  .read<LiveTrainingBloc>()
                  .add(const LiveTrainingEndRequested()),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('End Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F7E8F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
