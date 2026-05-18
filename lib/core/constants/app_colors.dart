import 'package:flutter/material.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';

// Compatibility shim: maps legacy AppColors.* names to the Astra DSColors palette.
class AppColors {
  AppColors._();

  static const Color primary        = DSColors.brand;
  static const Color background     = DSColors.appBackground;
  static const Color surface        = DSColors.appSurface;
  static const Color card           = DSColors.appCard;
  static const Color border         = DSColors.appBorder;
  static const Color divider        = DSColors.appDivider;

  static const Color textPrimary    = DSColors.textPrimary;
  static const Color textSecondary  = DSColors.textSecondary;
  static const Color textMuted      = DSColors.textMuted;

  static const Color error          = DSColors.error;
  static const Color success        = DSColors.success;
  static const Color warning        = DSColors.warning;

  static const Color readyGreen     = DSColors.success;
  static const Color moderateAmber  = DSColors.warning;
  static const Color needsRecoveryRed = DSColors.error;

  // ignore: unused_field
  static const Color _unused = Colors.transparent;
}
