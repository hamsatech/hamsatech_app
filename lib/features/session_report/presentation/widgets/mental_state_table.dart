import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_report_entity.dart';

class MentalStateTable extends StatelessWidget {
  const MentalStateTable({super.key, required this.comparison});

  final MentalStateComparisonEntity comparison;

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
          // ── Column headers ─────────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _ColumnHeader(title: 'Before')),
                const VerticalDivider(
                    width: 1, thickness: 1, color: DSColors.gray200),
                Expanded(child: _ColumnHeader(title: 'After')),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DSColors.gray200),
          // ── Data rows ──────────────────────────────────────────────────────
          for (int i = 0; i < comparison.rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: DSColors.gray200),
            _DataRow(row: comparison.rows[i]),
          ],
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
      child: Text(
        title,
        style: DSTypography.labelSm.copyWith(color: DSColors.textSecondary),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.row});

  final MentalStateRowEntity row;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _CellTile(cell: row.before)),
          const VerticalDivider(
              width: 1, thickness: 1, color: DSColors.gray200),
          Expanded(child: _CellTile(cell: row.after)),
        ],
      ),
    );
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({required this.cell});

  final MentalStateCellEntity cell;

  @override
  Widget build(BuildContext context) {
    final valueColor = switch (cell.color) {
      MetricColor.good => DSColors.success,
      MetricColor.warning => DSColors.warning,
      MetricColor.bad => DSColors.error,
      MetricColor.neutral => DSColors.gray500,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cell.label,
            style: DSTypography.labelSm.copyWith(color: DSColors.textSecondary),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            cell.value,
            style: DSTypography.bodyMd.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
