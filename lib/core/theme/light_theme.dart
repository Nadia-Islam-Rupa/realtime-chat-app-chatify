import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 light theme for Chatify — Lavender/white variant.
///
/// All text uses dark violet (#1E1533) on light backgrounds.
/// Nav bar uses white surface with muted dark-violet unselected states.
/// Switch uses a solid visible track that clearly shows on/off.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,

  // ── Color scheme ─────────────────────────────────────────────────────────
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFEDE9FF),
    onPrimaryContainer: Color(0xFF1E1533),
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE4D9),
    onSecondaryContainer: Color(0xFF7A2B10),
    tertiary: Color(0xFF4FD1C5),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCFBF1),
    onTertiaryContainer: Color(0xFF0F4A44),
    // Surface — white, text on surface is dark
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightText, // black
    surfaceContainerHighest: AppColors.lightCard,
    onSurfaceVariant: AppColors.lightTextSec, // dark gray
    // Background
    // ignore: deprecated_member_use
    background: AppColors.lightBg,
    // ignore: deprecated_member_use
    onBackground: AppColors.lightText,
    // Outline
    outline: AppColors.lightDivider,
    outlineVariant: Color(0xFFD8D0F0),
    // Error
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFEDED),
    onErrorContainer: Color(0xFF7A1C1C),
    // Inverse
    inverseSurface: Color(0xFF1E1533),
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryLight,
    shadow: Color(0x1A000000),
    scrim: Color(0x33000000),
  ),

  // ── Scaffold ─────────────────────────────────────────────────────────────
  scaffoldBackgroundColor: AppColors.lightBg,

  // ── AppBar ────────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.lightSurface, // white
    foregroundColor: AppColors.lightText,
    surfaceTintColor: Colors.transparent,
    shadowColor: Color(0x14000000),
    titleTextStyle: TextStyle(
      color: AppColors.lightText, // dark violet title
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: AppColors.primary),
  ),

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  // White background, dark-violet unselected icons/labels,
  // violet indicator pill for the selected tab.
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.lightSurface, // white
    indicatorColor: Color(0xFFEDE9FF), // soft lavender pill
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primary);
      }
      // Unselected: clearly visible dark-violet on white
      return const IconThemeData(color: AppColors.lightTextSec);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      }
      // Unselected: muted gray-violet, readable on white
      return const TextStyle(
        color: AppColors.lightTextSec,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
    }),
    elevation: 4,
    shadowColor: Color(0x1A8B5CF6),
    surfaceTintColor: Colors.transparent,
  ),

  // ── Elevated button ───────────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // ── Filled button ─────────────────────────────────────────────────────────
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // ── Outlined button ───────────────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // ── Text button ───────────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  // ── Input decoration ──────────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.lightDivider, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.lightDivider, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: const TextStyle(color: AppColors.lightTextSec, fontSize: 14),
    labelStyle: const TextStyle(color: AppColors.lightTextSec, fontSize: 14),
    prefixIconColor: AppColors.primary,
    suffixIconColor: AppColors.lightTextSec,
  ),

  // ── Card ──────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.lightDivider, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),

  // ── List tile ─────────────────────────────────────────────────────────────
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.primary,
    titleTextStyle: TextStyle(
      color: AppColors.lightText, // dark on light
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    subtitleTextStyle: TextStyle(
      color: AppColors.lightTextSec, // muted on light
      fontSize: 13,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  ),

  // ── Chip ──────────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFEDE9FF),
    labelStyle: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
    ),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  // ── FAB ───────────────────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: CircleBorder(),
  ),

  // ── Divider ───────────────────────────────────────────────────────────────
  dividerColor: AppColors.lightDivider,
  dividerTheme: const DividerThemeData(
    color: AppColors.lightDivider,
    space: 1,
    thickness: 1,
  ),

  // ── Dialog ────────────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: const TextStyle(
      color: AppColors.lightText,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: const TextStyle(
      color: AppColors.lightTextSec,
      fontSize: 14,
    ),
  ),

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.lightDivider,
  ),

  // ── SnackBar ──────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.lightText, // dark violet bg
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 4,
  ),

  // ── Progress indicator ────────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearMinHeight: 4,
  ),

  // ── Switch ────────────────────────────────────────────────────────────────
  // Inactive: light gray track + dark thumb — clearly shows OFF state on white.
  // Active: violet track + white thumb — clearly shows ON state.
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return const Color(0xFF9E9E9E); // gray thumb when off
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return const Color(0xFFE0E0E0); // light gray track when off
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.transparent;
      return const Color(0xFFBDBDBD);
    }),
  ),

  // ── Badge ─────────────────────────────────────────────────────────────────
  badgeTheme: const BadgeThemeData(
    backgroundColor: AppColors.secondary,
    textColor: Colors.white,
    smallSize: 8,
  ),

  // ── Typography — ALL dark violet on light background ─────────────────────
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: 57,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: 45,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      color: AppColors.lightText,
      fontSize: 36,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      color: AppColors.lightText,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: AppColors.lightText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: AppColors.lightTextSec,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: AppColors.lightTextSec,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: AppColors.lightTextSec,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  ),
);
