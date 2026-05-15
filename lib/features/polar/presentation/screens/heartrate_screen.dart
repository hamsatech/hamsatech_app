import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FDFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 88, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _HeartMark(),
                    SizedBox(height: 18),
                    _IntroCopy(),
                    SizedBox(height: 34),
                    _InstructionCard(
                      icon: Icons.bluetooth_rounded,
                      iconColor: Color(0xFF2F7E8F),
                      iconBackground: Color(0xFFEAF7FA),
                      label: 'Sit comfortably',
                    ),
                    SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.notifications_none_rounded,
                      iconColor: Color(0xFFF59E0B),
                      iconBackground: Color(0xFFFFF7ED),
                      label: 'Breathe normally',
                    ),
                    SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.mic_none_rounded,
                      iconColor: Color(0xFF22C55E),
                      iconBackground: Color(0xFFF0FDF4),
                      label: 'Don\'t move',
                    ),
                  ],
                ),
              ),
            ),
            _BaselineFooter(
              label: 'Start - 60 sec',
              onPressed: () => context.go('/baseline'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let’s measure your\nbaseline',
          style: DSTypography.onboardingCaption.copyWith(
            color: const Color(0xFF000F12),
            fontSize: 29,
            fontWeight: FontWeight.w700,
            height: 1.18,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We need to know your resting heart rate. This\n'
          'helps us tell when you\'re calm vs. stressed\n'
          'during a session.',
          style: DSTypography.bodyLarge.copyWith(
            color: DSColors.textPrimary,
            fontSize: 16,
            height: 1.38,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _HeartMark extends StatelessWidget {
  const _HeartMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4A9BC)),
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: Color(0xFFEF4444),
        size: 34,
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: DSColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DSColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: DSTypography.bodyLarge.copyWith(
                color: const Color(0xFF000F12),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BaselineFooter extends StatelessWidget {
  const _BaselineFooter({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: const BoxDecoration(
        color: DSColors.white,
        border: Border(top: BorderSide(color: DSColors.gray200)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DSColors.terracotta,
            foregroundColor: DSColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            label,
            style: DSTypography.headingMd.copyWith(
              color: DSColors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
