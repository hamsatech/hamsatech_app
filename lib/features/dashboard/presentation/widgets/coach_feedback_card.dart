import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/dashboard_data_entity.dart';

class CoachFeedbackCard extends StatelessWidget {
  const CoachFeedbackCard({
    required this.feedback,
    required this.onViewFull,
    required this.onMarkRead,
    super.key,
  });

  final CoachFeedbackData feedback;
  final VoidCallback onViewFull;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: feedback.isRead ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: DSColors.appCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DSColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              coachName: feedback.coachName,
              timestamp: _formatTimeAgo(feedback.timestamp),
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              feedback.message,
              style: DSTypography.bodyMedium.copyWith(
                color: DSColors.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            _MetaRow(label: 'About', value: feedback.about),
            const SizedBox(height: 6),
            _MetaRow(label: 'Assigned', value: feedback.assigned),
            const SizedBox(height: DSSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _ViewFullButton(onTap: onViewFull),
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: _MarkReadButton(
                    onTap: onMarkRead,
                    isRead: feedback.isRead,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coachName, required this.timestamp});

  final String coachName;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            coachName,
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          timestamp,
          style: DSTypography.caption.copyWith(
            color: DSColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          TextSpan(
            text: value,
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewFullButton extends StatelessWidget {
  const _ViewFullButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2F7E8F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'View Full',
          style: DSTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MarkReadButton extends StatelessWidget {
  const _MarkReadButton({required this.onTap, required this.isRead});

  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRead ? null : onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: DSColors.appBorder,
            width: 1,
          ),
        ),
        child: Text(
          isRead ? 'Read' : 'Mark Read',
          style: DSTypography.labelMedium.copyWith(
            color: isRead ? DSColors.textMuted : DSColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
