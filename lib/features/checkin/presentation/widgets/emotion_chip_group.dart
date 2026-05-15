import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/daily_checkin_entity.dart';

class EmotionChipGroup extends StatelessWidget {
  const EmotionChipGroup({
    required this.selected,
    required this.onToggled,
    super.key,
  });

  final List<EmotionTag> selected;
  final ValueChanged<EmotionTag> onToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EmotionTag.values
          .map((tag) => _EmotionChip(
                tag: tag,
                isSelected: selected.contains(tag),
                onTap: () => onToggled(tag),
              ))
          .toList(),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  final EmotionTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _teal : DSColors.appCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _teal : DSColors.appBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.label,
              style: DSTypography.labelSm.copyWith(
                color: isSelected ? Colors.white : DSColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onTap,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
