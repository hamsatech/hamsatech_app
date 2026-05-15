import 'package:flutter/material.dart';

class DSColors {
  DSColors._();

  // ── Brand — primary CTA (#2F7E8F) ────────────────────────────────────────
  static const Color brand        = Color(0xFF2F7E8F);
  static const Color brandHover   = Color(0xFF26707F);
  static const Color brandPressed = Color(0xFF1D6070);
  static const Color brandMuted   = Color(0x1A2F7E8F);

  // ── Accent — Terracotta (legacy name kept; resolves to brand palette) ────
  static const Color terracotta        = Color(0xFF2F7E8F);
  static const Color terracottaHover   = Color(0xFF26707F);
  static const Color terracottaPressed = Color(0xFF1D6070);
  static const Color terracottaMuted   = Color(0x1A2F7E8F);

  // ── Accent — Coral (logo heart) ───────────────────────────────────────────
  static const Color coral        = Color(0xFFF87171);
  static const Color coralMuted   = Color(0x1AF87171);

  // ── Accent — Navy (logo hands) ────────────────────────────────────────────
  static const Color navy         = Color(0xFF0F2A47);
  static const Color navyLight    = Color(0xFF1A3D60);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000F12);
  static const Color white = Color(0xFFFFFFFF);

  static const Color gray50  = Color(0xFFF0FAFC);
  static const Color gray100 = Color(0xFFE2F4F7);
  static const Color gray200 = Color(0xFFCAE8EE);
  static const Color gray300 = Color(0xFFB0D8E0);
  static const Color gray400 = Color(0xFF7FB8C4);
  static const Color gray500 = Color(0xFF4D8F9C);
  static const Color gray600 = Color(0xFF3A7080);
  static const Color gray700 = Color(0xFF2A5562);
  static const Color gray800 = Color(0xFF1A3840);
  static const Color gray900 = Color(0xFF0A1C20);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error        = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFFEDED);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color info         = Color(0xFF2F7E8F);
  static const Color infoLight    = Color(0xFF5BADBC);

  // ── App surface colours ───────────────────────────────────────────────────
  static const Color appBackground   = Color(0xFFF5FDFF);
  static const Color appSurface      = Color(0xFFF5FDFF);
  static const Color appCard         = Color(0xFFFFFFFF);
  static const Color appCardElevated = Color(0xFFEAF7FA);
  static const Color appBorder       = Color(0xFFCAE8EE);
  static const Color appDivider      = Color(0xFFE2F4F7);

  // ── App text colours ──────────────────────────────────────────────────────
  // Opacity-based variants of textPrimary so they always blend naturally
  // against any background without teal cast.
  static const Color textPrimary    = Color(0xFF000F12);   // 100 %
  static const Color textSecondary  = Color(0x99000F12);   //  60 %
  static const Color textMuted      = Color(0x66000F12);   //  40 %
  static const Color textDisabled   = Color(0x40000F12);   //  25 %
  static const Color textPlaceholder = Color(0x4D000F12);  //  30 %
}
