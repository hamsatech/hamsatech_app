import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class SaveCheckinButton extends StatelessWidget {
  const SaveCheckinButton({
    required this.onSave,
    this.canSave = true,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onSave;
  final bool canSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.appBackground,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (canSave && !isLoading) ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: DSColors.terracotta,
              disabledBackgroundColor:
                  DSColors.terracotta.withValues(alpha: 0.45),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Check-in and Continue',
                    style: DSTypography.headingMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
