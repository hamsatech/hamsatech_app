import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class ReportSectionHeader extends StatelessWidget {
  const ReportSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DSTypography.headingMd.copyWith(color: DSColors.black),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: DSSpacing.xxs),
            Text(
              subtitle!,
              style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
