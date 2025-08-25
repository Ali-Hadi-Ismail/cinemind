import 'package:flutter/material.dart';

class CineMindTheme {
  // Lighter red, soft black, white
  static const Color primaryRed = Color(0xFFE53935); // softer red
  static const Color backgroundBlack = Color(0xFF312c2b); // softer black
  static const Color whiteText = Colors.white;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: backgroundBlack,

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: whiteText,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: whiteText),
      bodyLarge: TextStyle(color: whiteText),
      bodySmall: TextStyle(color: whiteText),
    ),
    iconTheme: const IconThemeData(color: whiteText),
    cardColor: Color(0xFF2A2A2A), // dark card color
    dividerColor: Colors.grey,
    colorScheme: ColorScheme.dark(
      primary: primaryRed,
      surface: backgroundBlack,
      onSurface: whiteText,
      onPrimary: whiteText,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: Colors.grey[200],
    dividerColor: Colors.grey,
    colorScheme: ColorScheme.light(
      primary: primaryRed,
      surface: Colors.white,
      onPrimary: Colors.white,
    ),
  );
}
