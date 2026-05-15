import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/dashboard_data_entity.dart';

class WeeklyStatsCard extends StatelessWidget {
  const WeeklyStatsCard({required this.stats, super.key});

  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DSColors.gray200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: stats.averageScore > 0
                    ? stats.averageScore.round().toString()
                    : '—',
                label: 'Average score',
              ),
            ),
            VerticalDivider(
              color: DSColors.appBorder.withValues(alpha: 0.5),
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: _StatCell(
                value: stats.sessionCount.toString(),
                label: 'Sessions',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: DSSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: DSTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
