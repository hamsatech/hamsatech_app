import 'package:flutter/material.dart';

class RitualHeader extends StatelessWidget {
  const RitualHeader({
    required this.title,
    required this.onSkip,
    super.key,
  });

  final String title;
  final VoidCallback onSkip;

  static const _textDark = Color(0xFF2A5562);
  static const _textMuted = Color(0xFF7FB8C4);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
        ),
        GestureDetector(
          onTap: onSkip,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.skip_next_rounded,
                  size: 16,
                  color: _textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
