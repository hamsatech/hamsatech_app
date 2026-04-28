import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_typography.dart';

class DSScoreRing extends StatelessWidget {
  const DSScoreRing({
    super.key,
    required this.score,
    required this.size,
    this.label,
    this.strokeWidth = 6,
    this.color,
  });

  /// 0–100
  final double score;
  final double size;
  final String? label;
  final double strokeWidth;
  final Color? color;

  Color get _ringColor {
    if (color != null) return color!;
    if (score >= 70) return DSColors.success;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: score / 100,
              color: _ringColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toInt().toString(),
                style: DSTypography.metricValue.copyWith(fontSize: size * 0.28),
              ),
              if (label != null)
                Text(
                  label!,
                  style: DSTypography.caption.copyWith(fontSize: size * 0.10),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = DSColors.appBorder
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
