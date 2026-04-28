import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

enum DSCheckboxSize { sm, md, lg }

/// A styled checkbox that supports checked, unchecked, indeterminate, and
/// disabled states, with an optional label, description, and badge.
///
/// [value] == null → indeterminate (dash icon).
class DSCheckbox extends StatelessWidget {
  const DSCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = DSCheckboxSize.md,
    this.label,
    this.description,
    this.badge,
    this.isDisabled = false,
  });

  /// true = checked, false = unchecked, null = indeterminate
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final DSCheckboxSize size;
  final String? label;
  final String? description;
  final String? badge;
  final bool isDisabled;

  double get _boxSize => switch (size) {
        DSCheckboxSize.sm => 16,
        DSCheckboxSize.md => 18,
        DSCheckboxSize.lg => 20,
      };

  double get _iconSize => switch (size) {
        DSCheckboxSize.sm => 10,
        DSCheckboxSize.md => 12,
        DSCheckboxSize.lg => 13,
      };

  TextStyle get _labelStyle => switch (size) {
        DSCheckboxSize.sm => DSTypography.labelSm,
        DSCheckboxSize.md => DSTypography.labelMd,
        DSCheckboxSize.lg => DSTypography.labelLg,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecked = value == true;
    final isIndeterminate = value == null;
    final active = isChecked || isIndeterminate;

    final Color boxBg;
    final Color borderColor;
    final Color? iconColor;

    if (isDisabled) {
      boxBg = active
          ? DSColors.brand.withValues(alpha: 0.35)
          : Colors.transparent;
      borderColor = isDark ? DSColors.gray700 : DSColors.gray300;
      iconColor = DSColors.white.withValues(alpha: 0.6);
    } else if (active) {
      boxBg = DSColors.brand;
      borderColor = DSColors.brand;
      iconColor = DSColors.white;
    } else {
      boxBg = Colors.transparent;
      borderColor = isDark ? DSColors.gray600 : DSColors.gray300;
      iconColor = null;
    }

    final box = GestureDetector(
      onTap: isDisabled
          ? null
          : () => onChanged?.call(value != true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _boxSize,
        height: _boxSize,
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: DSRadius.borderXs,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: active
            ? Center(
                child: Icon(
                  isIndeterminate
                      ? Icons.remove_rounded
                      : Icons.check_rounded,
                  size: _iconSize,
                  color: iconColor,
                ),
              )
            : null,
      ),
    );

    if (label == null && description == null) return box;

    final textColor = isDisabled
        ? (isDark ? DSColors.gray600 : DSColors.gray400)
        : (isDark ? DSColors.textPrimary : DSColors.gray900);
    final descColor = isDisabled
        ? (isDark ? DSColors.gray700 : DSColors.gray300)
        : DSColors.textSecondary;

    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(value != true),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: box,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Row(
                    children: [
                      Text(
                        label!,
                        style: _labelStyle.copyWith(color: textColor),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: DSSpacing.xs),
                        _Badge(label: badge!),
                      ],
                    ],
                  ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: DSTypography.bodySmall.copyWith(color: descColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.15),
        borderRadius: DSRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: DSColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: DSTypography.caption.copyWith(
              color: DSColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
