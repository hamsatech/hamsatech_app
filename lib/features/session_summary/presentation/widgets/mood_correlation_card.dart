import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_summary_entity.dart';

class MoodCorrelationCard extends StatelessWidget {
  const MoodCorrelationCard({super.key, required this.mood});

  final MoodCorrelationEntity mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200, width: 1),
        borderRadius: DSRadius.borderMd,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mood.moodEmoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.moodLabel,
                        style: DSTypography.headingSmall
                            .copyWith(color: DSColors.black),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        'Session avg: ${mood.formattedAvg}',
                        style: DSTypography.bodySm
                            .copyWith(color: DSColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _StateBadge(label: mood.moodState),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DSColors.gray200),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md, vertical: DSSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.sync_rounded,
                    size: 18, color: DSColors.success),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  'Auto-synced to coach',
                  style: DSTypography.labelMd.copyWith(color: DSColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm, vertical: DSSpacing.xxs),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.12),
        borderRadius: DSRadius.borderFull,
      ),
      child: Text(
        label,
        style: DSTypography.labelXs.copyWith(color: DSColors.success),
      ),
    );
  }
}
