import 'package:flutter/material.dart';

/// Clean design tokens and theme styles for the ScriptBridge application.
class AppTheme {
  /// Dark slate color definition.
  static const Color backgroundColor = Color(0xFF0F1717);
  static const Color surfaceColor = Color(0xFF162222);
  static const Color accentColor = Colors.tealAccent;
  static const Color primaryColor = Colors.teal;

  /// Returns the configured dark theme data.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white60,
        ),
      ),
    );
  }
}
