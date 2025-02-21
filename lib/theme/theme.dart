import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF5AC8FA), // Fresh pastel blue
    secondary: Color(0xFF50C2C9), // Soft teal accent
    background: Color(0xFFF7F9FC), // Light soothing background
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF333333), // Dark text for readability
    onSurface: Color(0xFF333333),
  ),
  scaffoldBackgroundColor: Color(0xFFF7F9FC), // Light calming tone
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF50C2C9), // Teal for app bar text/icons
    elevation: 2, // Subtle depth
    shadowColor: Colors.black12,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF50C2C9), // Teal background
      foregroundColor: Colors.white, // White text
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Smooth rounded buttons
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 3,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.black12,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF333333), fontSize: 16),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF50C2C9)),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF64D2FF), // Brighter pastel blue
    secondary: Color(0xFF3AB0A2), // Soft teal-green accent
    background: Color(0xFF181A20), // Dark soothing background
    surface: Color(0xFF1F222A),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Color(0xFFE0E0E0), // Light text for readability
    onSurface: Color(0xFFE0E0E0),
  ),
  scaffoldBackgroundColor: Color(0xFF181A20), // Dark soothing background
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1F222A), // Darker gray-blue app bar
    foregroundColor: Color(0xFF64D2FF), // Bright accent for icons
    elevation: 2,
    shadowColor: Colors.black26,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF3AB0A2), // Brighter teal
      foregroundColor: Colors.black, // Black text for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 3,
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF1F222A),
    shadowColor: Colors.black45,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF64D2FF)),
  ),
);
