import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_summary_entity.dart';

class ScorePaceChart extends StatelessWidget {
  const ScorePaceChart({super.key, required this.points});

  final List<ScorePointEntity> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _EmptyChart();
    }

    final maxY = (points.map((p) => p.value).reduce((a, b) => a > b ? a : b) *
            1.15)
        .ceilToDouble();
    final roundedMax = (maxY / 20).ceil() * 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(0, DSSpacing.sm, DSSpacing.sm, 0),
          decoration: BoxDecoration(
            color: DSColors.white,
            border: Border.all(color: DSColors.gray200, width: 1),
            borderRadius: DSRadius.borderMd,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: roundedMax / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: DSColors.gray100,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: roundedMax / 4,
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
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: DSSpacing.xs),
                        child: Text(
                          'S${idx + 1}',
                          style: DSTypography.labelXs
                              .copyWith(color: DSColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: DSColors.gray200, width: 1),
              ),
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: 0,
              maxY: roundedMax,
              lineBarsData: [
                LineChartBarData(
                  spots: points
                      .map((p) => FlSpot(p.index.toDouble(), p.value))
                      .toList(),
                  isCurved: false,
                  color: DSColors.info,
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
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              extraLinesData: points.length > 1
                  ? ExtraLinesData(
                      verticalLines: List.generate(
                        points.length - 1,
                        (i) => VerticalLine(
                          x: i + 0.5,
                          color: DSColors.gray300,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                    )
                  : const ExtraLinesData(),
              lineTouchData: const LineTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        _ChartLegend(),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(
          indicator: Container(
            width: 20,
            height: 2,
            color: DSColors.info,
          ),
          label: 'Avg HR',
        ),
        const SizedBox(width: DSSpacing.lg),
        _LegendItem(
          indicator: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DSColors.error,
            ),
          ),
          label: 'Spike',
        ),
        const SizedBox(width: DSSpacing.lg),
        _LegendItem(
          indicator: _DottedLine(),
          label: 'Series boundary',
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
      canvas.drawLine(Offset(x, size.height / 2),
          Offset((x + 3).clamp(0, size.width), size.height / 2), paint);
      x += 6;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter _) => false;
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderMd,
      ),
      child: Center(
        child: Text(
          'No data',
          style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
        ),
      ),
    );
  }
}
