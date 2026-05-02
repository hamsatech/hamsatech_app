import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_input_label.dart';
import 'ds_text_input.dart';

class DSCountryCode {
  const DSCountryCode({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });

  final String name;
  final String flag;
  final String code;
  final String dialCode;

  static const DSCountryCode us =
      DSCountryCode(name: 'United States', flag: '🇺🇸', code: 'US', dialCode: '+1');
  static const DSCountryCode gb =
      DSCountryCode(name: 'United Kingdom', flag: '🇬🇧', code: 'GB', dialCode: '+44');
  static const DSCountryCode in_ =
      DSCountryCode(name: 'India', flag: '🇮🇳', code: 'IN', dialCode: '+91');
  static const DSCountryCode au =
      DSCountryCode(name: 'Australia', flag: '🇦🇺', code: 'AU', dialCode: '+61');
  static const DSCountryCode es =
      DSCountryCode(name: 'Spain', flag: '🇪🇸', code: 'ES', dialCode: '+34');
  static const DSCountryCode ae =
      DSCountryCode(name: 'UAE', flag: '🇦🇪', code: 'AE', dialCode: '+971');
  static const DSCountryCode ca =
      DSCountryCode(name: 'Canada', flag: '🇨🇦', code: 'CA', dialCode: '+1');
  static const DSCountryCode de =
      DSCountryCode(name: 'Germany', flag: '🇩🇪', code: 'DE', dialCode: '+49');
  static const DSCountryCode fr =
      DSCountryCode(name: 'France', flag: '🇫🇷', code: 'FR', dialCode: '+33');
  static const DSCountryCode sg =
      DSCountryCode(name: 'Singapore', flag: '🇸🇬', code: 'SG', dialCode: '+65');
  static const DSCountryCode nz =
      DSCountryCode(name: 'New Zealand', flag: '🇳🇿', code: 'NZ', dialCode: '+64');
  static const DSCountryCode za =
      DSCountryCode(name: 'South Africa', flag: '🇿🇦', code: 'ZA', dialCode: '+27');

  static const List<DSCountryCode> common = [
    us, gb, in_, au, es, ae, ca, de, fr, sg, nz, za,
  ];
}

class DSPhoneInput extends StatefulWidget {
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
  State<DSPhoneInput> createState() => _DSPhoneInputState();
}

class _DSPhoneInputState extends State<DSPhoneInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _isFocused = _focusNode.hasFocus);

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

    final fgColor = isDark ? DSColors.gray300 : DSColors.gray700;
    final hintColor = isDark ? DSColors.gray600 : DSColors.gray400;
    final dividerColor = isDark ? DSColors.gray700 : DSColors.gray200;
    final chevronColor = isDark ? DSColors.gray500 : DSColors.gray400;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Country code selector
              GestureDetector(
                onTap: isDisabled ? null : widget.onCountryTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.md - 1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.selectedCountry.code} (${widget.selectedCountry.dialCode})',
                        style: DSTypography.bodyMd.copyWith(color: fgColor),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: chevronColor,
                      ),
                    ],
                  ),
                ),
              ),
              // Vertical divider
              Container(
                width: 1,
                height: 22,
                color: dividerColor,
              ),
              // Phone number text field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: widget.onChanged,
                  enabled: !isDisabled,
                  style: DSTypography.bodyMd.copyWith(
                    color: isDisabled
                        ? (isDark ? DSColors.gray600 : DSColors.gray400)
                        : (isDark ? DSColors.gray100 : DSColors.gray900),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: DSTypography.bodyMd.copyWith(color: hintColor),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.md,
                      vertical: DSSpacing.md - 1,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
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
