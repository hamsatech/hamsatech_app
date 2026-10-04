import 'package:flutter/material.dart';

class SaarthiAvatar extends StatelessWidget {
  const SaarthiAvatar({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderWidth = (size * 0.035).clamp(1.5, 3.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F7E8F).withValues(alpha: 0.38),
            blurRadius: size * 0.22,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logos/saarthi_avatar.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
