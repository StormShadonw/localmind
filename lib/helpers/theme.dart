import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3936b8);
const Color secondaryColor = Color(0xFF094ebb);

final inputBorderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(100),
  borderSide: const BorderSide(color: Colors.white, width: 1),
);
final inputErrorBorderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(100),
  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
);

final THEMEDATA = ThemeData(
  fontFamily: "Poppins",
  colorScheme: const ColorScheme(
    background: Colors.white,
    brightness: Brightness.light,
    secondary: secondaryColor,
    primary: primaryColor,
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
