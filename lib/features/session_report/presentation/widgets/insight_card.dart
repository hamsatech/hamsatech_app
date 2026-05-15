import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_report_entity.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final InsightEntity insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.warning.withValues(alpha: 0.07),
        border: Border.all(
            color: DSColors.warning.withValues(alpha: 0.25), width: 1),
        borderRadius: DSRadius.borderMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.18),
              borderRadius: DSRadius.borderMd,
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.headline,
                  style: DSTypography.headingSmall
                      .copyWith(color: DSColors.black),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  insight.body,
                  style:
                      DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
