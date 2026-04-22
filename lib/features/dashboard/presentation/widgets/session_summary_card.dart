import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/dashboard_data_entity.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({super.key, required this.session});

  final SessionSummaryData? session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.secondary, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Last Session', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          if (session == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No sessions yet.\nStart your first training session!',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            Row(
              children: [
                _SummaryItem(
                  label: 'Date',
                  value: DateFormat('dd MMM').format(session!.date),
                  icon: Icons.calendar_today_outlined,
                ),
                _SummaryItem(
                  label: 'Duration',
                  value: '${session!.durationMinutes}m',
                  icon: Icons.timer_outlined,
                ),
                _SummaryItem(
                  label: 'Rating',
                  value: '${'★' * session!.postSessionRating}${'☆' * (5 - session!.postSessionRating)}',
                  icon: Icons.star_border_rounded,
                  valueColor: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            Text('Pre-session state',
                style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            _PreSessionBar(
                label: 'Energy',
                value: session!.preSessionEnergy),
            _PreSessionBar(
                label: 'Focus', value: session!.preSessionFocus),
            _PreSessionBar(
                label: 'Stress', value: session!.preSessionStress,
                isInverse: true),
          ],
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _PreSessionBar extends StatelessWidget {
  const _PreSessionBar({
    required this.label,
    required this.value,
    this.isInverse = false,
  });

  final String label;
  final int value; // 1–10
  final bool isInverse;

  Color get _color {
    final normalised = isInverse ? (11 - value) : value;
    if (normalised >= 7) return AppColors.secondary;
    if (normalised >= 4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 10,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value/10',
              style: AppTextStyles.caption.copyWith(color: _color)),
        ],
      ),
    );
  }
}
