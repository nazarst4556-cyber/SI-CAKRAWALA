import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.merahIndonesia,
      colorScheme: const ColorScheme.light(
        primary: AppColors.merahIndonesia,
        secondary: AppColors.tniGreenAccent,
        tertiary: AppColors.cyberCyan,
        error: AppColors.merahSoft,
        surface: AppColors.glassSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 3.0,
        ),
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.cyberCyan,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.exo2(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.exo2(
          fontSize: 12,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.shareTechMono(
          fontSize: 11,
          color: AppColors.cyberCyan,
          letterSpacing: 0.8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyberCyan, width: 2),
        ),
        labelStyle: GoogleFonts.exo2(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.exo2(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.merahIndonesia,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.5),
        ),
      ),
    );
  }

  // Keep dark theme reference for internal dashboard panels
  static ThemeData get darkTheme => lightTheme;
}
