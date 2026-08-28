import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/dashboard_data_entity.dart';

class PerformanceChartCard extends StatelessWidget {
  const PerformanceChartCard({super.key, required this.history});

  final List<PerformanceDataPoint> history;

  @override
  Widget build(BuildContext context) {
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
              Text('Last 5 sessions', style: DSTypography.caption),
            ],
          ),
          const SizedBox(height: 20),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Complete sessions to see your trend',
                  style: DSTypography.bodySmall,
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(_buildChartData()),
            ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: DSColors.brand, label: 'Session Quality'),
                const SizedBox(width: 20),
                _Legend(color: DSColors.info, label: 'Focus'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    final qualitySpots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.overallRating))
        .toList();
    final focusSpots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.focusScore))
        .toList();

    return LineChartData(
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
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
            reservedSize: 32,
            interval: 25,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: DSTypography.caption,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Text(
              'S${v.toInt() + 1}',
              style: DSTypography.caption,
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        _lineBar(qualitySpots, DSColors.brand),
        _lineBar(focusSpots, DSColors.info),
      ],
    );
  }

  LineChartBarData _lineBar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: DSTypography.caption),
      ],
    );
  }
}
