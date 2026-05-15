import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_series_entity.dart';

class ShotTracker extends StatelessWidget {
  const ShotTracker({
    super.key,
    required this.shots,
    required this.shotsPerSeries,
  });

  final List<ScoreValue> shots;
  final int shotsPerSeries;

  @override
  Widget build(BuildContext context) {
    final rows = (shotsPerSeries / 5).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'So far this series:',
          style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
        ),
        const SizedBox(height: DSSpacing.sm),
        ...List.generate(rows, (row) {
          final start = row * 5;
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Row(
              children: List.generate(5, (col) {
                final index = start + col;
                if (index >= shotsPerSeries) {
                  return const Expanded(child: SizedBox());
                }
                final filled = index < shots.length;
                return Expanded(
                  child: Center(
                    child: Text(
                      filled ? shots[index].display : '—',
                      style: DSTypography.headingSm.copyWith(
                        color: filled ? DSColors.black : DSColors.gray300,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}
