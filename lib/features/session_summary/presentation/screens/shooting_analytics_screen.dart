import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../bloc/session_summary_bloc.dart';
import '../../bloc/session_summary_event.dart';
import '../../bloc/session_summary_state.dart';
import '../../domain/entities/session_summary_entity.dart';

const _kTeal = Color(0xFF2F7E8F);
const _kAmber = Color(0xFFF59E0B);
const _kGreen = Color(0xFF22C55E);
const _kIndigo = Color(0xFF6366F1);
const _kRed = Color(0xFFEF4444);

class ShootingAnalyticsScreen extends StatefulWidget {
  const ShootingAnalyticsScreen({super.key});

  @override
  State<ShootingAnalyticsScreen> createState() =>
      _ShootingAnalyticsScreenState();
}

class _ShootingAnalyticsScreenState extends State<ShootingAnalyticsScreen> {
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
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: switch (state) {
            SessionSummaryLoading() || SessionSummaryInitial() =>
              const Center(child: CircularProgressIndicator(color: _kTeal)),
            SessionSummaryError(:final message) => Center(
                child: Text(
                  message,
                  style: DSTypography.bodyMd
                      .copyWith(color: DSColors.textSecondary),
                ),
              ),
            SessionSummaryLoaded(:final data) => _AnalyticsDashboard(data: data),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main body
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsDashboard extends StatelessWidget {
  const _AnalyticsDashboard({required this.data});

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
                const _PageHeader(),
                const SizedBox(height: 20),
                _MetricsGrid(data: data),
                const SizedBox(height: 16),
                _ComparisonCard(data: data),
                const SizedBox(height: 16),
                _ScorePatternCard(data: data),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: DSColors.gray200),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: DSPrimaryButton(
              label: 'Continue to Insights',
              color: _kTeal,
              onPressed: () => context.go('/session/report'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page header
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HamsaTech',
          style: DSTypography.caption.copyWith(
            color: _kTeal,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Shooting / Training',
          style: DSTypography.headingXl.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Daily session performance and average comparison',
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2 × 2 Metrics grid
// ─────────────────────────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final has = data.totalShots > 0;

    final holdTrend = has
        ? '+${(data.bestShot - data.averagePerShot).abs().toStringAsFixed(1)} vs avg'
        : 'no data';

    final consTrend = has
        ? data.efficiency >= 70
            ? '+${(data.efficiency - 70).toStringAsFixed(0)}%'
            : '${(data.efficiency - 70).toStringAsFixed(0)}%'
        : 'no data';

    final mentalRaw = data.moodCorrelation != null
        ? (data.moodCorrelation!.moodRating * 20).clamp(0, 100).toInt()
        : has
            ? (data.efficiency * 0.9).round().clamp(0, 100)
            : 0;
    final mentalTrend = data.moodCorrelation?.moodLabel ?? 'steady focus';

    final periodAvg = data.moodCorrelation?.sessionAvg ?? data.averagePerShot * 0.98;
    final scoreTrend = has
        ? '+${(data.averagePerShot - periodAvg).abs().toStringAsFixed(2)}'
        : 'no data';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'HOLD STABILITY',
                value: has ? data.formattedBestShot : '—',
                trend: holdTrend,
                dotColor: _kGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'CONSISTENCY',
                value: has ? '${data.formattedEfficiency}%' : '—',
                trend: consTrend,
                dotColor: _kTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'MENTAL FOCUS',
                value: has ? '$mentalRaw' : '—',
                trend: mentalTrend,
                dotColor: _kIndigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'LATEST SCORE',
                value: has ? data.formattedAverage : '—',
                trend: scoreTrend,
                dotColor: _kAmber,
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
    required this.trend,
    required this.dotColor,
  });

  final String label;
  final String value;
  final String trend;
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
                  trend,
                  style: DSTypography.caption
                      .copyWith(color: DSColors.textSecondary),
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

// ─────────────────────────────────────────────────────────────────────────────
// Today vs Athlete Average card
// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.data});

  final SessionSummaryEntity data;

  @override
  Widget build(BuildContext context) {
    final has = data.totalShots > 0;
    final today = has ? data.formattedAverage : '—';
    final period = has
        ? (data.moodCorrelation?.formattedAvg ??
            (data.averagePerShot * 0.98).toStringAsFixed(2))
        : '—';

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
            'Today vs Athlete Average',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ComparisonBlock(
                  label: 'Today',
                  value: today,
                  bg: const Color(0xFFEAF7FA),
                  valueColor: _kTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ComparisonBlock(
                  label: 'Period avg',
                  value: period,
                  bg: const Color(0xFFEEF2FF),
                  valueColor: _kIndigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonBlock extends StatelessWidget {
  const _ComparisonBlock({
    required this.label,
    required this.value,
    required this.bg,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color bg;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DSTypography.caption.copyWith(
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DSTypography.headingXl.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Latest Session Score Pattern card
// ─────────────────────────────────────────────────────────────────────────────

class _ScorePatternCard extends StatelessWidget {
  const _ScorePatternCard({required this.data});

  final SessionSummaryEntity data;

  static const _demo = [
    10.2, 9.8, 9.1, 10.4, 9.9,
    8.7, 10.1, 9.2, 9.7, 10.5,
    10.0, 9.3, 9.8, 10.3, 10.1,
  ];

  @override
  Widget build(BuildContext context) {
    final scores = data.scorePoints.isNotEmpty
        ? data.scorePoints.map((p) => p.value).toList()
        : _demo;

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
            'Latest Session Score Pattern',
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _ScoreGrid(scores: scores),
          const SizedBox(height: 12),
          Text(
            'Session score, focus and comparison',
            style: DSTypography.caption.copyWith(color: DSColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ScoreGrid extends StatelessWidget {
  const _ScoreGrid({required this.scores});

  final List<double> scores;

  static const _columns = 5;

  @override
  Widget build(BuildContext context) {
    final rows = (scores.length / _columns).ceil();
    return Column(
      children: List.generate(rows, (r) {
        return Padding(
          padding: EdgeInsets.only(bottom: r < rows - 1 ? 8 : 0),
          child: Row(
            children: List.generate(_columns, (c) {
              final idx = r * _columns + c;
              return Expanded(
                child: Center(
                  child: idx < scores.length
                      ? _ScoreBubble(value: scores[idx])
                      : const SizedBox(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _ScoreBubble extends StatelessWidget {
  const _ScoreBubble({required this.value});

  final double value;

  Color get _bg {
    if (value >= 10.2) return _kTeal.withValues(alpha: 0.14);
    if (value >= 9.8) return _kGreen.withValues(alpha: 0.14);
    if (value >= 9.3) return _kAmber.withValues(alpha: 0.14);
    return _kRed.withValues(alpha: 0.14);
  }

  Color get _border {
    if (value >= 10.2) return _kTeal.withValues(alpha: 0.40);
    if (value >= 9.8) return _kGreen.withValues(alpha: 0.40);
    if (value >= 9.3) return _kAmber.withValues(alpha: 0.40);
    return _kRed.withValues(alpha: 0.40);
  }

  Color get _text {
    if (value >= 10.2) return _kTeal;
    if (value >= 9.8) return const Color(0xFF16A34A);
    if (value >= 9.3) return const Color(0xFFD97706);
    return _kRed;
  }

  @override
  Widget build(BuildContext context) {
    final label = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: DSTypography.caption.copyWith(
            color: _text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
