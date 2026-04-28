import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_text_input.dart';

class DSCountryCode {
  const DSCountryCode({
    required this.flag,
    required this.code,
    required this.dialCode,
  });

  final String flag;
  final String code;
  final String dialCode;

  static const DSCountryCode us =
      DSCountryCode(flag: '🇺🇸', code: 'US', dialCode: '+1');
  static const DSCountryCode gb =
      DSCountryCode(flag: '🇬🇧', code: 'GB', dialCode: '+44');
  static const DSCountryCode in_ =
      DSCountryCode(flag: '🇮🇳', code: 'IN', dialCode: '+91');
  static const DSCountryCode au =
      DSCountryCode(flag: '🇦🇺', code: 'AU', dialCode: '+61');

  static const List<DSCountryCode> common = [us, gb, in_, au];
}

class DSPhoneInput extends StatelessWidget {
  const DSPhoneInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = '000-000-0000',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.selectedCountry = DSCountryCode.us,
    this.onCountryTap,
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
  final DSCountryCode selectedCountry;
  final VoidCallback? onCountryTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? DSColors.gray300 : DSColors.gray700;
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
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      focusNode: focusNode,
      prefix: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onCountryTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedCountry.flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    selectedCountry.dialCode,
                    style: DSTypography.bodyMd.copyWith(color: fgColor),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: isDark ? DSColors.gray500 : DSColors.gray400,
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            const SizedBox(width: DSSpacing.sm),
          ],
        ),
      ),
    );
  }
}
