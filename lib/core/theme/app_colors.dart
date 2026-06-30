import 'package:flutter/material.dart';

/// Central color palette for Chatify.
/// All theme files reference these constants so color changes are one-place edits.
abstract final class AppColors {
  // --- Brand ---
  static const Color primary = Color(0xFF6750A4); // Material 3 purple seed
  static const Color primaryLight = Color(0xFFEADDFF);
  static const Color primaryDark = Color(0xFF21005D);

  // --- Neutral ---
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  // --- Utility ---
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF386A20);
  static const Color online = Color(0xFF4CAF50);
  static const Color divider = Color(0xFFCAC4D0);
  static const Color dividerDark = Color(0xFF49454F);

  // --- Chat bubbles ---
  static const Color bubbleOutgoing = Color(0xFFEADDFF);
  static const Color bubbleIncoming = Color(0xFFF3EDF7);
  static const Color bubbleOutgoingDark = Color(0xFF4A4458);
  static const Color bubbleIncomingDark = Color(0xFF2B2930);
}
