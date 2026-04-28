import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

// ---------------------------------------------------------------------------
// Trailing mode
// ---------------------------------------------------------------------------

enum DSSelectItemTrailing {
  /// Shows a checkmark when [isSelected], nothing otherwise.
  check,

  /// Shows a Switch (orange = on, gray = off).
  toggle,

  /// Shows a checkbox before the leading widget (left side).
  checkbox,
}

// ---------------------------------------------------------------------------
// Leading helpers
// ---------------------------------------------------------------------------

/// Small icon + tinted square background (category style).
class DSItemIcon extends StatelessWidget {
  const DSItemIcon({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = color ?? (isDark ? DSColors.gray300 : DSColors.gray600);
    return Icon(icon, size: 18, color: fg);
  }
}

/// Circle with two-letter initials (avatar fallback).
class DSItemInitials extends StatelessWidget {
  const DSItemInitials({super.key, required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: DSTypography.labelXs.copyWith(color: DSColors.white, height: 1),
      ),
    );
  }
}

/// Network/asset image avatar.
class DSItemAvatar extends StatelessWidget {
  const DSItemAvatar({super.key, this.imageUrl, this.fallbackInitials = '?', this.color});

  final String? imageUrl;
  final String fallbackInitials;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context),
        ),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DSItemInitials(
      initials: fallbackInitials,
      color: color ?? (isDark ? DSColors.gray700 : DSColors.gray300),
    );
  }
}

/// Small filled circle used for status/colour dots.
class DSItemColorDot extends StatelessWidget {
  const DSItemColorDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ---------------------------------------------------------------------------
// Core item
// ---------------------------------------------------------------------------

/// A tappable list row that supports three trailing interaction modes.
///
/// ```dart
/// DSSelectItem(
///   label: 'Luke Evans',
///   subtitle: '@lukeevans',
///   leading: DSItemAvatar(fallbackInitials: 'LE', color: Colors.teal),
///   isSelected: true,
///   trailing: DSSelectItemTrailing.check,
///   onTap: () {},
/// )
/// ```
class DSSelectItem extends StatelessWidget {
  const DSSelectItem({
    super.key,
    required this.label,
    this.subtitle,
    this.leading,
    this.isSelected = false,
    this.onTap,
    this.onToggle,
    this.trailing = DSSelectItemTrailing.check,
    this.isDisabled = false,
  });

  final String label;
  final String? subtitle;

  /// Widget shown before the label — use [DSItemIcon], [DSItemAvatar],
  /// [DSItemInitials], [DSItemColorDot], or any widget.
  final Widget? leading;

  /// Whether this item is selected / toggled on.
  final bool isSelected;

  final VoidCallback? onTap;

  /// Called when the toggle/checkbox value changes.
  final ValueChanged<bool>? onToggle;

  final DSSelectItemTrailing trailing;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDisabled
        ? (isDark ? DSColors.gray600 : DSColors.gray400)
        : (isDark ? DSColors.gray100 : DSColors.gray900);
    final subColor = isDisabled
        ? (isDark ? DSColors.gray700 : DSColors.gray300)
        : DSColors.textSecondary;

    Widget? checkboxWidget;
    if (trailing == DSSelectItemTrailing.checkbox) {
      checkboxWidget = _SmallCheckbox(checked: isSelected, isDark: isDark);
    }

    Widget? trailingWidget;
    switch (trailing) {
      case DSSelectItemTrailing.check:
        trailingWidget = isSelected
            ? Icon(Icons.check_rounded,
                size: 16,
                color: isDisabled ? DSColors.brand.withValues(alpha: 0.4) : DSColors.brand)
            : null;
      case DSSelectItemTrailing.toggle:
        trailingWidget = _DSSwitch(
          value: isSelected,
          isDisabled: isDisabled,
          onChanged: isDisabled ? null : onToggle,
        );
      case DSSelectItemTrailing.checkbox:
        trailingWidget = null;
    }

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              onTap?.call();
              if (trailing == DSSelectItemTrailing.toggle ||
                  trailing == DSSelectItemTrailing.checkbox) {
                onToggle?.call(!isSelected);
              }
            },
      borderRadius: DSRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm + 2,
        ),
        child: Row(
          children: [
            // Checkbox goes on the LEFT
            if (checkboxWidget != null) ...[
              checkboxWidget,
              const SizedBox(width: DSSpacing.sm),
            ],
            // Leading widget
            if (leading != null) ...[
              Opacity(opacity: isDisabled ? 0.4 : 1.0, child: leading!),
              const SizedBox(width: DSSpacing.sm),
            ],
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: DSTypography.labelMd.copyWith(color: textColor)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: DSTypography.bodySm.copyWith(color: subColor)),
                ],
              ),
            ),
            // Trailing widget (check / toggle)
            if (trailingWidget != null) ...[
              const SizedBox(width: DSSpacing.sm),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _SmallCheckbox extends StatelessWidget {
  const _SmallCheckbox({required this.checked, required this.isDark});
  final bool checked;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? DSColors.brand : Colors.transparent,
        borderRadius: DSRadius.borderXs,
        border: Border.all(
          color: checked ? DSColors.brand : (isDark ? DSColors.gray600 : DSColors.gray300),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 11, color: DSColors.white)
          : null,
    );
  }
}

class _DSSwitch extends StatelessWidget {
  const _DSSwitch({required this.value, this.onChanged, this.isDisabled = false});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDisabled
              ? (value
                  ? DSColors.brand.withValues(alpha: 0.35)
                  : DSColors.gray400.withValues(alpha: 0.3))
              : (value ? DSColors.brand : DSColors.gray400),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: DSColors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List container
// ---------------------------------------------------------------------------

/// Wraps a list of [DSSelectItem]s inside a bordered card with dividers.
class DSSelectList extends StatelessWidget {
  const DSSelectList({
    super.key,
    required this.children,
    this.showDividers = true,
  });

  final List<Widget> children;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? DSColors.appBorder : DSColors.gray100;

    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (showDividers && i < children.length - 1) {
        items.add(Divider(height: 1, thickness: 1, color: dividerColor));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DSColors.appCard : DSColors.white,
        borderRadius: DSRadius.borderMd,
        border: Border.all(color: isDark ? DSColors.appBorder : DSColors.gray200),
      ),
      child: ClipRRect(
        borderRadius: DSRadius.borderMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}
