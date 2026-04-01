import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFFFD23F);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color success = Color(0xFF06D6A0);
  static const Color danger = Color(0xFFEF476F);

  static const Color darkBg = Color(0xFF0D0D14);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkBorder = Color(0xFF2A2A4A);
  static const Color darkText = Color(0xFFF0F0FF);
  static const Color darkSubText = Color(0xFF8888AA);

  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEEEEFF);
  static const Color lightBorder = Color(0xFFDDDDEE);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightSubText = Color(0xFF666688);

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkSurface,
      background: darkBg,
      error: danger,
    ),
    cardColor: darkCard,
    dividerColor: darkBorder,
    textTheme: _textTheme(darkText),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      titleTextStyle: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      iconTheme: const IconThemeData(color: darkText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primary,
      unselectedItemColor: darkSubText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: darkBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      labelStyle: const TextStyle(color: darkSubText, fontFamily: 'Outfit'),
      hintStyle: const TextStyle(color: darkSubText, fontFamily: 'Outfit'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      ),
    ),
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: lightSurface,
      background: lightBg,
      error: danger,
    ),
    cardColor: lightCard,
    dividerColor: lightBorder,
    textTheme: _textTheme(lightText),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      titleTextStyle: TextStyle(color: lightText, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      iconTheme: const IconThemeData(color: lightText),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primary,
      unselectedItemColor: lightSubText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: lightBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: lightBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
      labelStyle: const TextStyle(color: lightSubText, fontFamily: 'Outfit'),
      hintStyle: const TextStyle(color: lightSubText, fontFamily: 'Outfit'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      ),
    ),
  );

  static TextTheme _textTheme(Color color) => TextTheme(
    displayLarge: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: color, fontFamily: 'Outfit'),
    bodyMedium: TextStyle(color: color, fontFamily: 'Outfit'),
    labelLarge: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.w600),
  );

  static Color priorityColor(int index) {
    switch (index) {
      case 0: return const Color(0xFF4ECDC4); // low - teal
      case 1: return const Color(0xFFFFD23F); // medium - yellow
      case 2: return const Color(0xFFEF476F); // high - red
      default: return const Color(0xFF4ECDC4);
    }
  }

  static String priorityLabel(int index) {
    switch (index) {
      case 0: return 'Low';
      case 1: return 'Medium';
      case 2: return 'High';
      default: return 'Low';
    }
  }
}