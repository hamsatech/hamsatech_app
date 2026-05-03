import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../bloc/baseline_bloc.dart';
import '../bloc/baseline_event.dart';
import '../bloc/baseline_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public reusable instruction card (Phase 1)
// ─────────────────────────────────────────────────────────────────────────────

class InstructionItemCard extends StatelessWidget {
  const InstructionItemCard({
    super.key,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
  });

  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderLg,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: DSRadius.borderMd,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: DSSpacing.md),
          Text(
            title,
            style: DSTypography.headingSm.copyWith(color: DSColors.gray900),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Root view — BlocConsumer handles navigation; builder switches all 3 phases
// ─────────────────────────────────────────────────────────────────────────────

class BaselineView extends StatelessWidget {
  const BaselineView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BaselineBloc, BaselineState>(
      // Fire only when the navigate flag flips to true
      listenWhen: (prev, curr) => !prev.navigateToNext && curr.navigateToNext,
      listener: (context, state) => context.go('/onboarding-completion'),
      builder: (context, state) {
        final bloc = context.read<BaselineBloc>();
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: switch (state.status) {
            BaselineStatus.instruction => _InstructionScaffold(
                key: const ValueKey('instruction'),
                state: state,
                bloc: bloc,
              ),
            BaselineStatus.capturing => _CapturingScaffold(
                key: const ValueKey('capturing'),
                state: state,
              ),
            BaselineStatus.success => _SuccessScaffold(
                key: const ValueKey('success'),
                state: state,
                bloc: bloc,
              ),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 1 — Instruction scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _InstructionScaffold extends StatelessWidget {
  const _InstructionScaffold({
    super.key,
    required this.state,
    required this.bloc,
  });

  final BaselineState state;
  final BaselineBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.xxxl,
            DSSpacing.lg,
            DSSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhaseOneHeader(state: state),
              const SizedBox(height: DSSpacing.xxxl),
              _InstructionList(state: state),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: DSSpacing.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.xs,
            DSSpacing.lg,
            DSSpacing.xxs,
          ),
          child: DSPrimaryButton(
            label: state.ctaLabel,
            color: DSColors.terracotta,
            onPressed: () => bloc.add(const OnStartPressed()),
          ),
        ),
      ),
    );
  }
}

class _PhaseOneHeader extends StatelessWidget {
  const _PhaseOneHeader({required this.state});

  final BaselineState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: DSColors.coral.withValues(alpha: 0.15),
            borderRadius: DSRadius.borderXl,
          ),
          child: const Icon(Icons.favorite, color: DSColors.coral, size: 28),
        ),
        const SizedBox(height: DSSpacing.lg),
        Text(
          state.headerTitle,
          style: DSTypography.displaySm.copyWith(
            color: DSColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          state.headerSubtitle,
          style: DSTypography.bodyMd.copyWith(color: DSColors.gray500),
        ),
      ],
    );
  }
}

class _InstructionList extends StatelessWidget {
  const _InstructionList({required this.state});

  final BaselineState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InstructionItemCard(
          iconData: Icons.bluetooth,
          iconColor: DSColors.info,
          iconBgColor: DSColors.info.withValues(alpha: 0.1),
          title: state.card1Title,
        ),
        const SizedBox(height: DSSpacing.md),
        InstructionItemCard(
          iconData: Icons.notifications_outlined,
          iconColor: DSColors.warning,
          iconBgColor: DSColors.warning.withValues(alpha: 0.1),
          title: state.card2Title,
        ),
        const SizedBox(height: DSSpacing.md),
        InstructionItemCard(
          iconData: Icons.mic_outlined,
          iconColor: DSColors.success,
          iconBgColor: DSColors.success.withValues(alpha: 0.1),
          title: state.card3Title,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 2 — Capturing scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _CapturingScaffold extends StatelessWidget {
  const _CapturingScaffold({super.key, required this.state});

  final BaselineState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Text(
                state.capturingLabel,
                style: DSTypography.bodyMd.copyWith(color: DSColors.gray500),
              ),
              const SizedBox(height: DSSpacing.xxl),
              const _HeartCircle(),
              const SizedBox(height: DSSpacing.xxl),
              _BpmDisplay(bpm: state.bpm, bpmLabel: state.bpmLabel),
              const SizedBox(height: DSSpacing.xxxl),
              const _WaveformBars(),
              const SizedBox(height: DSSpacing.xxl),
              _TimerRow(state: state),
              const SizedBox(height: DSSpacing.md),
              _ProgressBar(progress: state.progress),
              const SizedBox(height: DSSpacing.lg),
              Text(
                state.footerText,
                style: DSTypography.bodySm.copyWith(color: DSColors.gray500),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 3 — Success / result scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessScaffold extends StatelessWidget {
  const _SuccessScaffold({
    super.key,
    required this.state,
    required this.bloc,
  });

  final BaselineState state;
  final BaselineBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Green success circle ─────────────────────────────────────
              const _SuccessCircle(),
              const SizedBox(height: DSSpacing.xxl),

              // ── "Your resting heart rate is" ─────────────────────────────
              Text(
                state.successTitle,
                style:
                    DSTypography.bodyLg.copyWith(color: DSColors.gray700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.lg),

              // ── Final BPM (green, stable) ─────────────────────────────────
              Text(
                '${state.bpm}',
                style: DSTypography.scoreDisplay.copyWith(
                  color: DSColors.success,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                state.bpmLabel,
                style: DSTypography.labelMd.copyWith(color: DSColors.gray500),
              ),
              const SizedBox(height: DSSpacing.xxxl),

              // ── Info card ─────────────────────────────────────────────────
              _SavedInfoCard(state: state),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: DSSpacing.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.xs,
            DSSpacing.lg,
            DSSpacing.xxs,
          ),
          child: DSPrimaryButton(
            label: state.continueCta,
            color: DSColors.terracotta,
            onPressed: () => bloc.add(const OnContinuePressed()),
          ),
        ),
      ),
    );
  }
}

// ── Green outlined success circle ─────────────────────────────────────────────

class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DSColors.success, width: 2),
      ),
      child: const Icon(Icons.check, color: DSColors.success, size: 32),
    );
  }
}

// ── Baseline-saved info card ───────────────────────────────────────────────────

class _SavedInfoCard extends StatelessWidget {
  const _SavedInfoCard({required this.state});

  final BaselineState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.08),
        border: Border.all(
          color: DSColors.success.withValues(alpha: 0.35),
        ),
        borderRadius: DSRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.infoCardTitle,
            style: DSTypography.headingSm.copyWith(
              color: DSColors.success,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            state.infoCardBody,
            style: DSTypography.bodyMd.copyWith(color: DSColors.gray700),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Phase 2 sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeartCircle extends StatelessWidget {
  const _HeartCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: DSColors.coral.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.favorite, color: DSColors.coral, size: 36),
    );
  }
}

class _BpmDisplay extends StatelessWidget {
  const _BpmDisplay({required this.bpm, required this.bpmLabel});

  final int bpm;
  final String bpmLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            '$bpm',
            key: ValueKey(bpm),
            style: DSTypography.scoreDisplay.copyWith(
              color: DSColors.terracotta,
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          bpmLabel,
          style: DSTypography.labelMd.copyWith(color: DSColors.gray500),
        ),
      ],
    );
  }
}

class _WaveformBars extends StatefulWidget {
  const _WaveformBars();

  @override
  State<_WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<_WaveformBars> {
  static const int _barCount = 34;
  static const double _maxHeight = 36.0;
  static const double _minHeight = 4.0;

  final _random = Random();
  late List<double> _heights;
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();
    _heights = List.generate(_barCount, (_) => _nextHeight());
    _animTimer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _barCount; i++) {
          if (_random.nextDouble() > 0.4) _heights[i] = _nextHeight();
        }
      });
    });
  }

  double _nextHeight() =>
      _minHeight + _random.nextDouble() * (_maxHeight - _minHeight);

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeInOut,
              width: 4,
              height: _heights[i],
              decoration: BoxDecoration(
                color: DSColors.terracotta,
                borderRadius: DSRadius.borderFull,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  const _TimerRow({required this.state});

  final BaselineState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, color: DSColors.gray500, size: 18),
        const SizedBox(width: DSSpacing.xs),
        Text(
          state.timerText,
          style: DSTypography.headingMd.copyWith(color: DSColors.gray900),
        ),
        const SizedBox(width: DSSpacing.xs),
        Text(
          state.timerSuffix,
          style: DSTypography.bodyMd.copyWith(color: DSColors.gray500),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: DSRadius.borderFull,
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: DSColors.gray200,
        valueColor: const AlwaysStoppedAnimation<Color>(DSColors.terracotta),
      ),
    );
  }
}
