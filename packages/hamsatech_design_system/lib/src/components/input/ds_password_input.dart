import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import 'ds_text_input.dart';

class DSPasswordInput extends StatefulWidget {
  const DSPasswordInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'Enter password',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.onChanged,
    this.onSubmitted,
    this.validator,
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
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  @override
  State<DSPasswordInput> createState() => _DSPasswordInputState();
}

class _DSPasswordInputState extends State<DSPasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? DSColors.gray500 : DSColors.gray400;

    return DSTextInput(
      controller: widget.controller,
      label: widget.label,
      isRequired: widget.isRequired,
      showInfoIcon: widget.showInfoIcon,
      infoTooltip: widget.infoTooltip,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      errorText: widget.errorText,
      state: widget.state,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      focusNode: widget.focusNode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: iconColor,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
        splashRadius: 16,
      ),
    );
  }
}
