import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_typography.dart';

class DSPrimaryButton extends StatelessWidget {
  const DSPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color = DSColors.brand,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: DSColors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: DSColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: textStyle ??
                    DSTypography.labelLg.copyWith(
                      color: DSColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
              ),
      ),
    );
  }
}
