import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.primaryValue,
    required this.label,
    this.primaryColor,
    this.valueSuffix,
  });

  final String primaryValue;
  final String label;
  final Color? primaryColor;
  final String? valueSuffix;

  @override
  Widget build(BuildContext context) {
    final valueColor = primaryColor ?? DSColors.black;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: DSRadius.borderMd,
        border: Border.all(color: DSColors.gray200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                primaryValue,
                style: DSTypography.headingXl.copyWith(color: valueColor),
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: DSSpacing.xs),
                Text(
                  valueSuffix!,
                  style: DSTypography.bodySm
                      .copyWith(color: DSColors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            label,
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
