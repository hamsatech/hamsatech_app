import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_text_input.dart';

/// Multi-line text area with optional character counter.
///
/// Wraps [DSTextInput] with vertical expand behaviour and an optional
/// max-length counter displayed below the field.
class DSTextArea extends StatelessWidget {
  const DSTextArea({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.minLines = 4,
    this.maxLines,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final DSInputState state;

  /// Minimum visible lines (default 4).
  final int minLines;

  /// Maximum visible lines before scrolling. null = unlimited.
  final int? maxLines;

  /// When set, shows a "current / max characters" counter.
  final int? maxLength;

  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isError = state == DSInputState.error || errorText != null;

    void handleChanged(String v) {
      onChanged?.call(v);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DSTextInput(
          controller: controller,
          label: label,
          isRequired: isRequired,
          showInfoIcon: showInfoIcon,
          infoTooltip: infoTooltip,
          placeholder: placeholder,
          helperText: helperText,
          errorText: errorText,
          state: state,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          onChanged: handleChanged,
          validator: validator,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
        if (maxLength != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final count = controller.text.length;
                final over = count > maxLength!;
                return Text(
                  'Max length: $maxLength characters.',
                  style: DSTypography.caption.copyWith(
                    color: over
                        ? DSColors.error
                        : (isError
                            ? DSColors.error
                            : (isDark ? DSColors.gray500 : DSColors.gray500)),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
