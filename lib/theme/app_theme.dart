import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50); // Light Green
  static const Color secondaryGreen = Color(0xFFC8E6C9); // Very Light Green
  static const Color accentGreen = Color(0xFF81C784);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F8E9); // Light green surface

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: backgroundLight,
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Colors.black,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryGreen.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x10000000), width: 1),
        ),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  // Keeping dark theme just in case, but renaming it
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C1410),
      );
}
