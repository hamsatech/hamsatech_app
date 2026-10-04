import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/session_report_entity.dart';

class ReportSeriesBreakdownRow extends StatelessWidget {
  const ReportSeriesBreakdownRow({super.key, required this.series});

  final ReportSeriesRowEntity series;

  @override
  Widget build(BuildContext context) {
    final showHeartRate = StorageService.isPolarEnabled();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              'S${series.seriesNumber}',
              style:
                  DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: DSRadius.borderFull,
              child: LinearProgressIndicator(
                value: series.fraction,
                minHeight: 8,
                backgroundColor: DSColors.gray100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  series.isBest ? DSColors.success : DSColors.info,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          SizedBox(
            width: 36,
            child: Text(
              series.formattedTotal,
              textAlign: TextAlign.right,
              style: DSTypography.bodyMd.copyWith(color: DSColors.black),
            ),
          ),
          if (showHeartRate) ...[
            const SizedBox(width: DSSpacing.sm),
            SizedBox(
              width: 52,
              child: Text(
                '${series.avgHr} bpm',
                style: DSTypography.labelXs
                    .copyWith(color: DSColors.textSecondary),
              ),
            ),
          ],
          if (series.isBest)
            const Icon(Icons.check_circle_rounded,
                size: 16, color: DSColors.success)
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}
