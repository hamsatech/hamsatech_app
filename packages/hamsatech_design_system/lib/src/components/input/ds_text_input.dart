import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_input_label.dart';

enum DSInputState { normal, error, disabled, loading }

class DSTextInput extends StatefulWidget {
  const DSTextInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.state = DSInputState.normal,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.minLines,
    this.maxLines = 1,
    this.validator,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Widget? suffix;
  final DSInputState state;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<DSTextInput> createState() => _DSTextInputState();
}

class _DSTextInputState extends State<DSTextInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() => _isFocused = _focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isError = widget.state == DSInputState.error || widget.errorText != null;
    final isDisabled = widget.state == DSInputState.disabled;
    final isLoading = widget.state == DSInputState.loading;

    final borderColor = isError
        ? DSColors.error
        : isDisabled
            ? (isDark ? DSColors.gray800 : DSColors.gray200)
            : _isFocused
                ? DSColors.brand
                : (isDark ? DSColors.gray700 : DSColors.gray200);

    final borderWidth = (_isFocused || isError) ? 1.5 : 1.0;

    final fillColor = isDisabled
        ? (isDark ? const Color(0xFF001418) : DSColors.gray50)
        : (isDark ? const Color(0xFF0A1C20) : DSColors.white);

    OutlineInputBorder border(Color c, [double? w]) => OutlineInputBorder(
          borderRadius: DSRadius.borderMd,
          borderSide: BorderSide(color: c, width: w ?? borderWidth),
        );

    Widget? resolvedSuffix;
    if (isLoading) {
      resolvedSuffix = Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? DSColors.gray500 : DSColors.gray400,
            ),
          ),
        ),
      );
    } else if (isError) {
      resolvedSuffix = const Padding(
        padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
        child: Icon(Icons.cancel_rounded, color: DSColors.error, size: 16),
      );
    } else {
      resolvedSuffix = widget.suffixIcon;
    }

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
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          validator: widget.validator,
          autofocus: widget.autofocus,
          readOnly: isDisabled || widget.readOnly,
          onTap: widget.onTap,
          enabled: !isDisabled,
          style: DSTypography.bodyMd.copyWith(
            color: isDisabled
                ? (isDark ? DSColors.textMuted : DSColors.textDisabled)
                : (isDark ? DSColors.white : DSColors.textPrimary),
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: DSTypography.bodyMd.copyWith(
              color: isDark ? DSColors.textMuted : DSColors.textPlaceholder,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md + 2,
              vertical: DSSpacing.md - 1,
            ),
            isDense: true,
            border: border(borderColor),
            enabledBorder: border(borderColor, 1.0),
            focusedBorder: border(borderColor, 1.5),
            disabledBorder: border(
              isDark ? DSColors.gray800 : DSColors.gray200,
              1.0,
            ),
            errorBorder: border(DSColors.error, 1.0),
            focusedErrorBorder: border(DSColors.error, 1.5),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(minWidth: 40, minHeight: 40)
                : null,
            prefix: widget.prefix,
            suffixIcon: resolvedSuffix,
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffix: widget.suffix,
            counterText: '',
            errorText: null,
          ),
        ),
        if (isError && widget.errorText != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.info_outline_rounded, size: 12, color: DSColors.error),
              ),
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
