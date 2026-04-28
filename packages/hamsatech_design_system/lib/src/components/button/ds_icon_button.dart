import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import 'ds_button.dart';

/// Icon-only button — same variants and sizes as [DSButton], square hit target.
class DSIconButton extends StatelessWidget {
  const DSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = DSButtonVariant.ghost,
    this.size = DSButtonSize.md,
    this.isLoading = false,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final String? tooltip;

  double get _dimension => switch (size) {
        DSButtonSize.sm => 30,
        DSButtonSize.md => 36,
        DSButtonSize.lg => 44,
      };

  double get _iconSize => switch (size) {
        DSButtonSize.sm => 14,
        DSButtonSize.md => 16,
        DSButtonSize.lg => 18,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _config(isDark);

    Widget child = isLoading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(c.fg),
            ),
          )
        : IconTheme(
            data: IconThemeData(size: _iconSize, color: c.fg),
            child: icon,
          );

    final shape = RoundedRectangleBorder(
      borderRadius: DSRadius.borderSm,
      side: c.border ?? BorderSide.none,
    );
    final dim = Size(_dimension, _dimension);
    final tap = isLoading ? null : onPressed;

    Widget btn;
    if (variant == DSButtonVariant.outline) {
      btn = OutlinedButton(
        onPressed: tap,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.fg,
          overlayColor: c.overlay,
          side: c.border,
          shape: shape,
          padding: EdgeInsets.zero,
          minimumSize: dim,
          maximumSize: dim,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    } else if (variant == DSButtonVariant.ghost ||
        variant == DSButtonVariant.linkSecondary ||
        variant == DSButtonVariant.link) {
      btn = TextButton(
        onPressed: tap,
        style: TextButton.styleFrom(
          foregroundColor: c.fg,
          overlayColor: c.overlay,
          shape: shape,
          padding: EdgeInsets.zero,
          minimumSize: dim,
          maximumSize: dim,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    } else {
      btn = ElevatedButton(
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
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(dim),
          maximumSize: WidgetStateProperty.all(dim),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    }

    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }

  _IconBtnConfig _config(bool isDark) => switch (variant) {
        DSButtonVariant.brand => _IconBtnConfig(
            bg: DSColors.brand,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.12),
          ),
        DSButtonVariant.black => _IconBtnConfig(
            bg: DSColors.black,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.10),
          ),
        DSButtonVariant.outline => _IconBtnConfig(
            bg: Colors.transparent,
            fg: isDark ? DSColors.gray200 : DSColors.gray700,
            overlay: (isDark ? DSColors.gray200 : DSColors.gray700).withValues(alpha: 0.06),
            border: BorderSide(color: isDark ? DSColors.gray700 : DSColors.gray200),
          ),
        DSButtonVariant.gray => _IconBtnConfig(
            bg: isDark ? DSColors.gray800 : DSColors.gray100,
            fg: isDark ? DSColors.gray200 : DSColors.gray700,
            overlay: (isDark ? DSColors.white : DSColors.black).withValues(alpha: 0.07),
          ),
        DSButtonVariant.white => _IconBtnConfig(
            bg: DSColors.white,
            fg: DSColors.gray900,
            overlay: DSColors.gray900.withValues(alpha: 0.06),
            border: const BorderSide(color: DSColors.gray200),
          ),
        DSButtonVariant.ghost => _IconBtnConfig(
            bg: Colors.transparent,
            fg: isDark ? DSColors.gray400 : DSColors.gray500,
            overlay: (isDark ? DSColors.gray400 : DSColors.gray500).withValues(alpha: 0.08),
          ),
        DSButtonVariant.linkSecondary || DSButtonVariant.link => _IconBtnConfig(
            bg: Colors.transparent,
            fg: variant == DSButtonVariant.link ? DSColors.brand : (isDark ? DSColors.gray500 : DSColors.gray500),
            overlay: Colors.transparent,
          ),
        DSButtonVariant.danger => _IconBtnConfig(
            bg: DSColors.error,
            fg: DSColors.white,
            overlay: DSColors.white.withValues(alpha: 0.12),
          ),
      };
}

class _IconBtnConfig {
  const _IconBtnConfig({
    required this.bg,
    required this.fg,
    required this.overlay,
    this.border,
  });
  final Color bg;
  final Color fg;
  final Color overlay;
  final BorderSide? border;
}
