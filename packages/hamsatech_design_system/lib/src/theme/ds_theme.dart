import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_typography.dart';

class DSTheme {
  DSTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DSColors.appBackground,
      colorScheme: const ColorScheme.dark(
        primary: DSColors.brand,
        secondary: DSColors.success,
        surface: DSColors.appSurface,
        error: DSColors.error,
        onPrimary: DSColors.white,
        onSecondary: DSColors.white,
        onSurface: DSColors.textPrimary,
        onError: DSColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DSColors.appBackground,
        foregroundColor: DSColors.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: DSTypography.headingMedium,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: DSColors.appCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.appCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.appBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.appBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DSColors.error),
        ),
        labelStyle: const TextStyle(color: DSColors.textSecondary),
        hintStyle: const TextStyle(color: DSColors.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DSColors.brand,
          foregroundColor: DSColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DSTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DSColors.brand,
          side: const BorderSide(color: DSColors.brand),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DSTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DSColors.brand,
          textStyle: DSTypography.labelLarge,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DSColors.appSurface,
        selectedItemColor: DSColors.brand,
        unselectedItemColor: DSColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      dividerTheme: const DividerThemeData(
        color: DSColors.appDivider,
        thickness: 1,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: DSColors.brand,
        inactiveTrackColor: DSColors.appBorder,
        thumbColor: DSColors.brand,
        overlayColor: DSColors.brandMuted,
        valueIndicatorColor: DSColors.brand,
        valueIndicatorTextStyle:
            const TextStyle(color: DSColors.white, fontSize: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: DSTypography.displayLarge,
        displayMedium: DSTypography.displayMedium,
        headlineLarge: DSTypography.headingLarge,
        headlineMedium: DSTypography.headingMedium,
        headlineSmall: DSTypography.headingSmall,
        bodyLarge: DSTypography.bodyLarge,
        bodyMedium: DSTypography.bodyMedium,
        bodySmall: DSTypography.bodySmall,
        labelLarge: DSTypography.labelLarge,
        labelMedium: DSTypography.labelMedium,
      ),
    );
  }
}
