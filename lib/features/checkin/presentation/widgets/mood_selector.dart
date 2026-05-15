import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import '../../domain/entities/daily_checkin_entity.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final MoodOption? selected;
  final ValueChanged<MoodOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MoodOption.values.asMap().entries.map((entry) {
        final i = entry.key;
        final mood = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
            child: _MoodTile(
              mood: mood,
              isSelected: selected == mood,
              onTap: () => onSelected(mood),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? _teal : DSColors.appCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _teal : DSColors.appBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: DSTypography.bodyXs.copyWith(
                color: isSelected ? Colors.white : DSColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
