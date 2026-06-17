import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/session_summary_bloc.dart';
import '../../bloc/session_summary_event.dart';
import '../../bloc/session_summary_state.dart';
import '../../domain/entities/session_summary_entity.dart';

const _kTeal = Color(0xFF2F7E8F);

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SessionSummaryBloc>()
          .add(const SessionSummaryLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionSummaryBloc, SessionSummaryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DSColors.appBackground,
          appBar: AppBar(
            backgroundColor: DSColors.appBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: DSColors.black),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: switch (state) {
            SessionSummaryLoading() ||
            SessionSummaryInitial() =>
              const Center(child: CircularProgressIndicator(color: _kTeal)),
            SessionSummaryError(:final message) => Center(
                child: Text(
                  message,
                  style: DSTypography.bodyMd
                      .copyWith(color: DSColors.textSecondary),
                ),
              ),
            SessionSummaryLoaded(:final data) => _SessionsDashboard(data: data),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ── Dashboard body ────────────────────────────────────────────────────────────

class _SessionsDashboard extends StatelessWidget {
  const _SessionsDashboard({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page header ────────────────────────────────────────────
                _PageHeader(),
                const SizedBox(height: 20),

                // ── 2×2 Metric cards ───────────────────────────────────────
                _MetricsGrid(data: data),
                const SizedBox(height: 16),

                // ── Last Session Summary ───────────────────────────────────
                _LastSessionSummaryCard(data: data),
                const SizedBox(height: 16),

                // ── Session History ────────────────────────────────────────
                _SessionHistoryCard(data: data),
                const SizedBox(height: 16),

                // ── Score Analysis ─────────────────────────────────────────
                _ScoreAnalysisCard(data: data),
              ],
            ),
          ),
        ),

        // ── Fixed bottom CTA ──────────────────────────────────────────────
        const Divider(height: 1, thickness: 1, color: DSColors.gray200),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: DSPrimaryButton(
              label: 'Save & View Full Report',
              color: _kTeal,
              onPressed: () => context.go('/session/analytics'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
          'Sessions',
          style: DSTypography.headingXl.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Last session summary, history and score analysis',
          style: DSTypography.bodySm.copyWith(
            color: DSColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── 2×2 Metric cards ─────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.totalShots > 0;

    // Performance: per-shot average (e.g. 9.6)
    final perfValue = hasData ? data.formattedAverage : '—';
    final perfLabel = hasData ? 'last session' : 'no data yet';
    final perfColor = DSColors.success;

    // Readiness: efficiency % (how close to max possible)
    final readValue = hasData ? data.formattedEfficiency : '—';
    final readLabel = hasData
        ? (data.efficiency > 70
            ? 'well optimised'
            : data.efficiency > 45
                ? 'warm up slowly'
                : 'needs work')
        : 'no data yet';
    final readColor = data.efficiency > 70
        ? DSColors.success
        : data.efficiency > 45
            ? const Color(0xFFF59E0B)
            : DSColors.error;

    // Hold Stability: best shot score
    final holdValue = hasData ? data.formattedBestShot : '—';
    final holdLabel = hasData ? 'session best' : 'no data yet';
    final holdColor = DSColors.brand;

    // Mental Score: from mood correlation or derived
    final mentalValue = data.moodCorrelation != null
        ? '${(data.moodCorrelation!.moodRating * 20).clamp(0, 100)}'
        : hasData
            ? '${(data.efficiency * 0.9).round().clamp(0, 100)}'
            : '—';
    final mentalLabel = data.moodCorrelation?.moodLabel ?? 'steady focus';
    const mentalColor = _kTeal;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'PERFORMANCE',
                value: perfValue,
                subLabel: perfLabel,
                dotColor: perfColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'READINESS',
                value: readValue,
                subLabel: readLabel,
                dotColor: readColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'HOLD STABILITY',
                value: holdValue,
                subLabel: holdLabel,
                dotColor: holdColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'MENTAL SCORE',
                value: mentalValue,
                subLabel: mentalLabel,
                dotColor: mentalColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.dotColor,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color dotColor;

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
            value,
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
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subLabel,
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

// ── Last Session Summary card ─────────────────────────────────────────────────

class _LastSessionSummaryCard extends StatelessWidget {
  const _LastSessionSummaryCard({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.totalShots > 0;

    final insight = data.moodCorrelation?.moodState.isNotEmpty == true
        ? data.moodCorrelation!.moodState
        : 'Stable hold with recovery watch';

    final detailLine = hasData
        ? 'Avg ${data.formattedAverage}/shot · ${data.totalShots} shots · ${data.duration}'
        : 'No shots recorded in this session.';

    final focusLine = hasData
        ? 'Best series: ${data.bestSeriesLabel} · Worst: ${data.worstSeriesLabel}'
        : 'Start a session from the dashboard to track performance.';

    return Container(
      padding: const EdgeInsets.all(18),
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
            'Last Session Summary',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            insight,
            style: DSTypography.bodyMd.copyWith(
              color: _kTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detailLine,
            style: DSTypography.bodySm.copyWith(
              color: DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            focusLine,
            style: DSTypography.bodySm.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session History card ──────────────────────────────────────────────────────

class _SessionHistoryCard extends StatelessWidget {
  const _SessionHistoryCard({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.totalShots > 0;

    return Container(
      padding: const EdgeInsets.all(18),
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
            'Session History',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (hasData) ...[
            _HistoryRow(
              dateLabel: 'Latest',
              scoreLabel: 'Score ${data.formattedAverage}',
              readyLabel: 'Eff ${data.formattedEfficiency}%',
              fatigueLabel: 'Best ${data.bestSeriesLabel}',
              scoreColor: DSColors.success,
              readyColor: const Color(0xFFF59E0B),
              fatigueColor: DSColors.error,
            ),
            const SizedBox(height: 10),
            _HistoryRow(
              dateLabel: 'Earlier',
              scoreLabel: 'Worst ${data.worstSeriesLabel}',
              readyLabel: 'Shots ${data.totalShots}',
              fatigueLabel: data.duration,
              scoreColor: DSColors.success,
              readyColor: const Color(0xFFF59E0B),
              fatigueColor: DSColors.textSecondary,
            ),
          ] else
            Text(
              'Complete a session to see history here.',
              style: DSTypography.bodySm.copyWith(
                color: DSColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.dateLabel,
    required this.scoreLabel,
    required this.readyLabel,
    required this.fatigueLabel,
    required this.scoreColor,
    required this.readyColor,
    required this.fatigueColor,
  });

  final String dateLabel;
  final String scoreLabel;
  final String readyLabel;
  final String fatigueLabel;
  final Color scoreColor;
  final Color readyColor;
  final Color fatigueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            dateLabel,
            style: DSTypography.caption.copyWith(
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            scoreLabel,
            style: DSTypography.caption.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            readyLabel,
            style: DSTypography.caption.copyWith(
              color: readyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            fatigueLabel,
            style: DSTypography.caption.copyWith(
              color: fatigueColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Score Analysis card ───────────────────────────────────────────────────────

class _ScoreAnalysisCard extends StatelessWidget {
  const _ScoreAnalysisCard({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final hasData = data.totalShots > 0;

    final headline = hasData
        ? 'Avg ${data.formattedAverage}/shot · efficiency at ${data.formattedEfficiency}%.'
        : 'No session data to analyse yet.';

    final detail = hasData
        ? 'Best shot: ${data.formattedBestShot} · Worst: ${data.formattedWorstShot} · '
            'Consistency gap: ${(data.bestShot - data.worstShot).toStringAsFixed(1)} pts.'
        : 'Complete a training session to see your score analysis here.';

    return Container(
      padding: const EdgeInsets.all(18),
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
            'Score Analysis',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: DSTypography.bodyMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            style: DSTypography.bodySm.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
