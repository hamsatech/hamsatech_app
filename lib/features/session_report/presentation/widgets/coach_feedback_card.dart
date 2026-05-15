import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_report_entity.dart';

class CoachFeedbackCard extends StatelessWidget {
  const CoachFeedbackCard({super.key, required this.feedback});

  final CoachFeedbackEntity feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: DSColors.info,
                  child: Text(
                    feedback.avatarInitial,
                    style: DSTypography.headingMd
                        .copyWith(color: DSColors.white),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.coachName,
                        style: DSTypography.headingSmall
                            .copyWith(color: DSColors.black),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        feedback.timestampLabel,
                        style: DSTypography.labelXs
                            .copyWith(color: DSColors.textMuted),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        feedback.message,
                        style: DSTypography.bodySm
                            .copyWith(color: DSColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DSColors.gray200),
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: DSButton(
              label: feedback.planLabel,
              variant: DSButtonVariant.outline,
              size: DSButtonSize.lg,
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
