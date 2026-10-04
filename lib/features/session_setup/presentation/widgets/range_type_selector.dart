import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/session_setup_entity.dart';

class RangeTypeSelector extends StatelessWidget {
  const RangeTypeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final RangeType selected;
  final ValueChanged<RangeType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DSColors.textPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: RangeType.values.map((type) {
          final isSelected = type == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? DSColors.gray700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  type.label,
                  style: DSTypography.labelMd.copyWith(
                    color: isSelected ? DSColors.gray100 : DSColors.gray400,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
