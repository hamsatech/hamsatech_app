import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_typography.dart';

class DSSecondaryTextButton extends StatelessWidget {
  const DSSecondaryTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = DSColors.brand,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        overlayColor: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: textStyle ??
            DSTypography.labelLg.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
      ),
    );
  }
}
