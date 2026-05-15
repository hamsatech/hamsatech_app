import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class BeginRitualButton extends StatelessWidget {
  const BeginRitualButton({
    required this.onTap,
    this.canBegin = true,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool canBegin;
  final bool isLoading;

  static const _teal = Color(0xFF2F7E8F);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.appBackground,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: (canBegin && !isLoading) ? onTap : null,
          child: AnimatedOpacity(
            opacity: canBegin ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Begin Ritual',
                          style: DSTypography.headingMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
