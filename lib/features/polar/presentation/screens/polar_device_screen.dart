import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/polar_bloc.dart';
import '../bloc/polar_event.dart';
import '../bloc/polar_state.dart';

// ── Colours local to this screen (light theme) ───────────────────────────────
const _kBg = Color(0xFFF5FDFF);
const _kTextPrimary = Color(0xFF000F12);
const _kTextSecondary = Color(0x99000F12);
const _kBorderColor = Color(0xFFCAE8EE);
const _kSearchIconBg = Color(0xFF2F7E8F);
const _kConnectedIconBg = Color(0xFF16A34A);
const _kConnectedText = Color(0xFF16A34A);
const _kConnectedBg = Color(0xFFF0FDF4);
const _kConnectBtnBg = Color(0xFF1D6070);
const _kConnectingBg = Color(0xFFEAF7FA);
const _kConnectingText = Color(0xFF2F7E8F);
const _kDoneBtnBg = Color(0xFF2F7E8F);
const _kScanTimeout = Duration(seconds: 10);

class PolarDeviceScreen extends StatelessWidget {
  const PolarDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PolarBloc>(),
      child: const _PolarDeviceView(),
    );
  }
}

class _PolarDeviceView extends StatefulWidget {
  const _PolarDeviceView();

  @override
  State<_PolarDeviceView> createState() => _PolarDeviceViewState();
}

class _PolarDeviceViewState extends State<_PolarDeviceView>
    with WidgetsBindingObserver {
  bool _permissionGranted = false;
  bool _permissionChecked = false;
  bool _scanTimedOut = false;
  Timer? _scanTimeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  // Permission was already requested at app open (SplashScreen).
  // Here we only check the current status and start scanning if granted,
  // or show the denied view if the user previously denied it.
  Future<void> _checkPermission() async {
    bool granted;
    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.status;
      final connect = await Permission.bluetoothConnect.status;
      granted = scan.isGranted && connect.isGranted;
    } else {
      final status = await Permission.bluetooth.status;
      granted = status.isGranted || status.isLimited;
    }
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      _permissionChecked = true;
    });
    if (granted) {
      context.read<PolarBloc>().add(const PolarScanStarted());
      _startScanTimeout();
    }
  }

  void _startScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimedOut = false;
    _scanTimeoutTimer = Timer(_kScanTimeout, _handleScanTimeout);
  }

  void _handleScanTimeout() {
    if (!mounted) return;

    final bloc = context.read<PolarBloc>();
    final state = bloc.state;
    if (state.isConnected || state.discoveredDevices.isNotEmpty) return;

    if (state.isScanning) {
      bloc.add(const PolarScanStopped());
    }

    setState(() => _scanTimedOut = true);
  }

  void _retryScan() {
    setState(() => _scanTimedOut = false);
    context.read<PolarBloc>().add(const PolarScanStarted());
    _startScanTimeout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<PolarBloc>();
    if (state == AppLifecycleState.paused && bloc.state.isStreaming) {
      bloc.add(const PolarStopHrStreamRequested());
    } else if (state == AppLifecycleState.resumed &&
        bloc.state.isConnected &&
        !bloc.state.isStreaming) {
      bloc.add(const PolarStartHrStreamRequested());
    }
  }

  @override
  void dispose() {
    _scanTimeoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kSearchIconBg)),
      );
    }
    if (!_permissionGranted) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: _PermissionDeniedView(),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: BlocConsumer<PolarBloc, PolarState>(
        listener: (context, state) {
          if (state.connectionStatus == PolarConnectionStatus.error &&
              state.errorMessage != null) {
            _scanTimeoutTimer?.cancel();
            if (!_scanTimedOut) {
              setState(() => _scanTimedOut = true);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          if (state.isConnected || state.discoveredDevices.isNotEmpty) {
            _scanTimeoutTimer?.cancel();
            if (_scanTimedOut && state.isConnected) {
              setState(() => _scanTimedOut = false);
            }
          }
          if (state.isConnected && !state.isStreaming) {
            context.read<PolarBloc>().add(const PolarStartHrStreamRequested());
          }
        },
        builder: (context, state) {
          final showFallback = !state.isConnected &&
              (state.connectionStatus == PolarConnectionStatus.error ||
                  (_scanTimedOut && state.discoveredDevices.isEmpty));

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StatusIconSection(
                          state: state,
                          showFallback: showFallback,
                        ),
                        const SizedBox(height: 32),
                        _SectionHeader(
                          state: state,
                          showFallback: showFallback,
                        ),
                        const SizedBox(height: 20),
                        _FoundDevicesDivider(),
                        const SizedBox(height: 16),
                        _DeviceList(state: state, showFallback: showFallback),
                        if (showFallback) ...[
                          const SizedBox(height: 16),
                          _TroubleshootCard(onRetry: _retryScan),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.isConnected)
                  _DoneButton(state: state)
                else if (showFallback)
                  const _ContinueWithoutDeviceButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Status icon + text at the top ────────────────────────────────────────────

class _StatusIconSection extends StatelessWidget {
  const _StatusIconSection({
    required this.state,
    required this.showFallback,
  });

  final PolarState state;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;

    return Column(
      children: [
        _StatusIcon(
          isConnected: isConnected,
          isSearching: !showFallback,
        ),
        const SizedBox(height: 12),
        Text(
          isConnected
              ? 'Connected to ${state.connectedDeviceName ?? state.connectedDeviceId ?? 'device'}'
              : showFallback
                  ? 'Can’t find your device?'
                  : 'Searching...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isConnected ? _kConnectedText : _kTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        if (!isConnected)
          Text(
            showFallback
                ? 'Try again or continue without Polar for now.'
                : 'Make sure your Polar device is on and nearby.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: _kTextSecondary,
            ),
          ),
      ],
    );
  }
}

class _StatusIcon extends StatefulWidget {
  const _StatusIcon({
    required this.isConnected,
    required this.isSearching,
  });

  final bool isConnected;
  final bool isSearching;

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isConnected) {
      return Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: _kConnectedIconBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 36),
      );
    }

    final icon = Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: _kSearchIconBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 36),
    );

    if (!widget.isSearching) return icon;

    return ScaleTransition(scale: _scale, child: icon);
  }
}

// ── Section header (title + subtitle) ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.state,
    required this.showFallback,
  });

  final PolarState state;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;
    return Column(
      children: [
        Text(
          isConnected
              ? 'Device connected'
              : showFallback
                  ? 'Having trouble?'
                  : 'Connecting to Polar',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isConnected
              ? 'Your heart rate and HRV data will now be\ntracked during sessions.'
              : showFallback
                  ? 'No Polar device was found during this scan.'
                  : 'Select a device below to pair it with the app.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: _kTextSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── "Found devices" divider ───────────────────────────────────────────────────

class _FoundDevicesDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _kBorderColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Found devices',
            style: const TextStyle(
              fontSize: 12,
              color: _kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: _kBorderColor, thickness: 1)),
      ],
    );
  }
}

// ── Permission denied view ────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth_disabled_rounded,
                  color: Color(0xFFEF4444), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bluetooth permission required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Allow Bluetooth access in Settings so the app can find and connect to your Polar device.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: _kTextSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: openAppSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kConnectBtnBg,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Open Settings',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Device list ───────────────────────────────────────────────────────────────

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    required this.state,
    required this.showFallback,
  });

  final PolarState state;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    if (state.discoveredDevices.isEmpty && !state.isConnected) {
      if (showFallback) return const _DemoDeviceCard();
      return const _EmptySearchState();
    }

    return Column(
      children: state.discoveredDevices
          .map((device) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DeviceCard(device: device, state: state),
              ))
          .toList(),
    );
  }
}

class _DemoDeviceCard extends StatefulWidget {
  const _DemoDeviceCard();

  @override
  State<_DemoDeviceCard> createState() => _DemoDeviceCardState();
}

class _DemoDeviceCardState extends State<_DemoDeviceCard> {
  bool _connecting = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _connecting ? _kConnectingBg : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _connecting ? const Color(0xFFBFDBFE) : _kBorderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _connecting ? _kConnectingBg : const Color(0xFFEAF7FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bluetooth_rounded,
              size: 18,
              color: _connecting ? _kConnectingText : _kSearchIconBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Polar H10 (Demo)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _connecting ? 'Connecting...' : 'H10',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _connecting ? _kConnectingText : _kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_connecting)
            const Text(
              'Connecting',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kConnectingText,
              ),
            )
          else
            _ConnectButton(
              onTap: () async {
                setState(() => _connecting = true);
                final bloc = context.read<PolarBloc>();
                await StorageService.setPolarConnectionMode('demo');
                if (!mounted) return;
                bloc.add(const PolarDemoConnectRequested());
              },
            ),
        ],
      ),
    );
  }
}

class _TroubleshootCard extends StatelessWidget {
  const _TroubleshootCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Having trouble?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Can’t find your device? Make sure your Polar is awake and close by, or continue without it for now.',
            style: TextStyle(
              fontSize: 13,
              color: _kTextSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: _kDoneBtnBg,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Troubleshoot / Try again',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state while scanning ────────────────────────────────────────────────

class _EmptySearchState extends StatefulWidget {
  const _EmptySearchState();

  @override
  State<_EmptySearchState> createState() => _EmptySearchStateState();
}

class _EmptySearchStateState extends State<_EmptySearchState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          FadeTransition(
            opacity: _opacity,
            child: const Icon(Icons.wifi_tethering_rounded,
                size: 36, color: _kTextSecondary),
          ),
          const SizedBox(height: 10),
          const Text(
            'Looking for the device',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This usually takes a few seconds',
            style: TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Individual device card ────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.state});
  final PolarDiscoveredDevice device;
  final PolarState state;

  bool get _isConnectingThis =>
      state.isConnecting && state.connectedDeviceId == device.deviceId;

  bool get _isConnectedThis =>
      state.isConnected && state.connectedDeviceId == device.deviceId;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isConnectingThis
            ? _kConnectingBg
            : _isConnectedThis
                ? _kConnectedBg
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isConnectingThis
              ? const Color(0xFFBFDBFE)
              : _isConnectedThis
                  ? const Color(0xFFBBF7D0)
                  : _kBorderColor,
        ),
      ),
      child: Row(
        children: [
          _BluetoothAvatar(
            isConnectedThis: _isConnectedThis,
            isConnectingThis: _isConnectingThis,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isConnectedThis)
                  const Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kConnectedText,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (_isConnectingThis)
                  const _ConnectingDots()
                else
                  Text(
                    device.deviceType ?? 'Polar device',
                    style:
                        const TextStyle(fontSize: 12, color: _kTextSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isConnectedThis)
            const Icon(Icons.check_circle_outline_rounded,
                color: _kConnectedText, size: 22)
          else if (_isConnectingThis)
            const Text(
              'Connecting',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kConnectingText,
              ),
            )
          else
            _ConnectButton(
              onTap: () {
                context
                    .read<PolarBloc>()
                    .add(PolarConnectRequested(device.deviceId));
              },
            ),
        ],
      ),
    );
  }
}

class _BluetoothAvatar extends StatelessWidget {
  const _BluetoothAvatar({
    required this.isConnectedThis,
    required this.isConnectingThis,
  });
  final bool isConnectedThis;
  final bool isConnectingThis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isConnectedThis
            ? _kConnectedBg
            : isConnectingThis
                ? _kConnectingBg
                : const Color(0xFFEAF7FA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.bluetooth_rounded,
        size: 18,
        color: isConnectedThis
            ? _kConnectedText
            : isConnectingThis
                ? _kConnectingText
                : _kSearchIconBg,
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: _kConnectBtnBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Connect',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Animated "• •" dots for connecting state ──────────────────────────────────

class _ConnectingDots extends StatefulWidget {
  const _ConnectingDots();

  @override
  State<_ConnectingDots> createState() => _ConnectingDotsState();
}

class _ConnectingDotsState extends State<_ConnectingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          children: [
            _Dot(opacity: math.sin(t * math.pi * 2).abs()),
            const SizedBox(width: 4),
            _Dot(opacity: math.sin((t + 0.3) * math.pi * 2).abs()),
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.2, 1.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: _kConnectingText,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── "Done Let's go" CTA at bottom ────────────────────────────────────────────

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            await StorageService.setPolarEnabled(true);
            await StorageService.setOnboardingComplete(true);
            if (StorageService.getPolarConnectionMode() != 'demo') {
              await StorageService.setPolarConnectionMode('connected');
            }
            if (context.mounted) context.go('/heartrate');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _kDoneBtnBg,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Done Let's go",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ContinueWithoutDeviceButton extends StatelessWidget {
  const _ContinueWithoutDeviceButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            await StorageService.setPolarEnabled(false);
            await StorageService.setOnboardingComplete(true);
            if (context.mounted) context.go('/home');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _kDoneBtnBg,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Continue without Polar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
