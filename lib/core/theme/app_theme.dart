import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_styles.dart';

/// Configuration and ThemeData for the Liquid Glass Dialer app.
class AppTheme {
  AppTheme._();

  /// Configurable working title or future final name.
  static const String appTitle = 'Liquid Glass Dialer';
  static const String appShortName = 'LIQUID';

  /// Root dark theme adhering to AMOLED-black background and liquid glass aesthetic.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GlassColors.background,
      colorScheme: const ColorScheme.dark(
        primary: GlassColors.silverAccent,
        secondary: GlassColors.silverHighlight,
        tertiary: GlassColors.silverSubtle,
        surface: GlassColors.surfaceDark,
        onSurface: GlassColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: GlassColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GlassColors.surfaceDark.withValues(alpha: 0.92),
        contentTextStyle: const TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GlassColors.borderLight, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        titleLarge: TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: GlassColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: GlassColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        labelSmall: TextStyle(
          color: GlassColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
        ),
      ),
      useMaterial3: true,
    );
  }
}
