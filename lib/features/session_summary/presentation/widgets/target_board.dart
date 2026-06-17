import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_summary_entity.dart';

class TargetBoardCard extends StatelessWidget {
  const TargetBoardCard({
    super.key,
    required this.seriesBreakdown,
    required this.selectedSeriesIndex,
    required this.onSeriesChanged,
  });

  final List<SeriesBreakdownEntity> seriesBreakdown;
  final int selectedSeriesIndex;
  final ValueChanged<int> onSeriesChanged;

  @override
  Widget build(BuildContext context) {
    if (seriesBreakdown.isEmpty) return const SizedBox.shrink();

    final clampedIndex =
        selectedSeriesIndex.clamp(0, seriesBreakdown.length - 1);
    final selectedSeries = seriesBreakdown[clampedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SeriesDropdown(
          seriesBreakdown: seriesBreakdown,
          selectedIndex: clampedIndex,
          onChanged: onSeriesChanged,
        ),
        const SizedBox(height: DSSpacing.lg),
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: _TargetPainter(
                seriesNumber: selectedSeries.seriesNumber,
                totalShots: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Center(
          child: Text(
            'Simulated from scores · not positional data',
            style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Series Dropdown ───────────────────────────────────────────────────────────

class _SeriesDropdown extends StatelessWidget {
  const _SeriesDropdown({
    required this.seriesBreakdown,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<SeriesBreakdownEntity> seriesBreakdown;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.gray200, width: 1),
        borderRadius: DSRadius.borderMd,
      ),
      child: Row(
        children: [
          Text(
            'No. of Series',
            style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedIndex,
              isDense: true,
              style: DSTypography.labelMd.copyWith(color: DSColors.black),
              icon: const Icon(Icons.expand_more,
                  size: 18, color: DSColors.textSecondary),
              items: List.generate(seriesBreakdown.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    'Series - ${i + 1}',
                    style: DSTypography.labelMd.copyWith(color: DSColors.black),
                  ),
                );
              }),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Archery Target Painter ────────────────────────────────────────────────────

class _TargetPainter extends CustomPainter {
  _TargetPainter({required this.seriesNumber, required this.totalShots});

  final int seriesNumber;
  final int totalShots;

  static const _ringColors = [
    Color(0xFFFFFFFF), // ring 1
    Color(0xFFFFFFFF), // ring 2
    Color(0xFF000000), // ring 3
    Color(0xFF000000), // ring 4
    Color(0xFF2F7E8F), // ring 5 (blue)
    Color(0xFF2F7E8F), // ring 6
    Color(0xFF2F7E8F), // ring 7 (red)
    Color(0xFF2F7E8F), // ring 8
    Color(0xFFFFD700), // ring 9 (yellow)
    Color(0xFFFFD700), // ring 10
  ];

  static const _ringBorderColors = [
    Color(0xFFCCCCCC), // ring 1-2 border (visible on white)
    Color(0xFFCCCCCC),
    Color(0xFF000F12),
    Color(0xFF000F12),
    Color(0xFF2F7E8F),
    Color(0xFF2F7E8F),
    Color(0xFF1D6070),
    Color(0xFF1D6070),
    Color(0xFFE6C200),
    Color(0xFFE6C200),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.92;

    // Draw rings from outermost to innermost
    for (int ring = 10; ring >= 1; ring--) {
      final radius = maxRadius * ring / 10;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = _ringColors[ring - 1]
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = _ringBorderColors[ring - 1].withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // Ring number labels (top of each ring)
    for (int ring = 1; ring <= 10; ring++) {
      final ringRadius = maxRadius * ring / 10;
      final prevRadius = ring > 1 ? maxRadius * (ring - 1) / 10 : 0.0;
      final textColor = ring <= 2
          ? const Color(0xFF3A7080)
          : ring <= 4
              ? const Color(0xFFAAAAAA)
              : DSColors.white;

      final tp = TextPainter(
        text: TextSpan(
          text: ring.toString(),
          style: TextStyle(
            fontSize: maxRadius * 0.075,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Draw at top, right, bottom, left of each ring band
      for (final angle in [0.0, pi / 2, pi, 3 * pi / 2]) {
        final bandRadius = (ringRadius + prevRadius) / 2;
        final x = center.dx + bandRadius * sin(angle) - tp.width / 2;
        final y = center.dy - bandRadius * cos(angle) - tp.height / 2;
        tp.paint(canvas, Offset(x, y));
      }
    }

    // Simulate shot dots based on series seed
    final rng = Random(seriesNumber * 42);
    for (int i = 0; i < totalShots; i++) {
      // Most shots in 8-10 zone for a skilled archer
      final scoreBase = 7.0 + rng.nextDouble() * 3.0; // 7.0–10.0
      final ringFraction = _scoreToRadius(scoreBase);
      final jitter = (rng.nextDouble() - 0.5) * maxRadius * 0.06;
      final radius = (maxRadius * ringFraction + jitter).clamp(0.0, maxRadius);
      final angle = rng.nextDouble() * 2 * pi;

      final pos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // White fill + black border
      canvas.drawCircle(pos, 4.5, Paint()..color = DSColors.white);
      canvas.drawCircle(
        pos,
        4.5,
        Paint()
          ..color = DSColors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Center X-ring dot
    canvas.drawCircle(
      center,
      maxRadius * 0.035,
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(
      center,
      maxRadius * 0.035,
      Paint()
        ..color = const Color(0xFFE6C200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  double _scoreToRadius(double score) {
    if (score >= 10.5) return 0.02;
    if (score >= 10.0) return 0.07;
    if (score >= 9.0) return 0.17;
    if (score >= 8.0) return 0.27;
    if (score >= 7.0) return 0.37;
    if (score >= 6.0) return 0.47;
    if (score >= 5.0) return 0.60;
    if (score >= 4.0) return 0.72;
    return 0.84;
  }

  @override
  bool shouldRepaint(_TargetPainter old) =>
      old.seriesNumber != seriesNumber || old.totalShots != totalShots;
}
