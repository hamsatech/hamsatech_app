import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_input_label.dart';

class DSTagsInput extends StatefulWidget {
  const DSTagsInput({
    super.key,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder = 'Type and press enter to add a tag...',
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.initialTags = const [],
    this.onTagsChanged,
  });

  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String placeholder;
  final String? helperText;
  final String? errorText;
  final bool isDisabled;
  final List<String> initialTags;
  final ValueChanged<List<String>>? onTagsChanged;

  @override
  State<DSTagsInput> createState() => _DSTagsInputState();
}

class _DSTagsInputState extends State<DSTagsInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<String> _tags;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _controller.clear();
      widget.onTagsChanged?.call(List.unmodifiable(_tags));
    } else {
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onTagsChanged?.call(List.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isError = widget.errorText != null;

    final borderColor = isError
        ? DSColors.error
        : widget.isDisabled
            ? (isDark ? DSColors.gray800 : DSColors.gray200)
            : _isFocused
                ? DSColors.brand
                : (isDark ? DSColors.gray700 : DSColors.gray200);

    final borderWidth = (_isFocused || isError) ? 1.5 : 1.0;

    final fillColor = widget.isDisabled
        ? (isDark ? const Color(0xFF0D1117) : DSColors.gray50)
        : (isDark ? const Color(0xFF111827) : DSColors.white);

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
        GestureDetector(
          onTap: widget.isDisabled ? null : _focusNode.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: DSRadius.borderMd,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._tags.map((tag) => _TagChip(
                      tag: tag,
                      onRemove: widget.isDisabled ? null : () => _removeTag(tag),
                      isDark: isDark,
                    )),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 80),
                  child: IntrinsicWidth(
                    child: Focus(
                      onKeyEvent: (_, event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controller.text.isEmpty &&
                            _tags.isNotEmpty) {
                          _removeTag(_tags.last);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !widget.isDisabled,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _addTag,
                        style: DSTypography.bodyMd.copyWith(
                          color: widget.isDisabled
                              ? (isDark ? DSColors.gray600 : DSColors.gray400)
                              : (isDark ? DSColors.gray100 : DSColors.gray900),
                        ),
                        decoration: InputDecoration(
                          hintText: _tags.isEmpty ? widget.placeholder : '',
                          hintStyle: DSTypography.bodyMd.copyWith(
                            color: isDark ? DSColors.gray600 : DSColors.gray400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          counterText: '',
                        ),
                        cursorColor: DSColors.brand,
                        cursorWidth: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.onRemove,
    required this.isDark,
  });

  final String tag;
  final VoidCallback? onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? DSColors.gray800 : DSColors.gray100,
        borderRadius: DSRadius.borderFull,
        border: Border.all(
          color: isDark ? DSColors.gray700 : DSColors.gray200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: DSTypography.labelSm.copyWith(
              color: isDark ? DSColors.gray300 : DSColors.gray700,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: DSSpacing.xxs + 1),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 13,
                color: isDark ? DSColors.gray500 : DSColors.gray400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
