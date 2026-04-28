import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import 'ds_text_input.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class DSComboboxItem<T> {
  const DSComboboxItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
  });

  final T value;
  final String label;
  final String? subtitle;

  /// Optional leading widget (icon, flag, avatar…)
  final Widget? leading;
}

// ---------------------------------------------------------------------------
// Single-select combobox
// ---------------------------------------------------------------------------

/// A text input that opens a searchable dropdown overlay.
///
/// Use [DSMultiCombobox] for multi-select with checkboxes.
class DSCombobox<T> extends StatefulWidget {
  const DSCombobox({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.state = DSInputState.normal,
    this.maxDropdownHeight = 260,
    this.emptyText = 'No results',
  });

  final List<DSComboboxItem<T>> items;
  final ValueChanged<DSComboboxItem<T>> onSelected;
  final T? value;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final DSInputState state;
  final double maxDropdownHeight;
  final String emptyText;

  @override
  State<DSCombobox<T>> createState() => _DSComboboxState<T>();
}

class _DSComboboxState<T> extends State<DSCombobox<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<DSComboboxItem<T>> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onSearch);
    _syncLabel();
  }

  void _syncLabel() {
    if (widget.value != null) {
      final match = widget.items.where((i) => i.value == widget.value).firstOrNull;
      if (match != null) _controller.text = match.label;
    }
  }

  @override
  void didUpdateWidget(DSCombobox<T> old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _syncLabel();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      _showOverlay();
    } else {
      _hideOverlay();
      _syncLabel();
    }
  }

  void _onSearch() {
    final q = _controller.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
    });
    _overlay?.markNeedsBuild();
  }

  void _showOverlay() {
    _hideOverlay();
    setState(() => _open = true);
    _overlay = OverlayEntry(builder: (_) => _DropdownOverlay(
      link: _layerLink,
      items: _filtered,
      emptyText: widget.emptyText,
      maxHeight: widget.maxDropdownHeight,
      onSelected: _select,
      selectedValue: widget.value,
    ));
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  void _select(DSComboboxItem<T> item) {
    widget.onSelected(item);
    _hideOverlay();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onSearch);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: DSTextInput(
        controller: _controller,
        focusNode: _focusNode,
        label: widget.label,
        isRequired: widget.isRequired,
        showInfoIcon: widget.showInfoIcon,
        infoTooltip: widget.infoTooltip,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        state: widget.state,
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
          child: Icon(
            _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: DSColors.textMuted,
          ),
        ),
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select combobox
// ---------------------------------------------------------------------------

/// A combobox with checkbox-style multi-select.
class DSMultiCombobox<T> extends StatefulWidget {
  const DSMultiCombobox({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.infoTooltip,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.state = DSInputState.normal,
    this.maxDropdownHeight = 260,
    this.emptyText = 'No results',
  });

  final List<DSComboboxItem<T>> items;
  final Set<T> values;
  final ValueChanged<Set<T>> onChanged;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final String? infoTooltip;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final DSInputState state;
  final double maxDropdownHeight;
  final String emptyText;

  @override
  State<DSMultiCombobox<T>> createState() => _DSMultiComboboxState<T>();
}

class _DSMultiComboboxState<T> extends State<DSMultiCombobox<T>> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<DSComboboxItem<T>> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _focusNode.addListener(_onFocusChange);
    _searchCtrl.addListener(_onSearch);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
    });
    _overlay?.markNeedsBuild();
  }

  void _showOverlay() {
    _hideOverlay();
    setState(() => _open = true);
    _overlay = OverlayEntry(builder: (_) => _MultiDropdownOverlay(
      link: _layerLink,
      items: _filtered,
      values: widget.values,
      emptyText: widget.emptyText,
      maxHeight: widget.maxDropdownHeight,
      onToggle: _toggle,
    ));
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  void _toggle(T value) {
    final next = Set<T>.from(widget.values);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    widget.onChanged(next);
    _overlay?.markNeedsBuild();
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.removeListener(_onFocusChange);
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: DSTextInput(
        controller: _searchCtrl,
        focusNode: _focusNode,
        label: widget.label,
        isRequired: widget.isRequired,
        showInfoIcon: widget.showInfoIcon,
        infoTooltip: widget.infoTooltip,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        state: widget.state,
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
          child: Icon(
            _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: DSColors.textMuted,
          ),
        ),
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared overlay widgets
// ---------------------------------------------------------------------------

class _DropdownOverlay<T> extends StatelessWidget {
  const _DropdownOverlay({
    required this.link,
    required this.items,
    required this.onSelected,
    required this.emptyText,
    required this.maxHeight,
    this.selectedValue,
  });

  final LayerLink link;
  final List<DSComboboxItem<T>> items;
  final ValueChanged<DSComboboxItem<T>> onSelected;
  final String emptyText;
  final double maxHeight;
  final T? selectedValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OverlayPositioned(
      link: link,
      maxHeight: maxHeight,
      isDark: isDark,
      child: items.isEmpty
          ? _EmptyItem(text: emptyText)
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = item.value == selectedValue;
                return _ComboItem(
                  item: item,
                  isDark: isDark,
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, size: 16, color: DSColors.brand)
                      : null,
                  onTap: () => onSelected(item),
                );
              },
            ),
    );
  }
}

class _MultiDropdownOverlay<T> extends StatelessWidget {
  const _MultiDropdownOverlay({
    required this.link,
    required this.items,
    required this.values,
    required this.onToggle,
    required this.emptyText,
    required this.maxHeight,
  });

  final LayerLink link;
  final List<DSComboboxItem<T>> items;
  final Set<T> values;
  final ValueChanged<T> onToggle;
  final String emptyText;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OverlayPositioned(
      link: link,
      maxHeight: maxHeight,
      isDark: isDark,
      child: items.isEmpty
          ? _EmptyItem(text: emptyText)
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isSelected = values.contains(item.value);
                return _ComboItem(
                  item: item,
                  isDark: isDark,
                  leading: _CheckMark(checked: isSelected),
                  onTap: () => onToggle(item.value),
                );
              },
            ),
    );
  }
}

class _OverlayPositioned extends StatelessWidget {
  const _OverlayPositioned({
    required this.link,
    required this.maxHeight,
    required this.isDark,
    required this.child,
  });

  final LayerLink link;
  final double maxHeight;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: link.leaderSize?.width ?? 240,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: Offset(0, (link.leaderSize?.height ?? 40) + 4),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: isDark ? DSColors.appCard : DSColors.white,
              borderRadius: DSRadius.borderMd,
              border: Border.all(
                color: isDark ? DSColors.appBorder : DSColors.gray200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: DSRadius.borderMd,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboItem<T> extends StatelessWidget {
  const _ComboItem({
    required this.item,
    required this.isDark,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final DSComboboxItem<T> item;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: DSSpacing.sm)],
            if (item.leading != null) ...[
              IconTheme(
                data: const IconThemeData(size: 18),
                child: item.leading!,
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: DSTypography.bodyMd.copyWith(
                      color: isDark ? DSColors.gray100 : DSColors.gray900,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: DSTypography.bodySm.copyWith(color: DSColors.textSecondary),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: DSSpacing.sm), trailing!],
          ],
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? DSColors.brand : Colors.transparent,
        borderRadius: DSRadius.borderXs,
        border: Border.all(
          color: checked ? DSColors.brand : DSColors.gray400,
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 11, color: DSColors.white)
          : null,
    );
  }
}

class _EmptyItem extends StatelessWidget {
  const _EmptyItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Text(
        text,
        style: DSTypography.bodySm.copyWith(color: DSColors.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}
