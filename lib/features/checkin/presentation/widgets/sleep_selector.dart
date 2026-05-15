import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/daily_checkin_entity.dart';

class SleepSelector extends StatelessWidget {
  const SleepSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final SleepOption? selected;
  final ValueChanged<SleepOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SleepOption.values.asMap().entries.map((entry) {
        final i = entry.key;
        final option = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
            child: _SleepChip(
              option: option,
              isSelected: selected == option,
              onTap: () => onSelected(option),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SleepChip extends StatelessWidget {
  const _SleepChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final SleepOption option;
  final bool isSelected;
  final VoidCallback onTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _teal : DSColors.appCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _teal : DSColors.appBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          option.label,
          textAlign: TextAlign.center,
          style: DSTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : DSColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
