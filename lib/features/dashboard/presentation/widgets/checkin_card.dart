import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class CheckinCard extends StatelessWidget {
  const CheckinCard({
    required this.onTap,
    this.isCompleted = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: DSColors.appCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DSColors.gray200),
        ),
        child: Row(
          children: [
            _CheckinIcon(isCompleted: isCompleted),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Check in',
                    style: DSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted ? 'Check-in complete' : 'How are you feeling?',
                    style: DSTypography.bodySmall.copyWith(
                      color: DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isCompleted ? DSColors.success : DSColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckinIcon extends StatelessWidget {
  const _CheckinIcon({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isCompleted
            ? DSColors.success.withValues(alpha: 0.15)
            : DSColors.brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check_circle_rounded,
              color: DSColors.success,
              size: 24,
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.track_changes_rounded,
                  color: DSColors.brand,
                  size: 24,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: DSColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
