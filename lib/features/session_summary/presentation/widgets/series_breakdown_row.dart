import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_summary_entity.dart';

class SeriesBreakdownRow extends StatelessWidget {
  const SeriesBreakdownRow({super.key, required this.series});

  final SeriesBreakdownEntity series;

  @override
  Widget build(BuildContext context) {
    final barColor = series.isBest ? DSColors.success : DSColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              'S${series.seriesNumber}',
              style: DSTypography.labelMd.copyWith(color: DSColors.textSecondary),
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: DSRadius.borderFull,
              child: LinearProgressIndicator(
                value: series.fraction,
                minHeight: 8,
                backgroundColor: DSColors.gray100,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          SizedBox(
            width: 36,
            child: Text(
              series.formattedTotal,
              textAlign: TextAlign.right,
              style: DSTypography.headingSm.copyWith(color: DSColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
