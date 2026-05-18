import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_report_entity.dart';

class MetricTableCard extends StatelessWidget {
  const MetricTableCard({super.key, required this.rows});

  final List<MetricTableRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderMd,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: DSColors.gray200),
            _RowTile(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final MetricTableRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            row.label,
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
          Row(
            children: [
              if (row.indicatorColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: row.indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(
                row.value,
                style: DSTypography.bodyMd.copyWith(color: DSColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricTableRow {
  const MetricTableRow({
    required this.label,
    required this.value,
    this.indicatorColor,
  });

  final String label;
  final String value;
  final Color? indicatorColor;
}

// ── Factory helpers ───────────────────────────────────────────────────────────

Color _metricColor(MetricColor c) => switch (c) {
      MetricColor.good => DSColors.success,
      MetricColor.warning => DSColors.warning,
      MetricColor.bad => DSColors.error,
      MetricColor.neutral => DSColors.gray400,
    };

MetricTableCard buildPhysiologyCard({
  required PhysiologyMetricsEntity physiology,
  bool showHrRows = true,
}) {
  return MetricTableCard(rows: [
    if (showHrRows) ...[
      MetricTableRow(
          label: 'Avg Heart Rate', value: '${physiology.avgHr} bpm'),
      MetricTableRow(
          label: 'Peak Heart Rate', value: '${physiology.peakHr} bpm'),
    ],
    MetricTableRow(
      label: 'Fatigue',
      value: physiology.fatigueLabel,
      indicatorColor: _metricColor(physiology.fatigueColor),
    ),
    MetricTableRow(
      label: 'Recovery',
      value: physiology.recoveryLabel,
      indicatorColor: _metricColor(physiology.recoveryColor),
    ),
  ]);
}

MetricTableCard buildHrStatsCard({required HrMetricsEntity hr}) {
  return MetricTableCard(rows: [
    MetricTableRow(label: 'Average HR', value: '${hr.avgHr} bpm'),
    MetricTableRow(label: 'Peak HR', value: '${hr.peakHr} bpm'),
    MetricTableRow(label: 'Min HR', value: '${hr.minHr} bpm'),
    MetricTableRow(
      label: 'HR Zone',
      value: hr.hrZoneLabel,
      indicatorColor: _metricColor(hr.hrZoneColor),
    ),
  ]);
}
