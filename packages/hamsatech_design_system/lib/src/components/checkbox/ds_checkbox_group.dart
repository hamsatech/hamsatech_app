import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import 'ds_checkbox.dart';

/// A flat list or inline row of checkboxes.
///
/// Each [DSCheckboxGroupItem] has a unique [id] used to track selection in [values].
class DSCheckboxGroup extends StatelessWidget {
  const DSCheckboxGroup({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.size = DSCheckboxSize.md,
    this.spacing,
  });

  final List<DSCheckboxGroupItem> items;
  final Set<String> values;
  final ValueChanged<Set<String>> onChanged;
  final Axis direction;
  final DSCheckboxSize size;
  final double? spacing;

  void _toggle(String id) {
    final next = Set<String>.from(values);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final gap = spacing ??
        (direction == Axis.vertical ? DSSpacing.md.toDouble() : DSSpacing.lg.toDouble());

    final children = items.map((item) {
      return DSCheckbox(
        value: values.contains(item.id),
        onChanged: item.isDisabled ? null : (_) => _toggle(item.id),
        size: size,
        label: item.label,
        description: item.description,
        badge: item.badge,
        isDisabled: item.isDisabled,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: gap,
        runSpacing: DSSpacing.sm,
        children: children,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand((c) => [c, SizedBox(height: gap)])
          .toList()
        ..removeLast(),
    );
  }
}

class DSCheckboxGroupItem {
  const DSCheckboxGroupItem({
    required this.id,
    required this.label,
    this.description,
    this.badge,
    this.isDisabled = false,
  });

  final String id;
  final String label;
  final String? description;
  final String? badge;
  final bool isDisabled;
}

// ---------------------------------------------------------------------------
// Card-style variant
// ---------------------------------------------------------------------------

/// Each option is rendered inside a bordered card (label + description + badge).
class DSCheckboxCardGroup extends StatelessWidget {
  const DSCheckboxCardGroup({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.size = DSCheckboxSize.md,
  });

  final List<DSCheckboxGroupItem> items;
  final Set<String> values;
  final ValueChanged<Set<String>> onChanged;
  final DSCheckboxSize size;

  void _toggle(String id) {
    final next = Set<String>.from(values);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        final selected = values.contains(item.id);
        final borderColor = selected
            ? DSColors.brand
            : (isDark ? DSColors.appBorder : DSColors.gray200);
        final bgColor = selected
            ? DSColors.brand.withValues(alpha: isDark ? 0.08 : 0.04)
            : (isDark ? DSColors.appCard : DSColors.white);

        return GestureDetector(
          onTap: item.isDisabled ? null : () => _toggle(item.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: DSSpacing.sm),
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: DSRadius.borderMd,
              border: Border.all(color: borderColor),
            ),
            child: DSCheckbox(
              value: selected,
              onChanged: item.isDisabled ? null : (_) => _toggle(item.id),
              size: size,
              label: item.label,
              description: item.description,
              badge: item.badge,
              isDisabled: item.isDisabled,
            ),
          ),
        );
      }).toList(),
    );
  }
}
