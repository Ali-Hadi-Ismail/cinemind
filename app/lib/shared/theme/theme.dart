import 'package:flutter/material.dart';

class CineMindTheme {
  // Core brand colors
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2A2A2D);
  static const Color whiteText = Colors.white;

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryRed,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: whiteText,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 24,
        color: whiteText,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: whiteText,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 40,
        color: whiteText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 28,
        color: whiteText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: whiteText,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        color: whiteText,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
    iconTheme: const IconThemeData(color: whiteText),
    cardColor: cardDark,
    dividerColor: Colors.white24,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      onPrimary: whiteText,
      surface: backgroundDark,
      onSurface: whiteText,
      secondary: Colors.redAccent,
      onSecondary: whiteText,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 24,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 40,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: 28,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        color: Colors.black54,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: Colors.grey[200],
    dividerColor: Colors.black26,
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      secondary: Colors.redAccent,
      onSecondary: Colors.white,
    ),
  );
}
