import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

enum DSButtonVariant { brand, black, outline, gray, white, ghost, linkSecondary, link, danger }

enum DSButtonSize { sm, md, lg }

class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.brand,
    this.size = DSButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.shortcut,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? shortcut;
  final bool isLoading;
  final bool isFullWidth;

  EdgeInsetsGeometry get _padding => switch (size) {
        DSButtonSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        DSButtonSize.md => const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        DSButtonSize.lg => const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      };

  double get _iconSize => switch (size) {
        DSButtonSize.sm => 14,
        DSButtonSize.md => 16,
        DSButtonSize.lg => 18,
      };

  TextStyle get _textStyle => switch (size) {
        DSButtonSize.sm => DSTypography.labelSm,
        DSButtonSize.md => DSTypography.labelMd,
        DSButtonSize.lg => DSTypography.labelLg,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _config(isDark);
    final btn = _build(context, config);
    if (isFullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }

  _BtnConfig _config(bool isDark) => switch (variant) {
        DSButtonVariant.brand => _BtnConfig(
            bg: DSColors.brand,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.12),
          ),
        DSButtonVariant.black => _BtnConfig(
            bg: DSColors.black,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.10),
          ),
        DSButtonVariant.outline => _BtnConfig(
            bg: Colors.transparent,
            fg: isDark ? DSColors.gray200 : DSColors.gray700,
            overlay: (isDark ? DSColors.gray200 : DSColors.gray700).withValues(alpha: 0.06),
            border: BorderSide(color: isDark ? DSColors.gray700 : DSColors.gray200),
          ),
        DSButtonVariant.gray => _BtnConfig(
            bg: isDark ? DSColors.gray800 : DSColors.gray100,
            fg: isDark ? DSColors.gray200 : DSColors.gray700,
            overlay: (isDark ? DSColors.white : DSColors.black).withValues(alpha: 0.07),
          ),
        DSButtonVariant.white => _BtnConfig(
            bg: DSColors.white,
            fg: DSColors.gray900,
            overlay: DSColors.gray900.withValues(alpha: 0.06),
            border: const BorderSide(color: DSColors.gray200),
          ),
        DSButtonVariant.ghost => _BtnConfig(
            bg: Colors.transparent,
            fg: isDark ? DSColors.gray400 : DSColors.gray500,
            overlay: (isDark ? DSColors.gray400 : DSColors.gray500).withValues(alpha: 0.08),
          ),
        DSButtonVariant.linkSecondary => _BtnConfig(
            bg: Colors.transparent,
            fg: isDark ? DSColors.gray500 : DSColors.gray500,
            overlay: Colors.transparent,
            isLink: true,
          ),
        DSButtonVariant.link => _BtnConfig(
            bg: Colors.transparent,
            fg: DSColors.brand,
            overlay: Colors.transparent,
            isLink: true,
          ),
        DSButtonVariant.danger => _BtnConfig(
            bg: DSColors.error,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.12),
          ),
      };

  Widget _content(BuildContext context, Color fg) {
    final iconData = IconThemeData(size: _iconSize, color: fg);
    final effectiveLeading = isLoading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : leadingIcon != null
            ? IconTheme(data: iconData, child: leadingIcon!)
            : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (effectiveLeading != null) ...[
          effectiveLeading,
          const SizedBox(width: DSSpacing.sm),
        ],
        Text(label, style: _textStyle.copyWith(color: fg)),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: DSSpacing.sm),
          IconTheme(data: iconData, child: trailingIcon!),
        ],
        if (shortcut != null) ...[
          const SizedBox(width: DSSpacing.sm),
          _ShortcutBadge(shortcut: shortcut!),
        ],
      ],
    );
  }

  Widget _build(BuildContext context, _BtnConfig c) {
    final tap = isLoading ? null : onPressed;
    final shape = RoundedRectangleBorder(
      borderRadius: DSRadius.borderSm,
      side: c.border ?? BorderSide.none,
    );
    final minSize = const Size(0, 0);

    if (variant == DSButtonVariant.outline) {
      return OutlinedButton(
        onPressed: tap,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.fg,
          overlayColor: c.overlay,
          side: c.border,
          shape: shape,
          padding: _padding,
          textStyle: _textStyle,
          minimumSize: minSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _content(context, c.fg),
      );
    }

    if (variant == DSButtonVariant.ghost ||
        variant == DSButtonVariant.linkSecondary ||
        variant == DSButtonVariant.link) {
      return TextButton(
        onPressed: tap,
        style: TextButton.styleFrom(
          foregroundColor: c.fg,
          overlayColor: c.overlay,
          shape: shape,
          padding: c.isLink ? EdgeInsets.zero : _padding,
          textStyle: _textStyle,
          minimumSize: minSize,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _content(context, c.fg),
      );
    }

    // brand, black, gray, white
    return ElevatedButton(
      onPressed: tap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled) ? c.bg.withValues(alpha: 0.45) : c.bg),
        foregroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled) ? c.fg.withValues(alpha: 0.45) : c.fg),
        overlayColor: WidgetStateProperty.all(c.overlay),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(shape),
        padding: WidgetStateProperty.all(_padding),
        textStyle: WidgetStateProperty.all(_textStyle),
        minimumSize: WidgetStateProperty.all(minSize),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _content(context, c.fg),
    );
  }
}

class _BtnConfig {
  const _BtnConfig({
    required this.bg,
    required this.fg,
    required this.overlay,
    this.border,
    this.isLink = false,
  });

  final Color bg;
  final Color fg;
  final Color overlay;
  final BorderSide? border;
  final bool isLink;
}

class _ShortcutBadge extends StatelessWidget {
  const _ShortcutBadge({required this.shortcut});
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? DSColors.gray800 : DSColors.gray100,
        borderRadius: DSRadius.borderXs,
        border: Border.all(
          color: isDark ? DSColors.gray700 : DSColors.gray300,
        ),
      ),
      child: Text(
        shortcut,
        style: DSTypography.labelXs.copyWith(
          color: isDark ? DSColors.gray300 : DSColors.gray600,
        ),
      ),
    );
  }
}
