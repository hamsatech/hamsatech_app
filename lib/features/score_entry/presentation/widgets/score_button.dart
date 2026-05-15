import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

import '../../domain/entities/session_series_entity.dart';

class ScoreButton extends StatelessWidget {
  const ScoreButton({
    super.key,
    required this.value,
    required this.onTap,
  });

  final ScoreValue value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final Color borderColor;

    if (value.isMiss) {
      bg = DSColors.error;
      textColor = DSColors.white;
      borderColor = Colors.transparent;
    } else if (value.isSubFive) {
      bg = DSColors.error.withValues(alpha: 0.07);
      textColor = DSColors.error;
      borderColor = DSColors.error.withValues(alpha: 0.25);
    } else {
      bg = DSColors.white;
      textColor = DSColors.black;
      borderColor = DSColors.gray200;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: DSRadius.borderMd,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            value.display,
            style: DSTypography.headingMd.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
