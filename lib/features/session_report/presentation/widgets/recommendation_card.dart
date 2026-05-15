import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_report_entity.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.items,
    required this.onBreathingTap,
  });

  final List<RecommendationItemEntity> items;
  final VoidCallback onBreathingTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200),
        borderRadius: DSRadius.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) ...[
            _CheckItem(item: item),
            const SizedBox(height: DSSpacing.sm),
          ],
          const SizedBox(height: DSSpacing.xs),
          DSPrimaryButton(
            label: 'Start Breathing Now',
            color: _teal,
            onPressed: onBreathingTap,
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.item});

  final RecommendationItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.isChecked
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: item.isChecked ? DSColors.success : DSColors.gray300,
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Text(
            item.text,
            style: DSTypography.bodySm.copyWith(
              color: item.isChecked ? DSColors.gray400 : DSColors.black,
              decoration:
                  item.isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}
