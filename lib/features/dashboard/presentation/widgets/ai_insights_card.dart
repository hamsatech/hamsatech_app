import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';



class AiInsightsCard extends StatelessWidget {
  const AiInsightsCard({super.key, required this.insights});

  final List<String> insights;

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
                  color: DSColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: DSColors.info, size: 18),
              ),
              const SizedBox(width: 10),
              Text('AI Insights', style: DSTypography.headingSmall),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.asMap().entries.map((e) => _InsightItem(
                index: e.key,
                text: e.value,
              )),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.index, required this.text});

  final int index;
  final String text;

  static const _colors = [
    DSColors.info,
    DSColors.success,
    DSColors.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: DSTypography.bodySmall.copyWith(
                color: DSColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
