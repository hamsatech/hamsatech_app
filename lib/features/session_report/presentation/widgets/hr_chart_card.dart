import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_report_entity.dart';

class HrChartCard extends StatelessWidget {
  const HrChartCard({
    super.key,
    required this.points,
    required this.metrics,
  });

  final List<HrChartPoint> points;
  final HrMetricsEntity metrics;

  @override
  Widget build(BuildContext context) {
    if (!StorageService.isPolarEnabled()) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: DSColors.white,
          border: Border.all(color: DSColors.gray200),
          borderRadius: DSRadius.borderMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Color(0xFF2F7E8F),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Polar not connected yet',
              style: DSTypography.bodyMd.copyWith(
                color: const Color(0xFF2F7E8F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (points.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: DSColors.white,
          border: Border.all(color: DSColors.gray200),
          borderRadius: DSRadius.borderMd,
        ),
        child: Center(
          child: Text(
            'No HR data recorded',
            style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
          ),
        ),
      );
    }

    final maxBpm = points.map((p) => p.bpm).reduce(max);
    final minBpm = points.map((p) => p.bpm).reduce(min);
    final chartMax = (maxBpm + 12).ceilToDouble();
    final chartMin = (minBpm - 8).floorToDouble().clamp(0.0, double.infinity);
    final interval =
        ((chartMax - chartMin) / 3).roundToDouble().clamp(5.0, double.infinity);

    final boundaryXs = points
        .where((p) => p.isSeriesBoundary)
        .map((p) => p.index.toDouble() + 0.5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Chart ────────────────────────────────────────────────────────────
        Container(
          height: 180,
          padding:
              const EdgeInsets.fromLTRB(0, DSSpacing.sm, DSSpacing.sm, 0),
          decoration: BoxDecoration(
            color: DSColors.white,
            border: Border.all(color: DSColors.gray200),
            borderRadius: DSRadius.borderMd,
          ),
          child: LineChart(
            LineChartData(
              minY: chartMin,
              maxY: chartMax,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: DSColors.gray100,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: DSColors.gray200),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: interval,
                    getTitlesWidget: (value, _) => Padding(
                      padding: const EdgeInsets.only(right: DSSpacing.xs),
                      child: Text(
                        value.toInt().toString(),
                        style: DSTypography.labelXs
                            .copyWith(color: DSColors.textMuted),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(
                verticalLines: boundaryXs
                    .map(
                      (x) => VerticalLine(
                        x: x,
                        color: DSColors.gray300,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    )
                    .toList(),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: points
                      .map((p) => FlSpot(p.index.toDouble(), p.bpm))
                      .toList(),
                  isCurved: true,
                  curveSmoothness: 0.25,
                  color: DSColors.error,
                  barWidth: 1.5,
                  isStrokeCapRound: false,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, pct, bar, idx) {
                      if (idx < points.length && points[idx].isSpike) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: DSColors.error,
                          strokeColor: DSColors.error,
                          strokeWidth: 0,
                        );
                      }
                      return FlDotCirclePainter(
                        radius: 0,
                        color: Colors.transparent,
                        strokeColor: Colors.transparent,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: DSColors.error.withValues(alpha: 0.06),
                  ),
                ),
              ],
              lineTouchData: const LineTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        // ── Legend ────────────────────────────────────────────────────────────
        Row(
          children: [
            _LegendItem(
              indicator: Container(
                  width: 20, height: 2, color: DSColors.error),
              label: 'Avg HR',
            ),
            const SizedBox(width: DSSpacing.lg),
            _LegendItem(
              indicator: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: DSColors.error),
              ),
              label: 'Spike',
            ),
            const SizedBox(width: DSSpacing.lg),
            _LegendItem(
              indicator: _DottedLine(),
              label: 'Series boundary',
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.lg),
        // ── Stats ─────────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatBlock(
                label: 'Avg pre-shot HR',
                value: '${metrics.avgPreShotHr} bpm',
              ),
            ),
            Expanded(
              child: _StatBlock(
                label: 'HR spikes (>${metrics.spikeThreshold} bpm)',
                value: '${metrics.spikeCount}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.indicator, required this.label});

  final Widget indicator;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        indicator,
        const SizedBox(width: DSSpacing.xs),
        Text(
          label,
          style: DSTypography.labelXs.copyWith(color: DSColors.textSecondary),
        ),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 2,
      child: CustomPaint(painter: _DottedLinePainter()),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DSColors.gray400
      ..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 3).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += 6;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter _) => false;
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DSTypography.labelXs.copyWith(color: DSColors.textSecondary),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          value,
          style: DSTypography.headingMd.copyWith(color: DSColors.black),
        ),
      ],
    );
  }
}
