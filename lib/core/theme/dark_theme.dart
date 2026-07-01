import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 dark theme for Chatify.
///
/// Background: #0F172A  Surface: #1E293B  Card: #273549
/// Primary: #8B7CFF  Secondary: #FF9B71  Accent: #4FD1C5
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,

  // ── Color scheme ─────────────────────────────────────────────────────────
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    // Primary — soft purple for dark bg
    primary: AppColors.primaryDarkMode,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF3730A3),
    onPrimaryContainer: Color(0xFFEDE9FF),
    // Secondary — soft coral
    secondary: AppColors.secondaryDarkMode,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF7A2B10),
    onSecondaryContainer: Color(0xFFFFE4D9),
    // Tertiary — teal accent
    tertiary: AppColors.accentDarkMode,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF0F4A44),
    onTertiaryContainer: Color(0xFFCCFBF1),
    // Surface
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.cardDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    // Background
    // ignore: deprecated_member_use
    background: AppColors.backgroundDark,
    // ignore: deprecated_member_use
    onBackground: AppColors.textPrimaryDark,
    // Outline
    outline: AppColors.dividerDark,
    outlineVariant: Color(0xFF475569),
    // Error
    error: Color(0xFFFC8181),
    onError: Color(0xFF7A1C1C),
    errorContainer: Color(0xFF7A1C1C),
    onErrorContainer: Color(0xFFFFEDED),
    // Inverse
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primary,
    // Shadow
    shadow: Color(0x33000000),
    scrim: Color(0x66000000),
  ),

  // ── Scaffold background ───────────────────────────────────────────────────
  scaffoldBackgroundColor: AppColors.backgroundDark,

  // ── AppBar ────────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    surfaceTintColor: Colors.transparent,
    shadowColor: Color(0x33000000),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: AppColors.primaryDarkMode),
  ),

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: Color(0xFF3730A3),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primaryDarkMode);
      }
      return const IconThemeData(color: AppColors.textSecondaryDark);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.primaryDarkMode,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      }
      return const TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
    }),
    elevation: 2,
    surfaceTintColor: Colors.transparent,
  ),

  // ── Elevated button ───────────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDarkMode,
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
      backgroundColor: AppColors.primaryDarkMode,
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
      foregroundColor: AppColors.primaryDarkMode,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: AppColors.primaryDarkMode, width: 1.5),
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
      foregroundColor: AppColors.primaryDarkMode,
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
    fillColor: AppColors.cardDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide:
          const BorderSide(color: AppColors.dividerDark, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide:
          const BorderSide(color: AppColors.dividerDark, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide:
          const BorderSide(color: AppColors.primaryDarkMode, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFFC8181), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFFC8181), width: 2),
    ),
    hintStyle: const TextStyle(
        color: AppColors.textSecondaryDark, fontSize: 14),
    labelStyle: const TextStyle(
        color: AppColors.textSecondaryDark, fontSize: 14),
    prefixIconColor: AppColors.primaryDarkMode,
    suffixIconColor: AppColors.textSecondaryDark,
  ),

  // ── Card ──────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.cardDark,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.dividerDark, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),

  // ── List tile ─────────────────────────────────────────────────────────────
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.primaryDarkMode,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    subtitleTextStyle: TextStyle(
      color: AppColors.textSecondaryDark,
      fontSize: 13,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  ),

  // ── Chip ──────────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF3730A3),
    labelStyle: const TextStyle(
        color: AppColors.primaryDarkMode, fontWeight: FontWeight.w500),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  // ── FAB ───────────────────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDarkMode,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: CircleBorder(),
  ),

  // ── Divider ───────────────────────────────────────────────────────────────
  dividerColor: AppColors.dividerDark,
  dividerTheme: const DividerThemeData(
    color: AppColors.dividerDark,
    space: 1,
    thickness: 1,
  ),

  // ── Dialog ────────────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: const TextStyle(
      color: AppColors.textSecondaryDark,
      fontSize: 14,
    ),
  ),

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    showDragHandle: true,
    dragHandleColor: AppColors.dividerDark,
  ),

  // ── SnackBar ──────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.cardDark,
    contentTextStyle: const TextStyle(
        color: AppColors.textPrimaryDark, fontSize: 14),
    actionTextColor: AppColors.accentDarkMode,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 4,
  ),

  // ── Progress indicator ────────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryDarkMode,
    linearMinHeight: 4,
  ),

  // ── Switch ────────────────────────────────────────────────────────────────
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return AppColors.textSecondaryDark;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDarkMode;
      }
      return AppColors.dividerDark;
    }),
  ),

  // ── Badge ─────────────────────────────────────────────────────────────────
  badgeTheme: const BadgeThemeData(
    backgroundColor: AppColors.secondaryDarkMode,
    textColor: Colors.white,
    smallSize: 8,
  ),

  // ── Typography ────────────────────────────────────────────────────────────
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 57,
        fontWeight: FontWeight.w700),
    displayMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 45,
        fontWeight: FontWeight.w700),
    displaySmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 36,
        fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 32,
        fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 28,
        fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 24,
        fontWeight: FontWeight.w700),
    titleLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 22,
        fontWeight: FontWeight.w600),
    titleMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w600),
    titleSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w400),
    labelLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w600),
    labelMedium: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w500),
  ),
);
