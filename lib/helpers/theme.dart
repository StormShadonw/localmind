import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFF0D0D0E);
const Color surfaceColor = Color(0xFF1A1A1C);
const Color primaryColor = Color(0xFF7D8BFF);
const Color accentColor = Color(0xFFA682FF);
const Color textColor = Colors.white;
const Color secondaryTextColor = Color(0xFFA1A1AA);

final inputBorderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
);

final inputErrorBorderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
);

final THEMEDATA = ThemeData(
  fontFamily: "Poppins",
  brightness: Brightness.dark,
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: const ColorScheme.dark(
    background: backgroundColor,
    surface: surfaceColor,
    primary: primaryColor,
    secondary: accentColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: textColor,
    onSurface: textColor,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: textColor, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, color: textColor, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, color: secondaryTextColor),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    displaySmall: TextStyle(fontSize: 12, color: secondaryTextColor),
  ),
  cardTheme: CardThemeData(
    color: surfaceColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
  ),
  useMaterial3: true,
);
