import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 light theme for Chatify.
///
/// Palette: vibrant purple primary · coral secondary · turquoise accent
/// Background: #F4F7FC  Surface: White  Text: #1E293B / #64748B
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,

  // ── Color scheme ─────────────────────────────────────────────────────────
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    // Primary — vibrant purple
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    // Secondary — coral orange
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE4D9),
    onSecondaryContainer: Color(0xFF7A2B10),
    // Tertiary — turquoise accent
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCCFBF1),
    onTertiaryContainer: Color(0xFF0F4A44),
    // Surface
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.primaryLight,
    onSurfaceVariant: AppColors.textSecondary,
    // Background
    // ignore: deprecated_member_use
    background: AppColors.background,
    // ignore: deprecated_member_use
    onBackground: AppColors.textPrimary,
    // Outline
    outline: AppColors.divider,
    outlineVariant: Color(0xFFCBD5E1),
    // Error
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFEDED),
    onErrorContainer: Color(0xFF7A1C1C),
    // Inverse
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryDarkMode,
    // Shadow
    shadow: Color(0x1A000000),
    scrim: Color(0x33000000),
  ),

  // ── Scaffold background ───────────────────────────────────────────────────
  scaffoldBackgroundColor: AppColors.background,

  // ── AppBar ────────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    shadowColor: Color(0x14000000),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: AppColors.primary),
  ),

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryLight,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primary);
      }
      return const IconThemeData(color: AppColors.textSecondary);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      }
      return const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
    }),
    elevation: 2,
    shadowColor: Color(0x1A6C63FF),
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
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // ── Input decoration ──────────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
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
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    prefixIconColor: AppColors.primary,
    suffixIconColor: AppColors.textSecondary,
  ),

  // ── Card ──────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: const Color(0x0A6C63FF),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.divider, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),

  // ── List tile ─────────────────────────────────────────────────────────────
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.primary,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    subtitleTextStyle: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  ),

  // ── Chip ──────────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primaryLight,
    labelStyle:
        const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
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
  dividerColor: AppColors.divider,
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    space: 1,
    thickness: 1,
  ),

  // ── Dialog ────────────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
  ),

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.divider,
  ),

  // ── SnackBar ──────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    actionTextColor: AppColors.accent,
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
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return AppColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.divider;
    }),
  ),

  // ── Badge ─────────────────────────────────────────────────────────────────
  badgeTheme: const BadgeThemeData(
    backgroundColor: AppColors.secondary,
    textColor: Colors.white,
    smallSize: 8,
  ),

  // ── Typography ────────────────────────────────────────────────────────────
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 57,
        fontWeight: FontWeight.w700),
    displayMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 45,
        fontWeight: FontWeight.w700),
    displaySmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700),
    titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(
        color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(
        color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400),
    labelLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600),
    labelMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500),
  ),
);
