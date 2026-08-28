import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dashboard_data_entity.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({super.key, required this.session});

  final SessionSummaryData? session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_rounded,
                    color: DSColors.success, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Last Session', style: DSTypography.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          if (session == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No sessions yet.\nStart your first training session!',
                  style: DSTypography.bodySmall,
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
                  value:
                      '${'★' * session!.postSessionRating}${'☆' * (5 - session!.postSessionRating)}',
                  icon: Icons.star_border_rounded,
                  valueColor: DSColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: DSColors.appDivider),
            const SizedBox(height: 12),
            Text('Pre-session state', style: DSTypography.labelMedium),
            const SizedBox(height: 8),
            _PreSessionBar(label: 'Energy', value: session!.preSessionEnergy),
            _PreSessionBar(label: 'Focus', value: session!.preSessionFocus),
            _PreSessionBar(
                label: 'Stress',
                value: session!.preSessionStress,
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
          Icon(icon, color: DSColors.textMuted, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: DSTypography.labelLarge.copyWith(
              color: valueColor ?? DSColors.textPrimary,
            ),
          ),
          Text(label, style: DSTypography.caption),
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
    if (normalised >= 7) return DSColors.success;
    if (normalised >= 4) return DSColors.warning;
    return DSColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: DSTypography.caption),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 10,
                minHeight: 6,
                backgroundColor: DSColors.appBorder,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value/10',
              style: DSTypography.caption.copyWith(color: _color)),
        ],
      ),
    );
  }
}
