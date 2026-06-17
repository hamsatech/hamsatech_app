import 'package:flutter/material.dart';

import '../../domain/entities/session_mood.dart';

class EmotionSelector extends StatelessWidget {
  const EmotionSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final SessionMood? selected;
  final ValueChanged<SessionMood> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SessionMood.values.map((mood) {
        final isSelected = selected == mood;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(mood),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF2F7E8F) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF2F7E8F)
                          : const Color(0xFF4D8F9C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
