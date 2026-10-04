import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/dashboard_data_entity.dart';

/// Plots real `avg_score` per completed session
/// (`GET /api/mobile/athletes/{id}/sessions`) — a single line of genuinely
/// scored sessions only. A session with no saved score summary contributes
/// no point (never plotted as 0), so the line simply skips it rather than
/// implying a real-but-zero score.
class PerformanceChartCard extends StatelessWidget {
  const PerformanceChartCard({super.key, required this.history});

  final List<PerformanceDataPoint> history;

  List<PerformanceDataPoint> get _scored =>
      history.where((p) => p.avgScore != null).toList();

  @override
  Widget build(BuildContext context) {
    final scored = _scored;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.show_chart_rounded,
                    color: DSColors.brand, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Performance Trend', style: DSTypography.headingSmall),
              const Spacer(),
              Text('Recent sessions', style: DSTypography.caption),
            ],
          ),
          const SizedBox(height: 20),
          if (scored.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  history.isEmpty
                      ? 'Complete sessions to see your trend'
                      : 'No scored sessions yet — save a score after your '
                          'next session to start your trend',
                  textAlign: TextAlign.center,
                  style: DSTypography.bodySmall,
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(_buildChartData(scored)),
            ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(List<PerformanceDataPoint> scored) {
    final spots = scored
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.avgScore!))
        .toList();
    final maxScore = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    // Real scores aren't bounded to 0-100 like the previous fabricated
    // 0-100 ratings were — scale the axis to the data instead of assuming
    // a fixed range.
    final axisMax = (maxScore * 1.2).ceilToDouble().clamp(10.0, double.infinity);

    return LineChartData(
      minY: 0,
      maxY: axisMax,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: DSColors.appDivider,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: DSTypography.caption,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= scored.length) return const SizedBox.shrink();
              return Text('S${scored[i].sessionNumber}',
                  style: DSTypography.caption);
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: DSColors.brand,
          barWidth: 2.5,
          dotData: FlDotData(
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: DSColors.brand,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: DSColors.brand.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}
