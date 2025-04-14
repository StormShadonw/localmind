import 'package:flutter/material.dart';

final THEMEDATA = ThemeData(
  fontFamily: "Poppins",
  colorScheme: const ColorScheme(
    background: Colors.white,
    brightness: Brightness.light,
    secondary: Color(0xFF094ebb),
    primary: Color(0xFF3936b8),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    onBackground: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      fontSize: 14,
      // fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      // fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      // fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontFamily: "Poppins",
      fontSize: 24,
      // fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontFamily: "Poppins",
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    displayLarge: TextStyle(
      fontFamily: "Poppins",
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontFamily: "Poppins",
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  useMaterial3: true,
);
