import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_input_label.dart';

class DSOtpInput extends StatefulWidget {
  const DSOtpInput({
    super.key,
    this.length = 4,
    this.separatorAfter,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.cellSize = 52,
    this.cellSpacing = 8,
    this.onChanged,
    this.onCompleted,
  });

  /// Number of OTP digits.
  final int length;

  /// Insert a separator dot after this index (0-based). e.g. 2 for "123 · 456".
  final int? separatorAfter;

  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? helperText;
  final String? errorText;
  final bool isDisabled;
  final double cellSize;
  final double cellSpacing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<DSOtpInput> createState() => _DSOtpInputState();
}

class _DSOtpInputState extends State<DSOtpInput> {
  late final List<TextEditingController> _ctrls;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    for (final n in _nodes) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _ctrls.map((c) => c.text).join();

  void _onCellChanged(int index, String raw) {
    if (raw.length > 1) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _ctrls[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length < widget.length ? digits.length : widget.length - 1;
      _nodes[next].requestFocus();
    } else if (raw.isNotEmpty) {
      _ctrls[index].text = raw;
      if (index < widget.length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }
    final val = _value;
    widget.onChanged?.call(val);
    if (val.length == widget.length) widget.onCompleted?.call(val);
    setState(() {});
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[index].text.isEmpty &&
        index > 0) {
      _ctrls[index - 1].clear();
      _nodes[index - 1].requestFocus();
      widget.onChanged?.call(_value);
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.errorText != null;

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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length * 2 - 1, (i) {
            if (i.isOdd) {
              final cellIndex = i ~/ 2;
              if (widget.separatorAfter != null &&
                  cellIndex == widget.separatorAfter) {
                return _Separator();
              }
              return SizedBox(width: widget.cellSpacing);
            }
            final idx = i ~/ 2;
            return _OtpCell(
              controller: _ctrls[idx],
              focusNode: _nodes[idx],
              size: widget.cellSize,
              isDisabled: widget.isDisabled,
              isError: isError,
              onChanged: (v) => _onCellChanged(idx, v),
              onKeyEvent: (e) => _onKeyEvent(idx, e),
            );
          }),
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
              color: DSColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpCell extends StatefulWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.size,
    required this.isDisabled,
    required this.isError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final double size;
  final bool isDisabled;
  final bool isError;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent) onKeyEvent;

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = widget.focusNode.hasFocus;

    Color borderColor;
    Color bgColor;

    if (widget.isDisabled) {
      borderColor = isDark ? DSColors.gray800 : DSColors.gray200;
      bgColor = isDark ? const Color(0xFF001418) : DSColors.gray50;
    } else if (widget.isError) {
      borderColor = DSColors.error;
      bgColor = isDark ? const Color(0xFF0A1C20) : DSColors.white;
    } else if (isFocused) {
      borderColor = isDark ? DSColors.gray300 : DSColors.gray700;
      bgColor = isDark ? DSColors.gray800 : DSColors.white;
    } else if (_isHovered) {
      borderColor = isDark ? DSColors.gray600 : DSColors.gray300;
      bgColor = isDark ? DSColors.gray800 : DSColors.gray50;
    } else {
      borderColor = isDark ? DSColors.gray700 : DSColors.gray200;
      bgColor = isDark ? const Color(0xFF0A1C20) : DSColors.white;
    }

    return MouseRegion(
      cursor: widget.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: DSRadius.borderSm,
          border: Border.all(
            color: borderColor,
            width: isFocused ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Focus(
            onKeyEvent: (_, e) => widget.onKeyEvent(e),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              readOnly: widget.isDisabled,
              enabled: !widget.isDisabled,
              onChanged: widget.onChanged,
              cursorColor: DSColors.brand,
              cursorWidth: 1.5,
              style: DSTypography.headingMd.copyWith(
                color: widget.isDisabled
                    ? (isDark ? DSColors.textMuted : DSColors.textDisabled)
                    : (isDark ? DSColors.white : DSColors.textPrimary),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: DSTypography.headingMd.copyWith(
          color: isDark ? DSColors.textMuted : DSColors.textPlaceholder,
        ),
      ),
    );
  }
}
