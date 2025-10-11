import 'package:flutter/material.dart';

import '../utils/constants.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(AppConstants.primaryColorValue);
  static const Color secondaryColor = Color(AppConstants.secondaryColorValue);
  static const Color backgroundColor = Color.fromRGBO(234, 234, 234, 1);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color.fromARGB(207, 207, 207, 207), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static const TextStyle titleTextStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);

  static const TextStyle subtitleTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary);

  static const TextStyle bodyTextStyle = TextStyle(fontSize: 16, color: textPrimary);

  static const TextStyle smallTextStyle = TextStyle(fontSize: 14, color: textSecondary);

  static const TextStyle buttonTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> buttonShadow = [const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.57), blurRadius: 5)];

  // Border Radius
  static BorderRadius cardBorderRadius = BorderRadius.circular(12);
  static BorderRadius buttonBorderRadius = BorderRadius.circular(7);

  // Spacing
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // App Theme Data
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: subtitleTextStyle,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: cardColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
      ),
    );
  }
}
