import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

/// A horizontal row of labeled (and optionally icon-prefixed) pill tabs.
/// Exactly one item is selected at a time.
class DSSegmentedControl<T> extends StatelessWidget {
  const DSSegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.size = DSSegmentedSize.md,
  });

  final List<DSSegmentedItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final DSSegmentedSize size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? DSColors.gray800 : DSColors.gray100;
    final selectedBg = isDark ? DSColors.gray700 : DSColors.white;
    final selectedFg = isDark ? DSColors.gray100 : DSColors.gray900;
    final unselectedFg = isDark ? DSColors.gray400 : DSColors.gray500;

    final textStyle = switch (size) {
      DSSegmentedSize.sm => DSTypography.labelSm,
      DSSegmentedSize.md => DSTypography.labelMd,
      DSSegmentedSize.lg => DSTypography.labelLg,
    };
    final iconSize = switch (size) {
      DSSegmentedSize.sm => 12.0,
      DSSegmentedSize.md => 14.0,
      DSSegmentedSize.lg => 16.0,
    };
    final vPad = switch (size) {
      DSSegmentedSize.sm => 4.0,
      DSSegmentedSize.md => 6.0,
      DSSegmentedSize.lg => 8.0,
    };

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: DSRadius.borderMd,
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final isSelected = item.value == selected;
            final fg = isSelected ? selectedFg : unselectedFg;

            return GestureDetector(
              onTap: () => onChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: vPad),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : Colors.transparent,
                  borderRadius: DSRadius.borderSm,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: DSColors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(size: iconSize, color: fg),
                        child: item.icon!,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                    ],
                    Text(item.label, style: textStyle.copyWith(color: fg)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DSSegmentedItem<T> {
  const DSSegmentedItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final Widget? icon;
}

enum DSSegmentedSize { sm, md, lg }
