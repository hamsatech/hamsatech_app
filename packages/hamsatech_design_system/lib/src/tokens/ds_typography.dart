import 'package:flutter/material.dart';
import 'ds_colors.dart';

class DSTypography {
  DSTypography._();

  // ── Generic scale (colour-free, compose with theme) ───────────────────────

  static const TextStyle displayLg = TextStyle(fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5);
  static const TextStyle displayMd = TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.3);
  static const TextStyle displaySm = TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.2);

  static const TextStyle headingXl = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle headingLg = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.35);
  static const TextStyle headingMd = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle headingSm = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle headingXs = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4);

  static const TextStyle bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodyMd = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySm = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyXs = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);

  static const TextStyle labelLg = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelMd = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelSm = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3);
  static const TextStyle labelXs = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3);

  static const TextStyle mono = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontFamily: 'monospace', height: 1.5);

  // ── App text styles (match legacy AppTextStyles exactly) ─────────────────
  // These carry explicit colours so they drop in as 1-to-1 replacements.

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: DSColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: DSColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: DSColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: DSColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DSColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DSColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DSColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DSColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DSColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DSColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: DSColors.textMuted,
    letterSpacing: 0.2,
  );

  static const TextStyle scoreDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: DSColors.textPrimary,
    letterSpacing: -1,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: DSColors.textPrimary,
    letterSpacing: -0.5,
  );
}
