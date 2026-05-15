import 'package:flutter/material.dart';

class BodyScanDots extends StatelessWidget {
  const BodyScanDots({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  static const _active = Color(0xFF2F7E8F);
  static const _inactive = Color(0xFFB0D8E0); // gray-300

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isActive ? 10 : 7,
          height: isActive ? 10 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          decoration: BoxDecoration(
            color: i <= currentIndex ? _active : _inactive,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
