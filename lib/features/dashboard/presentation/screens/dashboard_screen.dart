import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/astra_logo.dart';
import '../../../../core/widgets/saarthi_avatar.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../polar/presentation/bloc/polar_bloc.dart';
import '../../../polar/presentation/bloc/polar_state.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/coach_feedback_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/performance_chart_card.dart';
import '../widgets/weekly_stats_card.dart';

// "Connected" must reflect only the actual current PolarBloc BLE state —
// the persisted "has ever paired" flag (`data.isPolarConnected`) previously
// caused a false-positive "Connected" badge on cold start, since PolarBloc
// starts at `initial` (not a live connection) and nothing re-verifies the
// real BLE link at startup.
bool _isPolarLiveConnected(PolarState polarState) {
  return polarState.connectionStatus == PolarConnectionStatus.connected;
}

// PolarState changes on every HR sample (~1/sec while streaming); only
// connectionStatus affects _isPolarLiveConnected's output, so gate rebuilds
// on that field alone rather than the default "rebuild on every emission".
bool _polarConnectionStatusChanged(PolarState previous, PolarState current) =>
    previous.connectionStatus != current.connectionStatus;

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
        BlocBuilder<PolarBloc, PolarState>(
          bloc: getIt<PolarBloc>(),
          buildWhen: _polarConnectionStatusChanged,
          builder: (context, polarState) {
            if (_isPolarLiveConnected(polarState)) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PolarConnectCard(onTap: () => context.push('/polar')),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        _AssessmentReminderCard(
          answeredCount: data.assessmentAnsweredCount,
          totalQuestions: data.assessmentTotalQuestions,
          isComplete: data.assessmentIsComplete,
        ),
        const _WellnessUnavailableCard(),
        const SizedBox(height: 16),
        WeeklyStatsCard(
          sessionCount: data.sessionsThisWeek,
          averageScore: data.weeklyAvgScore,
        ),
        const SizedBox(height: 16),
        _SessionActionCard(onTap: () => context.push('/checkin')),
        const SizedBox(height: 16),
        PerformanceChartCard(history: data.performanceHistory),
        const SizedBox(height: 16),
        if (data.coachFeedback != null) ...[
          CoachFeedbackCard(
            feedback: data.coachFeedback!,
            onViewFull: () {},
            onMarkRead: () => context
                .read<DashboardBloc>()
                .add(const DashboardCoachFeedbackMarkRead()),
          ),
          const SizedBox(height: 16),
        ],
        if (data.aiInsights.isNotEmpty) ...[
          AiInsightsCard(insights: data.aiInsights),
          const SizedBox(height: 16),
        ] else
          const _InsightsUnavailableCard(),
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
                  const AstraLogoCompact(
                    symbolSize: 22,
                    textColor: Color(0xFF2F7E8F),
                  ),
                  const SizedBox(height: 6),
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
                _HeaderActions(),
                if (data.streakDays != null && data.streakDays! > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        BlocBuilder<PolarBloc, PolarState>(
          bloc: getIt<PolarBloc>(),
          buildWhen: _polarConnectionStatusChanged,
          builder: (context, polarState) {
            if (!_isPolarLiveConnected(polarState)) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            );
          },
        ),
      ],
    );
  }
}

// ─── Header action buttons ────────────────────────────────────────────────────

class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Feedback',
          onTap: () => _showFeedbackSheet(context),
        ),
        const SizedBox(width: 8),
        _ActionIconButton(
          icon: Icons.notifications_none_rounded,
          label: 'Alerts',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No new notifications'),
                backgroundColor: DSColors.brand,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _ActionIconButton(
          icon: Icons.logout_rounded,
          label: 'Logout',
          onTap: () => _showLogoutDialog(context),
          isDestructive: true,
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? DSColors.error : DSColors.textSecondary;
    final bgColor = isDestructive
        ? DSColors.error.withValues(alpha: 0.08)
        : DSColors.gray100;
    final borderColor = isDestructive
        ? DSColors.error.withValues(alpha: 0.18)
        : DSColors.gray200;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDestructive ? DSColors.error : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feedback bottom sheet ────────────────────────────────────────────────────

void _showFeedbackSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FeedbackBottomSheet(),
  );
}

class _FeedbackBottomSheet extends StatelessWidget {
  const _FeedbackBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DSColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Send Feedback',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Help us improve Astra by sharing your thoughts.',
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _FeedbackOption(
            icon: Icons.thumb_up_outlined,
            label: 'I love something',
            color: DSColors.success,
          ),
          const SizedBox(height: 10),
          _FeedbackOption(
            icon: Icons.bug_report_outlined,
            label: 'Report a bug',
            color: DSColors.error,
          ),
          const SizedBox(height: 10),
          _FeedbackOption(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Suggest a feature',
            color: DSColors.brand,
          ),
        ],
      ),
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  const _FeedbackOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: DSTypography.bodyMd.copyWith(
                  color: DSColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.7),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout dialog ────────────────────────────────────────────────────────────

void _showLogoutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: DSColors.appCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Logout from Astra?',
        style: DSTypography.headingMd.copyWith(
          color: DSColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'You will be returned to the login screen.',
        style: DSTypography.bodyMd.copyWith(color: DSColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: Text(
            'Cancel',
            style: DSTypography.labelMd.copyWith(color: DSColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogCtx);
            // Route through the same AuthRepository.logout() the Profile
            // screen's Sign Out uses, so every logout path clears the JWT,
            // secure storage, and all cached athlete-specific local state —
            // not just the auth token.
            await getIt<AuthRepository>().logout();
            if (context.mounted) context.go('/welcome');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DSColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Logout',
            style: DSTypography.labelMd.copyWith(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

// ─── Polar empty state ───────────────────────────────────────────────────────

class _PolarConnectCard extends StatelessWidget {
  const _PolarConnectCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F7E8F).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFD5EEF3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFF2F7E8F),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Polar not connected',
                      style: DSTypography.labelMd.copyWith(
                        color: DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connect Polar to unlock BPM, HRV, and physiology insights.',
                      style: DSTypography.bodySm.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF2F7E8F),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Connect Polar Device',
                style: DSTypography.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wellness metrics — honest "not available" state ────────────────────────
//
// Readiness/Recovery/Stress/Mental-State used to be shown here as numbers —
// including a hardcoded 60 for any athlete with no cached baseline, which
// was effectively every athlete, since nothing ever populated that cache.
// No backend endpoint or sensor provides these today (confirmed against
// current source: DashboardHomeResponse only returns sessions_this_week /
// weekly_avg_score), so rather than invent a formula, this is now an
// explicit unavailable state.

class _WellnessUnavailableCard extends StatelessWidget {
  const _WellnessUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DSColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.insights_outlined,
                color: DSColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness metrics not available yet',
                  style: DSTypography.labelMd.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Readiness, recovery, and stress scores are coming soon.',
                  style: DSTypography.bodySm.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ],
            ),
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

// ─── AI insights — honest "not available yet" state ──────────────────────────
//
// Shown only when hamsatech.ai_insights genuinely has no rows for this
// athlete yet (e.g. psychology assessment not completed/scored) — never
// replaced with canned/static copy pretending to be a real insight.

class _InsightsUnavailableCard extends StatelessWidget {
  const _InsightsUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DSColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: DSColors.info, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insights', style: DSTypography.headingSmall),
                const SizedBox(height: 2),
                Text(
                  'Complete your psychology assessment to unlock personalized insights.',
                  style: DSTypography.bodySmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Assessment reminder card ─────────────────────────────────────────────────

class _AssessmentReminderCard extends StatelessWidget {
  const _AssessmentReminderCard({
    required this.answeredCount,
    required this.totalQuestions,
    required this.isComplete,
  });

  final int answeredCount;
  final int totalQuestions;
  final bool isComplete;

  static const _kTeal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    // Driven by GET /api/v2/psychology-assessment (via DashboardDataEntity) —
    // totalQuestions == 0 means the status hasn't been fetched successfully
    // yet (no athlete_id, or a non-fatal API failure), so stay hidden.
    final shouldShowReminder = !isComplete && totalQuestions > 0;

    debugPrint(
      '[HomeAssessmentReminder] answeredCount=$answeredCount '
      'totalQuestions=$totalQuestions isComplete=$isComplete '
      'reminderVisible=$shouldShowReminder',
    );

    if (!shouldShowReminder) return const SizedBox.shrink();

    final remaining =
        (totalQuestions - answeredCount).clamp(1, totalQuestions).toInt();

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
              onPressed: () async {
                await context.push('/questions');
                // Refresh the live DashboardBloc instance this widget is
                // already listening to — the assessment flow may have
                // advanced or completed progress server-side while away.
                if (context.mounted) {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                }
              },
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

class _SaarthiFloatingButton extends StatefulWidget {
  const _SaarthiFloatingButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SaarthiFloatingButton> createState() => _SaarthiFloatingButtonState();
}

class _SaarthiFloatingButtonState extends State<_SaarthiFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _pulseAnim.value,
          child: child,
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
