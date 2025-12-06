import 'package:flutter/material.dart';

class AppTheme {
  static const _font = 'Inter';

  // Colors from design tokens
  static const Color primaryDark = Color(0xFF3C254A);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFE8A04E);
  static const Color backgroundBase = Color(0xFFF7F7F9);
  static const Color textPrimaryDark = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6F6F6F);
  static const Color iconDefault = Color(0xFFA3A3A3);

  static ThemeData lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: _font,
      scaffoldBackgroundColor: backgroundBase,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: accent,
        onPrimary: primaryLight,
        secondary: primaryDark,
        onSecondary: primaryLight,
        error: Colors.red,
        onError: primaryLight,
        surface: primaryLight,
        onSurface: textPrimaryDark,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimaryDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: primaryLight,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: primaryLight,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: primaryLight,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: const BorderSide(color: accent),
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
        hintStyle: const TextStyle(color: Color(0xFFB7B7B7)),
      ),
      iconTheme: const IconThemeData(color: iconDefault),
    );
  }
}

