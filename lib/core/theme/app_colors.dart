import 'package:flutter/material.dart';

class AppColors {
  // ── Indonesian National Colors ──────────────────────────────────────────────
  static const Color merahIndonesia  = Color(0xFFCC0001);
  static const Color merahVibrant    = Color(0xFFE8001A);
  static const Color merahSoft       = Color(0xFFFF3D5A);
  static const Color merahNeon       = Color(0xFFFF2A37); // kept for legacy widget compat
  static const Color putihIndonesia  = Color(0xFFF8FAFC);

  // ── TNI AD Tactical Greens ──────────────────────────────────────────────────
  static const Color tniGreenDark    = Color(0xFF1A3A28);
  static const Color tniGreenMid     = Color(0xFF2D6A4F);
  static const Color tniGreenAccent  = Color(0xFF40916C);
  static const Color tniGreenLight   = Color(0xFF52B788);
  static const Color tniGreenNeon    = Color(0xFF1CB96B);

  // ── Cyber High-Tech Accents ─────────────────────────────────────────────────
  static const Color cyberCyan       = Color(0xFF00C6FF);
  static const Color cyberCyanDeep   = Color(0xFF0072FF);
  static const Color cyberBlue       = Color(0xFF4A90E2);
  static const Color cyberPurple     = Color(0xFF7B2FBE);
  static const Color goldInsignia    = Color(0xFFD4AF37);
  static const Color goldGlow        = Color(0x66D4AF37);
  static const Color warningAmber    = Color(0xFFFF8F00);

  // ── Light Theme Backgrounds ─────────────────────────────────────────────────
  static const Color background      = Color(0xFFF0F4F8); // crisp cool-white
  static const Color backgroundCard  = Color(0xFFFFFFFF);
  static const Color backgroundShade = Color(0xFFE2EAF1);

  // ── Liquid Glass Surfaces ───────────────────────────────────────────────────
  static const Color glassSurface      = Color(0xCCFFFFFF); // white glass
  static const Color glassSurfaceDeep  = Color(0xB3E8F4FF);
  static const Color glassBorder       = Color(0x8000C6FF);
  static const Color glassBorderRed    = Color(0x99CC0001);
  static const Color glassBorderGreen  = Color(0x9940916C);
  static const Color glassGlow         = Color(0x3300C6FF);
  static const Color glassGlowRed      = Color(0x33CC0001);

  // ── Text Colors ─────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0F1B2D);
  static const Color textSecondary  = Color(0xFF2D4A6E);
  static const Color textMuted      = Color(0xFF64748B);
  static const Color textOnDark     = Color(0xFFF8FAFC);

  // ── Gradient Presets ────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8001A),
      Color(0xFFCC0001),
      Color(0xFF8B0000),
      Color(0xFF1A3A28),
      Color(0xFF2D6A4F),
    ],
    stops: [0.0, 0.25, 0.45, 0.70, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEEFFFFFF), Color(0xCCE8F4FF)],
  );

  static const LinearGradient cyberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1CB96B), Color(0xFF40916C)],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8001A), Color(0xFF8B0000)],
  );
}
