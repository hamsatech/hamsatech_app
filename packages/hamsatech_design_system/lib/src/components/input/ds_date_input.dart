import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../tokens/ds_colors.dart';
import 'ds_text_input.dart';

class DSDateInput extends StatefulWidget {
  const DSDateInput({
    super.key,
    required this.controller,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'mm/dd/yyyy',
    this.helperText,
    this.errorText,
    this.state = DSInputState.normal,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'MM/dd/yyyy',
    this.onDateSelected,
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
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String dateFormat;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<DSDateInput> createState() => _DSDateInputState();
}

class _DSDateInputState extends State<DSDateInput> {
  Future<void> _pickDate() async {
    if (widget.state == DSInputState.disabled) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      widget.controller.text = DateFormat(widget.dateFormat).format(picked);
      widget.onDateSelected?.call(picked);
    }
  }

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
      readOnly: true,
      onTap: _pickDate,
      suffixIcon: GestureDetector(
        onTap: _pickDate,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.calendar_today_outlined, size: 16, color: iconColor),
        ),
      ),
    );
  }
}
