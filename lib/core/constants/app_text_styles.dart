import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:flutter/material.dart';

// Compatibility shim: maps legacy AppTextStyles.* to DSTypography equivalents.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => DSTypography.displayLarge;
  static TextStyle get displayMedium => DSTypography.displayMedium;
  static TextStyle get headingLarge => DSTypography.headingLarge;
  static TextStyle get headingMedium => DSTypography.headingMedium;
  static TextStyle get headingSmall => DSTypography.headingSmall;
  static TextStyle get bodyLarge => DSTypography.bodyLarge;
  static TextStyle get bodyMedium => DSTypography.bodyMedium;
  static TextStyle get bodySmall => DSTypography.bodySmall;
  static TextStyle get labelLarge => DSTypography.labelLarge;
  static TextStyle get labelMedium => DSTypography.labelMedium;
  static TextStyle get caption => DSTypography.caption;
}
