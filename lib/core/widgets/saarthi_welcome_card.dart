import 'package:flutter/material.dart';

class SaarthiWelcomeCard extends StatelessWidget {
  const SaarthiWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F7E8F).withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/logos/saarthi_krishna.png',
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      ),
    );
  }
}
