import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_text_input.dart';

class DSAmountInput extends StatelessWidget {
  const DSAmountInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = '0.00',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.availableCurrencies = const ['USD', 'EUR', 'GBP', 'AUD'],
    this.onCurrencyChanged,
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
  final String currencySymbol;
  final String currencyCode;
  final List<String> availableCurrencies;
  final ValueChanged<String>? onCurrencyChanged;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? DSColors.gray500 : DSColors.gray400;
    final dividerColor = isDark ? DSColors.gray700 : DSColors.gray200;
    final fgColor = isDark ? DSColors.gray300 : DSColors.gray700;

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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: onChanged,
      focusNode: focusNode,
      prefix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currencySymbol, style: DSTypography.bodyMd.copyWith(color: mutedColor)),
          const SizedBox(width: DSSpacing.sm),
          Container(width: 1, height: 18, color: dividerColor),
          const SizedBox(width: DSSpacing.sm),
        ],
      ),
      suffix: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 1, height: 18, color: dividerColor),
            const SizedBox(width: DSSpacing.sm),
            GestureDetector(
              onTap: onCurrencyChanged == null
                  ? null
                  : () => _showCurrencyPicker(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencyCode,
                    style: DSTypography.labelSm.copyWith(color: fgColor),
                  ),
                  if (onCurrencyChanged != null) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: isDark ? DSColors.gray500 : DSColors.gray400,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.xs),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: availableCurrencies
            .map(
              (c) => ListTile(
                title: Text(c),
                trailing: c == currencyCode
                    ? const Icon(Icons.check_rounded, size: 18)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onCurrencyChanged?.call(c);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
