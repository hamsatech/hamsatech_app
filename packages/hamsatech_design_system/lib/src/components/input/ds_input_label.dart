import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

class DSInputLabel extends StatelessWidget {
  const DSInputLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
  });

  final String label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? DSColors.gray300 : DSColors.gray700;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isRequired) ...[
          const SizedBox(width: DSSpacing.xxs),
          Text(
            '*',
            style: DSTypography.labelMd.copyWith(color: DSColors.error),
          ),
        ],
        if (showInfoIcon) ...[
          const SizedBox(width: DSSpacing.xs),
          Tooltip(
            message: infoTooltip ?? '',
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: isDark ? DSColors.gray500 : DSColors.gray400,
            ),
          ),
        ],
      ],
    );
  }
}
