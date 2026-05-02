import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../../../core/di/injection.dart';
import '../bloc/polar_bloc.dart';
import '../bloc/polar_event.dart';
import '../bloc/polar_state.dart';

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
  final _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _deviceIdController.dispose();
    super.dispose();
  }

  void _connect(BuildContext context) {
    final deviceId = _deviceIdController.text.trim().toUpperCase();
    if (deviceId.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<PolarBloc>().add(PolarConnectRequested(deviceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.appBackground,
      appBar: AppBar(
        backgroundColor: DSColors.appBackground,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: DSColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Polar Device',
          style: TextStyle(
            color: DSColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<PolarBloc, PolarState>(
        listener: (context, state) {
          if (state.connectionStatus == PolarConnectionStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: DSColors.error,
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ConnectCard(
                  controller: _deviceIdController,
                  state: state,
                  onConnect: () => _connect(context),
                  onDisconnect: () => context
                      .read<PolarBloc>()
                      .add(const PolarDisconnectRequested()),
                ),
                const SizedBox(height: 24),
                if (state.isConnected) ...[
                  _HrDisplay(state: state),
                  const SizedBox(height: 20),
                  _RrIntervalsCard(state: state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  const _ConnectCard({
    required this.controller,
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
  });

  final TextEditingController controller;
  final PolarState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;
    final isConnecting =
        state.connectionStatus == PolarConnectionStatus.connecting;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? const Color(0xFF34D399)
                      : isConnecting
                          ? DSColors.brand
                          : DSColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected
                    ? 'Connected · ${state.connectedDeviceId}'
                    : isConnecting
                        ? 'Connecting...'
                        : 'Not connected',
                style: TextStyle(
                  fontSize: 13,
                  color: isConnected
                      ? const Color(0xFF34D399)
                      : DSColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isConnected && !isConnecting) ...[
            Container(
              decoration: BoxDecoration(
                color: DSColors.appCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DSColors.appBorder),
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontSize: 16,
                  color: DSColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'Device ID (e.g. A1B2C3)',
                  hintStyle: TextStyle(
                    color: DSColors.textMuted,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.bluetooth_rounded,
                      color: DSColors.brand, size: 20),
                ),
                onSubmitted: (_) => onConnect(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          if (isConnecting)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (isConnected)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: onDisconnect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DSColors.error,
                  side: BorderSide(color: DSColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Disconnect',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HrDisplay extends StatelessWidget {
  const _HrDisplay({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    final hr = state.latestReading;
    final hasContact = hr?.sensorContact ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: hasContact
                    ? const Color(0xFFF87171)
                    : DSColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                hasContact ? 'Sensor in contact' : 'No skin contact',
                style: TextStyle(
                  fontSize: 12,
                  color: hasContact
                      ? const Color(0xFFF87171)
                      : DSColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              hr != null ? '${hr.bpm}' : '--',
              key: ValueKey(hr?.bpm),
              style: TextStyle(
                fontSize: 88,
                fontWeight: FontWeight.w800,
                color: DSColors.textPrimary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BPM',
            style: TextStyle(
              fontSize: 16,
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w400,
              letterSpacing: 3,
            ),
          ),
          if (!state.isStreaming) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DSColors.brand,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Starting stream…',
                  style: TextStyle(
                    fontSize: 12,
                    color: DSColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RrIntervalsCard extends StatelessWidget {
  const _RrIntervalsCard({required this.state});
  final PolarState state;

  @override
  Widget build(BuildContext context) {
    final rrs = state.latestReading?.rrIntervals ?? [];
    final rmssd = state.latestReading?.rmssd ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RR INTERVALS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DSColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (rrs.isEmpty)
            Text(
              'Waiting for data…',
              style: TextStyle(color: DSColors.textMuted, fontSize: 14),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rrs.map((rr) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DSColors.appCardElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${rr}ms',
                    style: TextStyle(
                      fontSize: 13,
                      color: DSColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'RMSSD',
                  style: TextStyle(
                    fontSize: 11,
                    color: DSColors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rmssd.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 15,
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
