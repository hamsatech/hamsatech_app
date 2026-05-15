import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/checkin_card.dart';
import '../widgets/coach_feedback_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/weekly_stats_card.dart';

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
      body: BlocBuilder<DashboardBloc, DashboardState>(
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
        const SizedBox(height: DSSpacing.xl),

        // ── Header ──
        DashboardHeader(
          greeting: data.greeting,
          athleteName: data.athleteName,
          isPolarConnected: data.isPolarConnected,
          streakDays: data.streakDays,
          onNotificationTap: () {},
        ),

        const SizedBox(height: DSSpacing.xxl),

        // ── Metrics 2×2 grid ──
        _MetricsGrid(data: data),

        const SizedBox(height: DSSpacing.xxl),

        // ── Coach check-in section ──
        _SectionTitle(label: 'Feedback from Coach'),
        const SizedBox(height: 10),
        CheckinCard(
          isCompleted: data.todayCheckinCompleted,
          onTap: () => context.push('/checkin'),
        ),

        const SizedBox(height: DSSpacing.xl),

        // ── Start Training CTA ──
        _StartTrainingButton(
          onTap: () => context.push('/session/setup'),
        ),

        const SizedBox(height: DSSpacing.xxl),

        // ── Coach message feedback ──
        if (data.coachFeedback != null) ...[
          _SectionTitle(label: 'Feedback from Coach'),
          const SizedBox(height: 10),
          CoachFeedbackCard(
            feedback: data.coachFeedback!,
            onViewFull: () {},
            onMarkRead: () => context
                .read<DashboardBloc>()
                .add(const DashboardCoachFeedbackMarkRead()),
          ),
          const SizedBox(height: DSSpacing.xxl),
        ],

        // ── This Week ──
        _SectionTitle(label: 'This Week'),
        const SizedBox(height: 10),
        WeeklyStatsCard(stats: data.weeklyStats),

        const SizedBox(height: DSSpacing.xxl),
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
    final readiness = data.readiness;
    final sleep = data.sleep;
    final hrv = data.hrv;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Readiness',
                value: readiness.readinessScore.round().toString(),
                statusLabel: readiness.readinessLevel.label,
                statusColor: readiness.readinessLevel.color,
                valueColor: readiness.readinessLevel.color,
                progressValue: readiness.readinessScore / 100,
                progressColor: readiness.readinessLevel.color,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: MetricCard(
                title: 'Sleep',
                value: sleep.duration,
                statusLabel: sleep.quality,
                statusColor: DSColors.info,
                valueColor: DSColors.info,
                progressValue: sleep.score,
                progressColor: DSColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Resting HR',
                value: data.restingHR.toString(),
                unit: 'bpm',
                statusLabel: data.hrStatus,
                statusColor: DSColors.brand,
                valueColor: DSColors.brand,
                progressValue:
                    ((data.restingHR - 50) / 40).clamp(0.0, 1.0),
                progressColor: DSColors.brand,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: MetricCard(
                title: 'HRV Today',
                value: hrv.value.toString(),
                unit: 'ms',
                statusLabel: hrv.status,
                statusColor: DSColors.textMuted,
                valueColor: DSColors.error,
                progressValue: hrv.normalizedScore,
                progressColor: DSColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: DSTypography.bodyMedium.copyWith(
        color: DSColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ─── Start Training button ────────────────────────────────────────────────────

class _StartTrainingButton extends StatelessWidget {
  const _StartTrainingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF2F7E8F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Text(
              'Start Training Session',
              style: DSTypography.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
