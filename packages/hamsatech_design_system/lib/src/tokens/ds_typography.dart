import 'package:flutter/material.dart';
import 'ds_colors.dart';

class DSTypography {
  DSTypography._();

  // ── Generic scale — Inter (colour-free, compose with .copyWith) ───────────
  // Use these when you need a specific size/weight but want to control color
  // at call site (e.g., white text on dark card).

  static TextStyle get displayLg => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMd => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.3,
      );

  static TextStyle get displaySm => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get headingXl => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get headingLg => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: -0.2,
      );

  static TextStyle get headingMd => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get headingSm => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get headingXs => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get bodyLg => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0,
      );

  static TextStyle get bodyMd => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0,
      );

  static TextStyle get bodySm => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get bodyXs => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0,
      );

  static TextStyle get labelLg => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0,
      );

  static TextStyle get labelMd => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get labelSm => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0,
      );

  static TextStyle get labelXs => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0,
      );

  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'monospace',
    height: 1.5,
  );

  // ── App text styles — Inter (with baked-in colours) ───────────────────────
  // Use these for most UI text. Override via .copyWith() only when needed.

  static TextStyle get displayLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get headingLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get headingMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        height: 1.35,
        letterSpacing: -0.2,
      );

  static TextStyle get headingSmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DSColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DSColors.textPrimary,
        height: 1.55,
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DSColors.textPrimary,
        height: 1.55,
        letterSpacing: 0,
      );

  // Secondary-weight body — subtitles, descriptions
  static TextStyle get bodySmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DSColors.textSecondary,
        height: 1.5,
        letterSpacing: 0,
      );

  // Button / prominent action label
  static TextStyle get labelLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: DSColors.textPrimary,
        height: 1.3,
        letterSpacing: 0,
      );

  // Form labels, tag text
  static TextStyle get labelMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DSColors.textSecondary,
        height: 1.4,
        letterSpacing: 0,
      );

  // Metadata, timestamps, step indicators
  static TextStyle get caption => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: DSColors.textMuted,
        height: 1.4,
        letterSpacing: 0,
      );

  // Score / metric display number
  static TextStyle get scoreDisplay => TextStyle(
        fontFamily: 'Inter',
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: DSColors.textPrimary,
        height: 1.05,
        letterSpacing: -1.5,
      );

  static TextStyle get metricValue => TextStyle(
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      );

  // Input hint / placeholder
  static TextStyle get inputHint => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DSColors.textPlaceholder,
        height: 1.5,
        letterSpacing: 0,
      );

  // Form field label (above input)
  static TextStyle get inputLabel => TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DSColors.textSecondary,
        height: 1.4,
        letterSpacing: 0,
      );

  // ── Onboarding / Welcome screen ───────────────────────────────────────────

  static TextStyle get onboardingHeader => TextStyle(
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: DSColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.15,
      );

  static TextStyle get onboardingSubheader => TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DSColors.textSecondary,
        letterSpacing: 0,
        height: 1.4,
      );

  // PT Serif — editorial slide captions
  static const TextStyle onboardingCaption = TextStyle(
        fontFamily: 'PT Serif',
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: 0,
      );
}
