import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/session_setup_entity.dart';

class SessionTypeSelector extends StatelessWidget {
  const SessionTypeSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final SessionType? selected;
  final ValueChanged<SessionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SessionType.values.asMap().entries.map((entry) {
        final i = entry.key;
        final type = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
            child: _SessionTypeChip(
              type: type,
              isSelected: type == selected,
              onTap: () => onSelected(type),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SessionTypeChip extends StatelessWidget {
  const _SessionTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final SessionType type;
  final bool isSelected;
  final VoidCallback onTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
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
          type.label,
          style: DSTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : DSColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
