import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.title,
    required this.value,
    this.unit,
    required this.statusLabel,
    required this.statusColor,
    required this.valueColor,
    required this.progressValue,
    required this.progressColor,
    this.segmentCount = 10,
    super.key,
  });

  final String title;
  final String value;
  final String? unit; // e.g. "bpm", "ms" — null if unit is embedded in value
  final String statusLabel;
  final Color statusColor;
  final Color valueColor;
  final double progressValue; // 0.0–1.0
  final Color progressColor;
  final int segmentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: 20),
      decoration: BoxDecoration(
        color: DSColors.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DSColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          _ValueRow(value: value, unit: unit, valueColor: valueColor),
          const SizedBox(height: 12),
          _ProgressSegments(
            value: progressValue,
            color: progressColor,
            total: segmentCount,
          ),
          const SizedBox(height: 8),
          Text(
            statusLabel,
            style: DSTypography.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.value,
    required this.valueColor,
    this.unit,
  });

  final String value;
  final Color valueColor;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    if (unit == null) {
      return Text(
        value,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: valueColor,
          height: 1.1,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({
    required this.value,
    required this.color,
    this.total = 10,
  });

  final double value;
  final Color color;
  final int total;

  @override
  Widget build(BuildContext context) {
    final filled = (value * total).round().clamp(0, total);
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 3);
        final index = i ~/ 2;
        return Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: index < filled
                  ? color
                  : DSColors.appBorder.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Skeleton placeholder shown while loading
class MetricCardSkeleton extends StatefulWidget {
  const MetricCardSkeleton({super.key});

  @override
  State<MetricCardSkeleton> createState() => _MetricCardSkeletonState();
}

class _MetricCardSkeletonState extends State<MetricCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg, vertical: 20),
          decoration: BoxDecoration(
            color: DSColors.gray50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DSColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(width: 60, height: 12),
              const SizedBox(height: 6),
              _ShimmerBox(width: 80, height: 28),
              const SizedBox(height: 12),
              _ShimmerBox(width: double.infinity, height: 4),
              const SizedBox(height: 8),
              _ShimmerBox(width: 50, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DSColors.appBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
