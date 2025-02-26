import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF4ECDC4),
    secondary: Color(0xFFFF6B6B),
    background: Color(0xFFF9F9F9),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF2D3142),
    onSurface: Color(0xFF2D3142),
  ),
  scaffoldBackgroundColor: Color(0xFFF9F9F9),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF4ECDC4),
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4ECDC4),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 0,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.black.withOpacity(0.08),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF2D3142),
      fontSize: 16,
      height: 1.5,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2D3142),
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFF4ECDC4),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: Color(0xFFEEEEEE),
    thickness: 1,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF4ECDC4),
    secondary: Color(0xFFFF6B6B),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFF5F5F5),
    onSurface: Color(0xFFF5F5F5),
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFF4ECDC4),
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF4ECDC4),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 0,
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF1E1E1E),
    shadowColor: Colors.black.withOpacity(0.2),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFFF5F5F5),
      fontSize: 16,
      height: 1.5,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF5F5F5),
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFF4ECDC4),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: Color(0xFF2A2A2A),
    thickness: 1,
  ),
);
