import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../features/saarthi/presentation/screens/saarthi_chat_screen.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: DSColors.appBackground,
      body: Stack(
        children: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: DSColors.brand,
                backgroundColor: DSColors.appCard,
                onRefresh: () async {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (state is DashboardLoading)
                      SliverFillRemaining(
                        child: _LoadingSkeleton(topPad: topPad),
                      )
                    else if (state is DashboardError)
                      SliverFillRemaining(
                        child: _ErrorView(
                          message: state.message,
                          onRetry: () => context
                              .read<DashboardBloc>()
                              .add(const DashboardLoadRequested()),
                        ),
                      )
                    else if (state is DashboardLoaded)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          topPad + 8,
                          16,
                          bottomPad + 80,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _DashboardContent(data: state.data),
                          ]),
                        ),
                      )
                    else
                      SliverFillRemaining(
                        child: _LoadingSkeleton(topPad: topPad),
                      ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16 + bottomPad,
            right: 16,
            child: _SaarthiFloatingButton(
              onTap: () => context.push('/saarthi'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main content ─────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final DashboardDataEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DSSpacing.lg),
        _HomeHeader(data: data),
        const SizedBox(height: 16),
        const _AssessmentReminderCard(),
        _MetricsGrid(data: data),
        const SizedBox(height: 16),
        _SessionActionCard(onTap: () => context.push('/checkin')),
        const SizedBox(height: 16),
        const _CoachSummaryCard(),
        const SizedBox(height: DSSpacing.xxl),
      ],
    );
  }
}

// ─── Home header ──────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.data});

  final DashboardDataEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Astra Performance',
                    style: DSTypography.caption.copyWith(
                      color: DSColors.brand,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Athlete Home',
                    style: DSTypography.headingXl.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Human-centered training guidance from Astra',
                    style: DSTypography.bodySm.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: DSColors.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: DSColors.textSecondary,
                    size: 20,
                  ),
                ),
                if (data.streakDays != null && data.streakDays! > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.brand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: DSColors.brand.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${data.streakDays}d streak',
                          style: DSTypography.caption.copyWith(
                            color: DSColors.brand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        if (data.isPolarConnected) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: DSColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: DSColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Polar connected',
                  style: DSTypography.caption.copyWith(
                    color: DSColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Metrics grid ─────────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.data});

  final DashboardDataEntity data;

  @override
  Widget build(BuildContext context) {
    final r = data.readiness;

    final readinessScore = r.readinessScore.round().clamp(0, 100);
    final readinessStatus = switch (r.readinessLevel) {
      ReadinessLevel.ready => 'ready',
      ReadinessLevel.moderate => 'moderate',
      ReadinessLevel.needsRecovery => 'needs recovery',
    };
    final readinessColor = switch (r.readinessLevel) {
      ReadinessLevel.ready => DSColors.success,
      ReadinessLevel.moderate => DSColors.brand,
      ReadinessLevel.needsRecovery => DSColors.error,
    };

    final recoveryScore = r.energyLevel.round().clamp(0, 100);
    final recoveryStatus =
        recoveryScore > 66 ? 'good' : recoveryScore > 33 ? 'acceptable' : 'low';
    final recoveryColor = recoveryScore > 66
        ? DSColors.success
        : recoveryScore > 33
            ? DSColors.brand
            : DSColors.error;

    final stressScore = r.stressLevel.round().clamp(0, 100);
    final stressStatus =
        stressScore < 33 ? 'low' : stressScore < 66 ? 'moderate' : 'elevated';
    final stressColor = stressScore < 33
        ? DSColors.success
        : stressScore < 66
            ? DSColors.brand
            : DSColors.error;

    final mentalValue = switch (r.focusLevel) {
      FocusLevel.high => 'Calm',
      FocusLevel.medium => 'Steady',
      FocusLevel.low => 'Foggy',
    };
    final mentalStatus = switch (r.focusLevel) {
      FocusLevel.high => 'stable',
      FocusLevel.medium => 'steady',
      FocusLevel.low => 'distracted',
    };
    final mentalColor = switch (r.focusLevel) {
      FocusLevel.high => DSColors.success,
      FocusLevel.medium => DSColors.brand,
      FocusLevel.low => DSColors.error,
    };

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'READINESS',
                valueText: '$readinessScore',
                statusLabel: readinessStatus,
                statusColor: readinessColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'RECOVERY',
                valueText: '$recoveryScore',
                statusLabel: recoveryStatus,
                statusColor: recoveryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'STRESS',
                valueText: '$stressScore',
                statusLabel: stressStatus,
                statusColor: stressColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'MENTAL STATE',
                valueText: mentalValue,
                statusLabel: mentalStatus,
                statusColor: mentalColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Metric card ──────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.valueText,
    required this.statusLabel,
    required this.statusColor,
  });

  final String label;
  final String valueText;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DSTypography.labelXs.copyWith(
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            valueText,
            style: DSTypography.headingXl.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  statusLabel,
                  style: DSTypography.caption.copyWith(
                    color: DSColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Session action card ──────────────────────────────────────────────────────

class _SessionActionCard extends StatelessWidget {
  const _SessionActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Action Center',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a training session to capture full details',
            style: DSTypography.bodySm.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF2F7E8F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start Training Session',
                    style: DSTypography.bodyMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Coach quick summary card ─────────────────────────────────────────────────

class _CoachSummaryCard extends StatelessWidget {
  const _CoachSummaryCard();

  static const _tips = [
    'Start with breathing and sight alignment.',
    'Keep first block short; watch fatigue drift.',
    'Review focus trend after training.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coach Quick Summary',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < _tips.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}.',
                  style: DSTypography.bodySm.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tips[i],
                    style: DSTypography.bodySm.copyWith(
                      color: DSColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (i < _tips.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Text(
            'Performance is live. Wellness and Decisions coming soon.',
            style: DSTypography.caption.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Assessment reminder card ─────────────────────────────────────────────────

class _AssessmentReminderCard extends StatelessWidget {
  const _AssessmentReminderCard();

  static const _kTeal = Color(0xFF2F7E8F);
  static const _totalQuestions = 25;

  @override
  Widget build(BuildContext context) {
    final progress = StorageService.getQuestionnaireProgress();
    if (progress == null) return const SizedBox.shrink();

    final answers = progress['answers'] as Map<int, int>;
    final remaining = _totalQuestions - answers.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kTeal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: _kTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Psychology Assessment Pending',
                    style: DSTypography.labelMd.copyWith(
                      color: DSColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You have $remaining question${remaining == 1 ? '' : 's'} remaining',
                    style: DSTypography.bodySm.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/questions'),
              style: TextButton.styleFrom(
                backgroundColor: _kTeal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Continue',
                style: DSTypography.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Saarthi floating button ──────────────────────────────────────────────────

class _SaarthiFloatingButton extends StatelessWidget {
  const _SaarthiFloatingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F7E8F).withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const SaarthiAvatar(size: 68),
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({this.topPad = 0});

  final double topPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 120, height: 20),
                    const SizedBox(height: 6),
                    _SkeletonBox(width: 80, height: 20),
                  ],
                ),
              ),
              _SkeletonBox(width: 40, height: 40, radius: 20),
            ],
          ),
          const SizedBox(height: 8),
          _SkeletonBox(width: 110, height: 18, radius: 20),
          const SizedBox(height: 24),
          // Metrics grid skeleton
          Row(
            children: [
              Expanded(child: MetricCardSkeleton()),
              const SizedBox(width: 8),
              Expanded(child: MetricCardSkeleton()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: MetricCardSkeleton()),
              const SizedBox(width: 8),
              Expanded(child: MetricCardSkeleton()),
            ],
          ),
          const SizedBox(height: 24),
          _SkeletonBox(width: 160, height: 14),
          const SizedBox(height: 8),
          _SkeletonBox(width: double.infinity, height: 60),
          const SizedBox(height: 16),
          _SkeletonBox(width: double.infinity, height: 52),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 0.55).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: DSColors.gray100,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DSColors.error,
              size: 48,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              message,
              style: DSTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.lg),
            DSButton(
              label: 'Retry',
              onPressed: onRetry,
              variant: DSButtonVariant.brand,
            ),
          ],
        ),
      ),
    );
  }
}
