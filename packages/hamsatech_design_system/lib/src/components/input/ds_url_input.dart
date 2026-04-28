import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_typography.dart';
import 'ds_text_input.dart';

class DSUrlInput extends StatelessWidget {
  const DSUrlInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'hamsatech.com',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.scheme = 'https://',
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String placeholder;
  final String? helperText;
  final String? errorText;
  final DSInputState state;
  final String scheme;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? DSColors.gray500 : DSColors.gray400;
    final dividerColor = isDark ? DSColors.gray700 : DSColors.gray200;

    return DSTextInput(
      controller: controller,
      label: label,
      isRequired: isRequired,
      showInfoIcon: showInfoIcon,
      infoTooltip: infoTooltip,
      placeholder: placeholder,
      helperText: helperText,
      errorText: errorText,
      state: state,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      focusNode: focusNode,
      prefix: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(scheme, style: DSTypography.bodyMd.copyWith(color: mutedColor)),
            const SizedBox(width: 8),
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
