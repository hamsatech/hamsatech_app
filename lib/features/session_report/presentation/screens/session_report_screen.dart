import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/services/storage_service.dart';
import '../../bloc/session_report_bloc.dart';
import '../../bloc/session_report_event.dart';
import '../../bloc/session_report_state.dart';
import '../../domain/entities/session_report_entity.dart';

const _kTeal = Color(0xFF2F7E8F);
const _kAmber = Color(0xFFF59E0B);
const _kGreen = Color(0xFF22C55E);
const _kIndigo = Color(0xFF6366F1);
const _kRed = Color(0xFFEF4444);

class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({super.key});

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionReportBloc>().add(const SessionReportLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionReportBloc, SessionReportState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DSColors.appBackground,
          appBar: AppBar(
            backgroundColor: DSColors.appBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: DSColors.black),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'Today\'s Sessions',
              style: DSTypography.headingSm.copyWith(color: DSColors.black),
            ),
          ),
          body: switch (state) {
            SessionReportLoading() ||
            SessionReportInitial() =>
              const Center(child: CircularProgressIndicator(color: _kTeal)),
            SessionReportError(:final message) => Center(
                child: Text(
                  message,
                  style: DSTypography.bodyMd
                      .copyWith(color: DSColors.textSecondary),
                ),
              ),
            SessionReportLoaded(:final data) => _InsightsDashboard(
                data: data,
                onContinue: () => context.go('/home'),
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main dashboard body
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsDashboard extends StatelessWidget {
  const _InsightsDashboard({required this.data, required this.onContinue});

  final SessionReportEntity data;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isPolarConnected = StorageService.isPolarEnabled();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl, DSSpacing.sm, DSSpacing.xl, DSSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(data: data),
                const SizedBox(height: DSSpacing.xxl),
                const _PsychologyGrid(),
                const SizedBox(height: DSSpacing.lg),
                if (isPolarConnected)
                  _PhysiologyCard(data: data)
                else
                  const _PolarInsightsEmptyState(),
                const SizedBox(height: DSSpacing.lg),
                _PerformanceRecommendationCard(data: data),
                if (isPolarConnected) ...[
                  const SizedBox(height: DSSpacing.lg),
                  _ScoreHrTrustCard(data: data),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: DSColors.gray200),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl, DSSpacing.lg, DSSpacing.xl, DSSpacing.xxl),
            child: DSPrimaryButton(
              label: 'Save and Continue',
              color: _kTeal,
              onPressed: onContinue,
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
  const _PageHeader({required this.data});

  final SessionReportEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Astra Performance',
          style: DSTypography.bodySm.copyWith(
            color: _kTeal,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          'Insights',
          style: DSTypography.headingXl.copyWith(
            color: DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          'Psychology, physiology and score-vs-HR trust',
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Polar empty state
// ─────────────────────────────────────────────────────────────────────────────

class _PolarInsightsEmptyState extends StatelessWidget {
  const _PolarInsightsEmptyState();

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      title: 'Physiology Insights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: _kTeal,
                  size: 21,
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Polar not connected',
                      style: DSTypography.bodyMd.copyWith(
                        color: DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xxs),
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
          const SizedBox(height: DSSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/polar'),
              style: TextButton.styleFrom(
                backgroundColor: _kTeal,
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

// ─────────────────────────────────────────────────────────────────────────────
// Psychology 2 × 2 metric grid
// ─────────────────────────────────────────────────────────────────────────────

class _PsychCardData {
  const _PsychCardData(this.label, this.value, this.status, this.dotColor);

  final String label;
  final int value;
  final String status;
  final Color dotColor;
}

class _PsychologyGrid extends StatelessWidget {
  const _PsychologyGrid();

  static const _cards = [
    _PsychCardData('SOCIAL', 60, 'functional', _kGreen),
    _PsychCardData('AROUSAL', 50, 'conditioning', _kAmber),
    _PsychCardData('DECISION', 90, 'elite', _kTeal),
    _PsychCardData('FOCUS', 80, 'elite', _kIndigo),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: DSSpacing.md,
      mainAxisSpacing: DSSpacing.md,
      childAspectRatio: 1.55,
      children: _cards.map((c) => _PsychMetricCard(card: c)).toList(),
    );
  }
}

class _PsychMetricCard extends StatelessWidget {
  const _PsychMetricCard({required this.card});

  final _PsychCardData card;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            card.label,
            style: DSTypography.labelXs.copyWith(
              color: DSColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '${card.value}',
            style: DSTypography.headingXl.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: card.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                card.status,
                style: DSTypography.labelXs.copyWith(
                  color: card.dotColor,
                  fontWeight: FontWeight.w600,
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
// Physiology Explained card
// ─────────────────────────────────────────────────────────────────────────────

class _PhysiologyCard extends StatelessWidget {
  const _PhysiologyCard({required this.data});

  final SessionReportEntity data;

  @override
  Widget build(BuildContext context) {
    final avgHr = data.physiology.avgHr > 0
        ? data.physiology.avgHr
        : (data.hrMetrics.avgHr > 0 ? data.hrMetrics.avgHr : 88);
    final spikeCount = data.hrMetrics.spikeCount;

    return _InsightCard(
      title: 'Physiology Explained',
      child: Column(
        children: [
          _PhysRow(
            badge: 'HR $avgHr bpm',
            badgeColor: _kTeal,
            text: _hrText(avgHr),
          ),
          const SizedBox(height: DSSpacing.md),
          _PhysRow(
            badge: 'HRV 19 ms',
            badgeColor: _kAmber,
            text: 'Recovery signal is low; warm up patiently.',
          ),
          const SizedBox(height: DSSpacing.md),
          _PhysRow(
            badge: 'ACC ${spikeCount > 0 ? spikeCount * 25 : 100}',
            badgeColor: _kIndigo,
            text: spikeCount > 0
                ? 'Hold detected $spikeCount movement spikes.'
                : 'Very stable hold; minimal movement spikes.',
          ),
        ],
      ),
    );
  }

  String _hrText(int hr) {
    if (hr < 80) return 'Low body load; good for precision work.';
    if (hr < 100) return 'Moderate load; monitor pre-shot rhythm.';
    return 'High load; consider pacing and recovery.';
  }
}

class _PhysRow extends StatelessWidget {
  const _PhysRow({
    required this.badge,
    required this.badgeColor,
    required this.text,
  });

  final String badge;
  final Color badgeColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            style: DSTypography.labelXs.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Recommendation card
// ─────────────────────────────────────────────────────────────────────────────

class _PerformanceRecommendationCard extends StatelessWidget {
  const _PerformanceRecommendationCard({required this.data});

  final SessionReportEntity data;

  @override
  Widget build(BuildContext context) {
    final headline = data.insight.headline.isNotEmpty
        ? data.insight.headline
        : 'Begin with breathing reset, then grouped precision sets.';
    final body = data.insight.body.isNotEmpty
        ? data.insight.body
        : 'Main focus: hold stability and rhythm control.';

    return _InsightCard(
      title: 'Performance Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: DSTypography.bodyMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            body,
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
          if (data.recommendations.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Container(height: 1, color: const Color(0xFFE2F4F7)),
            const SizedBox(height: DSSpacing.md),
            ...data.recommendations.take(2).map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: _kTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(
                          child: Text(
                            r.text,
                            style: DSTypography.bodySm
                                .copyWith(color: DSColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score vs HR Trust chart card
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreHrTrustCard extends StatelessWidget {
  const _ScoreHrTrustCard({required this.data});

  final SessionReportEntity data;

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      title: 'Score vs HR Trust',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChart(),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              _LegendDot(color: _kTeal, label: 'Score trust'),
              const SizedBox(width: DSSpacing.lg),
              _LegendDot(color: _kRed, label: 'Heart rate'),
              const SizedBox(width: DSSpacing.lg),
              _LegendLine(color: _kAmber, label: 'Threshold'),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            'When HR rises above the line, score trust may drop.',
            style: DSTypography.labelXs.copyWith(
              color: DSColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final pts = data.hrPoints;
    if (pts.isEmpty) return _staticChart();

    final maxB = pts.map((p) => p.bpm).reduce(max);
    final minB = pts.map((p) => p.bpm).reduce(min);
    final chartMax = (maxB + 10).ceilToDouble();
    final chartMin = (minB - 5).floorToDouble().clamp(0.0, double.infinity);
    final range = chartMax - chartMin;
    if (range == 0) return _staticChart();

    final threshold = chartMin + range * 0.6;
    final trustSpots = <FlSpot>[];
    for (int i = 0; i < pts.length; i++) {
      final norm = (pts[i].bpm - chartMin) / range;
      final t = (1 - norm * 0.5).clamp(0.15, 1.0);
      trustSpots.add(FlSpot(i.toDouble(), chartMin + range * t));
    }

    return SizedBox(
      height: 130,
      child: LineChart(_chartData(
        hrSpots: pts.map((p) => FlSpot(p.index.toDouble(), p.bpm)).toList(),
        trustSpots: trustSpots,
        minY: chartMin,
        maxY: chartMax,
        threshold: threshold,
      )),
    );
  }

  Widget _staticChart() {
    const hrRaw = [72.0, 75.0, 78.0, 83.0, 86.0, 84.0, 80.0, 77.0, 74.0, 72.0];
    const trustRaw = [
      86.0,
      84.0,
      82.0,
      78.0,
      74.0,
      76.0,
      80.0,
      83.0,
      85.0,
      86.0
    ];
    return SizedBox(
      height: 130,
      child: LineChart(_chartData(
        hrSpots: hrRaw
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        trustSpots: trustRaw
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        minY: 60,
        maxY: 96,
        threshold: 80,
      )),
    );
  }

  LineChartData _chartData({
    required List<FlSpot> hrSpots,
    required List<FlSpot> trustSpots,
    required double minY,
    required double maxY,
    required double threshold,
  }) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: threshold,
            color: _kAmber.withValues(alpha: 0.55),
            strokeWidth: 1.5,
            dashArray: [6, 4],
          ),
        ],
      ),
      lineBarsData: [
        LineChartBarData(
          spots: hrSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: _kRed,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _kRed.withValues(alpha: 0.06),
          ),
        ),
        LineChartBarData(
          spots: trustSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: _kTeal,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _kTeal.withValues(alpha: 0.06),
          ),
        ),
      ],
      lineTouchData: const LineTouchData(enabled: false),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart legend helpers
// ─────────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: DSTypography.labelXs.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 2, color: color.withValues(alpha: 0.65)),
        const SizedBox(width: 4),
        Text(
          label,
          style: DSTypography.labelXs.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card shell
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DSTypography.headingMd.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          child,
        ],
      ),
    );
  }
}
