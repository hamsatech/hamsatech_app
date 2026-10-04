import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../../polar/presentation/bloc/polar_event.dart';
import '../../../polar/presentation/bloc/polar_state.dart';

class BaselineScreen extends StatelessWidget {
  const BaselineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PolarBloc>(),
      child: const _BaselineCaptureView(),
    );
  }
}

class _BaselineCaptureView extends StatefulWidget {
  const _BaselineCaptureView();

  @override
  State<_BaselineCaptureView> createState() => _BaselineCaptureViewState();
}

class _BaselineCaptureViewState extends State<_BaselineCaptureView> {
  static const _measurementDuration = Duration(seconds: 60);

  Timer? _timer;
  int _remainingSeconds = _measurementDuration.inSeconds;
  bool _completed = false;
  // Captured once, not re-read via context.read in dispose(): by the time
  // dispose() runs the element may already be unmounted, so provider
  // lookups there aren't reliable.
  late final PolarBloc _polarBloc;

  @override
  void initState() {
    super.initState();
    _polarBloc = context.read<PolarBloc>();
    if (_polarBloc.state.isConnected && !_polarBloc.state.isStreaming) {
      _polarBloc.add(const PolarStartHrStreamRequested());
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Covers every exit path uniformly — normal completion (context.go to
    // the result screen), back navigation, and any other disposal all run
    // this. Safe to call unconditionally even if streaming never started
    // or already stopped (native stopHrStream on a no-op job is a no-op).
    // Baseline capture is reachable only from the onboarding route set
    // (/baseline is onboarding-only — see AppRouter._onboardingRoutes),
    // which is always before any live training session can exist, so this
    // can never stop a stream a live session is relying on.
    _polarBloc.add(const PolarStopHrStreamRequested());
    super.dispose();
  }

  void _tick() {
    if (_completed || !mounted) return;
    if (_remainingSeconds <= 1) {
      _completeMeasurement();
      return;
    }
    setState(() => _remainingSeconds -= 1);
  }

  void _completeMeasurement() {
    if (_completed || !mounted) return;
    _completed = true;
    _timer?.cancel();
    context.go('/baseline/result');
  }

  String get _remainingLabel {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final elapsed = _measurementDuration.inSeconds - _remainingSeconds;
    return elapsed / _measurementDuration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolarBloc, PolarState>(
      builder: (context, state) {
        // No fallback value here: a Polar reading either exists or it
        // doesn't. Showing a made-up number (this used to default to 76)
        // would present a synthetic value as if it were a real
        // measurement — see BaselineResultScreen, which is the one that
        // actually persists this value, for the corresponding fix.
        final bpm = state.latestReading?.bpm;

        return Scaffold(
          backgroundColor: DSColors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Capturing baseline…',
                            textAlign: TextAlign.center,
                            style: DSTypography.headingLg.copyWith(
                              color: const Color(0xFF000F12),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const _CaptureHeartMark(),
                          const SizedBox(height: 32),
                          Text(
                            bpm?.toString() ?? '—',
                            style: DSTypography.scoreDisplay.copyWith(
                              color: DSColors.terracotta,
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bpm == null ? 'Waiting for signal…' : 'BPM',
                            style: DSTypography.bodyLarge.copyWith(
                              color: DSColors.textSecondary,
                              fontSize: 16,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 38),
                          const SizedBox(
                            width: 262,
                            height: 24,
                            child: CustomPaint(
                              painter: _HeartWavePainter(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _TimerLabel(remainingLabel: _remainingLabel),
                          const SizedBox(height: 18),
                          _ProgressTrack(value: _progress),
                          const SizedBox(height: 12),
                          Text(
                            'Stay still - movement affects accuracy',
                            textAlign: TextAlign.center,
                            style: DSTypography.bodyLarge.copyWith(
                              color: DSColors.textSecondary,
                              fontSize: 16,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CaptureHeartMark extends StatelessWidget {
  const _CaptureHeartMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF4),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF4A9BC)),
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: Color(0xFFEF4444),
        size: 44,
      ),
    );
  }
}

class _TimerLabel extends StatelessWidget {
  const _TimerLabel({required this.remainingLabel});

  final String remainingLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 24,
          color: const Color(0xFF000F12),
        ),
        const SizedBox(width: 8),
        Text(
          remainingLabel,
          style: DSTypography.headingXl.copyWith(
            color: const Color(0xFF000F12),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'remaining',
          style: DSTypography.headingLg.copyWith(
            color: const Color(0xFF000F12),
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: const Color(0xFFB0D8E0),
          valueColor: const AlwaysStoppedAnimation<Color>(
            DSColors.terracotta,
          ),
        ),
      ),
    );
  }
}

class _HeartWavePainter extends CustomPainter {
  const _HeartWavePainter();

  static const _bars = <double>[
    0.48,
    0.58,
    0.44,
    0.78,
    0.32,
    0.36,
    0.34,
    0.92,
    0.40,
    0.38,
    0.42,
    0.52,
    0.62,
    0.36,
    0.50,
    0.94,
    0.40,
    0.38,
    0.54,
    0.82,
    0.62,
    0.66,
    0.70,
    0.54,
    0.86,
    0.44,
    0.34,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square;
    final gap = size.width / (_bars.length - 1);
    final centerY = size.height / 2;

    for (var i = 0; i < _bars.length; i++) {
      final x = i * gap;
      final height = math.max(4.0, size.height * _bars[i]);
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
