import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import 'ds_text_input.dart';

class DSReferralInput extends StatelessWidget {
  const DSReferralInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'Enter referral code',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
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
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? DSColors.gray500 : DSColors.gray400;

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
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      focusNode: focusNode,
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.copy_outlined, size: 16, color: iconColor),
              splashRadius: 16,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            )
          : null,
    );
  }
}
