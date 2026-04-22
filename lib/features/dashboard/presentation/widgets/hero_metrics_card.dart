import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../domain/entities/dashboard_data_entity.dart';

class HeroMetricsCard extends StatelessWidget {
  const HeroMetricsCard({
    super.key,
    required this.athleteName,
    required this.metrics,
  });

  final String athleteName;
  final ReadinessMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final level = metrics.readinessLevel;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            level.color.withValues(alpha: 0.15),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: level.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()}, $athleteName',
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: level.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: level.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            level.label,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: level.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ScoreRing(
                score: metrics.readinessScore,
                size: 88,
                label: 'Readiness',
                strokeWidth: 7,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricPill(
                label: 'Focus',
                value: metrics.focusLevel.label,
                color: metrics.focusLevel.color,
                icon: Icons.center_focus_strong_rounded,
              ),
              const SizedBox(width: 8),
              _MetricPill(
                label: 'Stress',
                value: _stressLabel(metrics.stressLevel),
                color: _stressColor(metrics.stressLevel),
                icon: Icons.monitor_heart_outlined,
              ),
              const SizedBox(width: 8),
              _MetricPill(
                label: 'Energy',
                value: _energyLabel(metrics.energyLevel),
                color: _energyColor(metrics.energyLevel),
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  String _stressLabel(double v) {
    if (v < 35) return 'Low';
    if (v < 65) return 'Moderate';
    return 'High';
  }

  Color _stressColor(double v) {
    if (v < 35) return AppColors.secondary;
    if (v < 65) return AppColors.warning;
    return AppColors.error;
  }

  String _energyLabel(double v) {
    if (v >= 70) return 'High';
    if (v >= 40) return 'Moderate';
    return 'Low';
  }

  Color _energyColor(double v) {
    if (v >= 70) return AppColors.secondary;
    if (v >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style:
                    AppTextStyles.labelMedium.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
