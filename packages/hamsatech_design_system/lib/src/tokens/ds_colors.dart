import 'package:flutter/material.dart';

class DSColors {
  DSColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color brand        = Color(0xFFF97316);
  static const Color brandHover   = Color(0xFFEA6C10);
  static const Color brandPressed = Color(0xFFD35F0A);
  static const Color brandMuted   = Color(0x1AF97316);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color black = Color(0xFF09090B);
  static const Color white = Color(0xFFFFFFFF);

  static const Color gray50  = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color gray950 = Color(0xFF030712);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error        = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color info         = Color(0xFF3B82F6);
  static const Color infoLight    = Color(0xFF60A5FA);

  // ── App surface colours (dark theme) ─────────────────────────────────────
  // These map 1:1 from the old AppColors.
  static const Color appBackground   = Color(0xFF0A0E1A);
  static const Color appSurface      = Color(0xFF131929);
  static const Color appCard         = Color(0xFF1A2235);
  static const Color appCardElevated = Color(0xFF1F2940);
  static const Color appBorder       = Color(0xFF2D3748);
  static const Color appDivider      = Color(0xFF1E293B);

  // ── App text colours (dark theme) ─────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF475569);
}
