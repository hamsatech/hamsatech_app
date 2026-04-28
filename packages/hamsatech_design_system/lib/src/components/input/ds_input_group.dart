import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_input_label.dart';
import 'ds_text_input.dart';

/// An inline input + trailing action button joined inside a single border.
///
/// Matches the "Subscribe to Newsletter" pattern: an email-style text field
/// with a branded button flush to the right edge.
class DSInputGroup extends StatefulWidget {
  const DSInputGroup({
    super.key,
    required this.controller,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.state = DSInputState.normal,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.isButtonLoading = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final DSInputState state;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool isButtonLoading;
  final FocusNode? focusNode;

  @override
  State<DSInputGroup> createState() => _DSInputGroupState();
}

class _DSInputGroupState extends State<DSInputGroup> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isError = widget.state == DSInputState.error || widget.errorText != null;
    final isDisabled = widget.state == DSInputState.disabled;

    final borderColor = isError
        ? DSColors.error
        : isDisabled
            ? (isDark ? DSColors.gray800 : DSColors.gray200)
            : _isFocused
                ? DSColors.brand
                : (isDark ? DSColors.gray700 : DSColors.gray200);
    final borderWidth = (_isFocused || isError) ? 1.5 : 1.0;

    final fillColor = isDisabled
        ? (isDark ? const Color(0xFF0D1117) : DSColors.gray50)
        : (isDark ? const Color(0xFF111827) : DSColors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          DSInputLabel(
            label: widget.label!,
            isRequired: widget.isRequired,
            showInfoIcon: widget.showInfoIcon,
            infoTooltip: widget.infoTooltip,
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: DSRadius.borderMd,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  readOnly: isDisabled,
                  enabled: !isDisabled,
                  style: DSTypography.bodyMd.copyWith(
                    color: isDisabled
                        ? (isDark ? DSColors.gray600 : DSColors.gray400)
                        : (isDark ? DSColors.gray100 : DSColors.gray900),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: DSTypography.bodyMd.copyWith(
                      color: isDark ? DSColors.gray600 : DSColors.gray400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.md,
                      vertical: DSSpacing.md - 1,
                    ),
                    prefixIcon: widget.prefixIcon,
                    prefixIconConstraints: widget.prefixIcon != null
                        ? const BoxConstraints(minWidth: 40, minHeight: 40)
                        : null,
                    counterText: '',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: _GroupButton(
                  label: widget.buttonLabel,
                  onPressed: isDisabled ? null : widget.onButtonPressed,
                  isLoading: widget.isButtonLoading,
                ),
              ),
            ],
          ),
        ),
        if (isError && widget.errorText != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 12, color: DSColors.error),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  widget.errorText!,
                  style: DSTypography.bodySm.copyWith(color: DSColors.error),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            widget.helperText!,
            style: DSTypography.bodySm.copyWith(
              color: isDark ? DSColors.gray500 : DSColors.gray500,
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupButton extends StatelessWidget {
  const _GroupButton({required this.label, this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.disabled)
                ? DSColors.brand.withValues(alpha: 0.45)
                : DSColors.brand),
        foregroundColor: WidgetStateProperty.all(DSColors.white),
        overlayColor: WidgetStateProperty.all(DSColors.white.withValues(alpha: 0.12)),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: DSRadius.borderSm),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm + 2),
        ),
        minimumSize: WidgetStateProperty.all(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(DSColors.white),
              ),
            )
          : Text(label, style: DSTypography.labelMd.copyWith(color: DSColors.white)),
    );
  }
}
