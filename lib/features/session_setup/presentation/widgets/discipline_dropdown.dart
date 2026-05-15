import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class DisciplineDropdown extends StatelessWidget {
  const DisciplineDropdown({
    required this.disciplines,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> disciplines;
  final String selected; // empty = no selection yet
  final ValueChanged<String> onSelected;

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DSColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DisciplinePickerSheet(
        disciplines: disciplines,
        selected: selected,
        onSelected: (d) {
          onSelected(d);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selected.isNotEmpty;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: DSColors.appCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DSColors.appBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? selected : 'Select discipline',
                style: DSTypography.bodyMd.copyWith(
                  color: hasValue
                      ? DSColors.textPrimary
                      : DSColors.textMuted,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: DSColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplinePickerSheet extends StatelessWidget {
  const _DisciplinePickerSheet({
    required this.disciplines,
    required this.selected,
    required this.onSelected,
  });

  final List<String> disciplines;
  final String selected;
  final ValueChanged<String> onSelected;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: DSColors.appBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Select Discipline',
                style: DSTypography.headingMd.copyWith(
                  color: DSColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: DSColors.appBorder, height: 1),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: disciplines.length,
            separatorBuilder: (_, __) =>
                const Divider(color: DSColors.appDivider, height: 1),
            itemBuilder: (_, i) {
              final d = disciplines[i];
              final isSelected = d == selected;
              return ListTile(
                dense: true,
                title: Text(
                  d,
                  style: DSTypography.bodyMd.copyWith(
                    color: isSelected ? _teal : DSColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: _teal, size: 18)
                    : null,
                onTap: () => onSelected(d),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
