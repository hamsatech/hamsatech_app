import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/injection.dart';
import '../bloc/polar_bloc.dart';
import '../bloc/polar_event.dart';
import '../bloc/polar_state.dart';

// ── Colours local to this screen (light theme) ───────────────────────────────
const _kBg = Colors.white;
const _kTextPrimary = Color(0xFF111827);
const _kTextSecondary = Color(0xFF6B7280);
const _kBorderColor = Color(0xFFE5E7EB);
const _kSearchIconBg = Color(0xFF2563EB);
const _kConnectedIconBg = Color(0xFF16A34A);
const _kConnectedText = Color(0xFF16A34A);
const _kConnectedBg = Color(0xFFF0FDF4);
const _kConnectBtnBg = Color(0xFF14574A);
const _kConnectingBg = Color(0xFFEFF6FF);
const _kConnectingText = Color(0xFF1D4ED8);
const _kTroubleshootText = Color(0xFFC94B2A);
const _kDoneBtnBg = Color(0xFFC94B2A);

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
    }
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
          if (state.isConnected && !state.isStreaming) {
            context.read<PolarBloc>().add(const PolarStartHrStreamRequested());
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StatusIconSection(state: state),
                        const SizedBox(height: 32),
                        _SectionHeader(state: state),
                        const SizedBox(height: 20),
                        _FoundDevicesDivider(),
                        const SizedBox(height: 16),
                        _DeviceList(state: state),
                        const SizedBox(height: 20),
                        _TroubleshootRow(),
                      ],
                    ),
                  ),
                ),
                if (state.isConnected) _DoneButton(state: state),
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
  const _StatusIconSection({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;

    return Column(
      children: [
        _StatusIcon(isConnected: isConnected),
        const SizedBox(height: 12),
        Text(
          isConnected
              ? 'Connected to ${state.connectedDeviceName ?? state.connectedDeviceId ?? 'device'}'
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
            'Make sure your Polar device is on and nearby.',
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
  const _StatusIcon({required this.isConnected});
  final bool isConnected;

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

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: _kSearchIconBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}

// ── Section header (title + subtitle) ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;
    return Column(
      children: [
        Text(
          isConnected ? 'Device connected' : 'Connecting to Polar',
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
              style: TextStyle(fontSize: 14, color: _kTextSecondary, height: 1.5),
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
  const _DeviceList({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    if (state.discoveredDevices.isEmpty && !state.isConnected) {
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
                    style: const TextStyle(
                        fontSize: 12, color: _kTextSecondary),
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
                : const Color(0xFFEFF6FF),
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

// ── Troubleshoot link ─────────────────────────────────────────────────────────

class _TroubleshootRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning_amber_rounded,
            size: 14, color: _kTextSecondary),
        const SizedBox(width: 4),
        const Text(
          "Can't find your device? ",
          style: TextStyle(fontSize: 13, color: _kTextSecondary),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Troubleshoot',
            style: TextStyle(
              fontSize: 13,
              color: _kTroubleshootText,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: _kTroubleshootText,
            ),
          ),
        ),
      ],
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
          onPressed: () => Navigator.of(context).pop(),
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
