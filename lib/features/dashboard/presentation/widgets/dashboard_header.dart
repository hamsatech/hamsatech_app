import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.greeting,
    required this.athleteName,
    required this.isPolarConnected,
    this.streakDays,
    this.onNotificationTap,
    super.key,
  });

  final String greeting;
  final String athleteName;
  final bool isPolarConnected;
  final int? streakDays;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: DSTypography.headingLarge.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    athleteName,
                    style: DSTypography.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            if (streakDays != null && streakDays! > 0)
              _StreakBadge(days: streakDays!)
            else
              _NotificationButton(onTap: onNotificationTap),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        if (isPolarConnected) const _PolarConnectedBadge(),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DSColors.gray100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: DSColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DSColors.brand.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DSColors.brand.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: DSSpacing.xs),
          Text(
            '$days day streak',
            style: DSTypography.labelMedium.copyWith(
              color: DSColors.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolarConnectedBadge extends StatelessWidget {
  const _PolarConnectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DSColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: DSColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            'Polar connected',
            style: DSTypography.caption.copyWith(
              color: DSColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
