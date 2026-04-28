import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_button.dart';

/// A joined horizontal strip of labeled buttons (e.g. Create | Add | Label)
/// with an optional trailing "+" action button.
///
/// Each [DSButtonGroupItem] renders as a segment. The selected item (if any)
/// is highlighted; the others use [DSButtonVariant.outline] styling.
class DSButtonGroup extends StatelessWidget {
  const DSButtonGroup({
    super.key,
    required this.items,
    this.selectedIndex,
    this.trailingAction,
    this.size = DSButtonSize.md,
    this.variant = DSButtonVariant.outline,
  });

  final List<DSButtonGroupItem> items;

  /// Highlights this segment. Pass null for no selection highlight.
  final int? selectedIndex;

  /// Optional "+" button appended after the last segment.
  final VoidCallback? trailingAction;

  final DSButtonSize size;
  final DSButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? DSColors.gray700 : DSColors.gray200;
    final selectedBg = DSColors.brand;
    final selectedFg = DSColors.white;
    final defaultFg = isDark ? DSColors.gray200 : DSColors.gray700;
    final defaultBg = isDark ? DSColors.gray900 : DSColors.white;

    final textStyle = switch (size) {
      DSButtonSize.sm => DSTypography.labelSm,
      DSButtonSize.md => DSTypography.labelMd,
      DSButtonSize.lg => DSTypography.labelLg,
    };
    final iconSize = switch (size) {
      DSButtonSize.sm => 12.0,
      DSButtonSize.md => 14.0,
      DSButtonSize.lg => 16.0,
    };
    final hPad = switch (size) {
      DSButtonSize.sm => 10.0,
      DSButtonSize.md => 14.0,
      DSButtonSize.lg => 18.0,
    };
    final vPad = switch (size) {
      DSButtonSize.sm => 6.0,
      DSButtonSize.md => 9.0,
      DSButtonSize.lg => 12.0,
    };

    final count = items.length + (trailingAction != null ? 1 : 0);

    BorderRadius borderRadius(int index) {
      final isFirst = index == 0;
      final isLast = index == count - 1;
      final r = Radius.circular(DSRadius.sm);
      return BorderRadius.only(
        topLeft: isFirst ? r : Radius.zero,
        bottomLeft: isFirst ? r : Radius.zero,
        topRight: isLast ? r : Radius.zero,
        bottomRight: isLast ? r : Radius.zero,
      );
    }

    Widget segment({
      required int index,
      required String label,
      Widget? icon,
      VoidCallback? onPressed,
      bool selected = false,
    }) {
      final bg = selected ? selectedBg : defaultBg;
      final fg = selected ? selectedFg : defaultFg;
      final br = borderRadius(index);

      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: br,
            border: Border(
              top: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: index == count - 1 ? BorderSide(color: borderColor) : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(data: IconThemeData(size: iconSize, color: fg), child: icon),
                const SizedBox(width: DSSpacing.xs),
              ],
              Text(label, style: textStyle.copyWith(color: fg)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...items.asMap().entries.map((e) => segment(
              index: e.key,
              label: e.value.label,
              icon: e.value.icon,
              onPressed: e.value.onPressed,
              selected: e.key == selectedIndex,
            )),
        if (trailingAction != null)
          GestureDetector(
            onTap: trailingAction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hPad * 0.7, vertical: vPad),
              decoration: BoxDecoration(
                color: defaultBg,
                borderRadius: borderRadius(count - 1),
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.add, size: iconSize + 2, color: defaultFg),
            ),
          ),
      ],
    );
  }
}

class DSButtonGroupItem {
  const DSButtonGroupItem({
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
}
