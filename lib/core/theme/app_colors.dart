import 'package:flutter/material.dart';

/// Midnight Violet design system — single source of truth for all colors,
/// gradients, shadows, and opacities used across Chatify.
abstract final class AppColors {
  // ── Core background gradient ──────────────────────────────────────────────
  static const Color bgDeep   = Color(0xFF0F0B1E); // darkest navy
  static const Color bgMid    = Color(0xFF1A1035); // deep violet-navy
  static const Color bgLight  = Color(0xFF2D1B4E); // purple-tinted

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDeep, bgMid, bgLight],
  );

  // ── Primary accent — vibrant violet/purple ────────────────────────────────
  static const Color primary       = Color(0xFF8B5CF6);
  static const Color primaryLight  = Color(0xFFA855F7);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Secondary accent — pink/magenta ──────────────────────────────────────
  static const Color secondary = Color(0xFFEC4899);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Avatar/ring gradient ──────────────────────────────────────────────────
  static const LinearGradient avatarRingGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glass surface ─────────────────────────────────────────────────────────
  /// Semi-transparent dark purple card/surface
  static const Color glass       = Color(0xD91E1533); // 85% opacity
  static const Color glassBorder = Color(0x338B5CF6); // violet border at 20%
  static const Color glassDark   = Color(0xBF120E24); // 75% opacity darker

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF5F3FF); // white-ish
  static const Color textSecondary = Color(0xFFA78BC7); // muted lavender-gray
  static const Color textMuted     = Color(0xFF6B5B8A); // dimmer

  // ── Online / success ─────────────────────────────────────────────────────
  static const Color online = Color(0xFF4ADE80); // neon green

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);

  // ── Divider ───────────────────────────────────────────────────────────────
  static const Color divider = Color(0x2A8B5CF6); // violet tint

  // ── Chat bubbles ──────────────────────────────────────────────────────────
  /// Outgoing: gradient violet → pink
  static const LinearGradient sentBubbleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Incoming: glassy dark surface
  static const Color receivedBubble       = Color(0xCC1E1533);
  static const Color receivedBubbleBorder = Color(0x33A78BC7);

  // ── Glow shadows ─────────────────────────────────────────────────────────
  static List<BoxShadow> glowShadow({
    Color color = const Color(0xFF8B5CF6),
    double blurRadius = 20,
    double spreadRadius = 0,
  }) => [
    BoxShadow(
      color: color.withAlpha(60),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    ),
  ];

  static List<BoxShadow> avatarGlow = glowShadow(blurRadius: 16, spreadRadius: 1);

  static List<BoxShadow> fabGlow = [
    BoxShadow(
      color: primary.withAlpha(80),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  // ── Light mode variant (lavender-white) ───────────────────────────────────
  static const Color lightBg       = Color(0xFFF3F0FF);
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFF0EBFF);
  static const Color lightText     = Color(0xFF1E1533);
  static const Color lightTextSec  = Color(0xFF6B5B8A);
  static const Color lightDivider  = Color(0xFFDDD6FE);

  // ── Brightness-aware helpers ──────────────────────────────────────────────

  /// Returns the dark gradient when the theme is dark, or a soft light-mode
  /// gradient (lavender to white) when the theme is light.
  /// Use this instead of [backgroundGradient] inside widget build() methods.
  static LinearGradient backgroundGradientFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return backgroundGradient;
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [lightBg, lightSurface],
    );
  }

  // ── Legacy compatibility aliases ─────────────────────────────────────────
  /// kept so existing references to AppColors.online still compile
  static const Color primaryDark     = Color(0xFF3730A3);
  static const Color primaryLightOld = Color(0xFFEDE9FF);
  static const Color surface         = glass;
  static const Color surfaceDark     = Color(0xFF1E1533);
  static const Color background      = lightBg;
  static const Color backgroundDark  = bgDeep;
  static const Color cardDark        = glass;
  static const Color primaryDarkMode = primary;
  static const Color secondaryDarkMode = secondary;
  static const Color accentDarkMode  = Color(0xFF4FD1C5);
  static const Color textPrim        = textPrimary;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;
  static const Color dividerDark     = divider;
  static const Color bubbleOutgoing  = primary;
  static const Color bubbleIncoming  = receivedBubble;
  static const Color bubbleOutgoingDark = primary;
  static const Color bubbleIncomingDark = receivedBubble;
  static const Color accent          = Color(0xFF4FD1C5);
  static const Color error_          = error;
}
