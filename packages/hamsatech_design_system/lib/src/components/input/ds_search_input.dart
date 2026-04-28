import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import 'ds_text_input.dart';

class DSSearchInput extends StatelessWidget {
  const DSSearchInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'Search anything...',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.onChanged,
    this.onSubmitted,
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
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          Icons.search_rounded,
          size: 18,
          color: isDark ? DSColors.gray500 : DSColors.gray400,
        ),
      ),
    );
  }
}
