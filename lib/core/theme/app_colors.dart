import 'package:flutter/material.dart';

/// Central color palette for Chatify.
///
/// Light palette: vibrant purple primary, coral secondary, turquoise accent.
/// Dark palette: deeper variants of the same hues on a dark navy background.
///
/// All theme files reference these constants — color changes are one-place edits.
abstract final class AppColors {
  // ── Light theme ──────────────────────────────────────────────────────────

  /// Vibrant purple — primary actions, FAB, filled buttons.
  static const Color primary = Color(0xFF6C63FF);

  /// Coral orange — secondary actions, accents, highlights.
  static const Color secondary = Color(0xFFFF7A59);

  /// Turquoise — accent color, online indicator, success states.
  static const Color accent = Color(0xFF2DD4BF);

  /// Soft lavender — light tint of primary used for chips, input fills.
  static const Color primaryLight = Color(0xFFEDE9FF);

  /// Deep indigo — used for gradient headers.
  static const Color primaryDark = Color(0xFF3730A3);

  /// App background (light).
  static const Color background = Color(0xFFF4F7FC);

  /// Card / sheet surface (light).
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text (light).
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary / muted text (light).
  static const Color textSecondary = Color(0xFF64748B);

  // ── Dark theme ───────────────────────────────────────────────────────────

  /// App background (dark) — deep navy.
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Card / sheet surface (dark).
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Elevated card (dark).
  static const Color cardDark = Color(0xFF273549);

  /// Primary (dark) — slightly lighter purple for readability on dark bg.
  static const Color primaryDarkMode = Color(0xFF8B7CFF);

  /// Secondary (dark) — soft coral.
  static const Color secondaryDarkMode = Color(0xFFFF9B71);

  /// Accent (dark) — teal.
  static const Color accentDarkMode = Color(0xFF4FD1C5);

  /// Primary text (dark).
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary / muted text (dark).
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  // ── Shared semantic colors ───────────────────────────────────────────────

  /// Error red.
  static const Color error = Color(0xFFEF4444);

  /// Success green / online indicator.
  static const Color online = Color(0xFF22C55E);

  /// Divider (light).
  static const Color divider = Color(0xFFE2E8F0);

  /// Divider (dark).
  static const Color dividerDark = Color(0xFF334155);

  // ── Chat bubble colors ───────────────────────────────────────────────────

  /// Outgoing bubble (light) — primary purple with white text.
  static const Color bubbleOutgoing = Color(0xFF6C63FF);

  /// Incoming bubble (light) — soft lavender.
  static const Color bubbleIncoming = Color(0xFFEDE9FF);

  /// Outgoing bubble (dark) — slightly muted purple.
  static const Color bubbleOutgoingDark = Color(0xFF6C63FF);

  /// Incoming bubble (dark) — dark card surface.
  static const Color bubbleIncomingDark = Color(0xFF273549);
}
