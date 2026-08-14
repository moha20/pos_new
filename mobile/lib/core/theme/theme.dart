import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryCopper = Color(0xFFE65100); // Amber/Copper Orange
  static const Color accentGold = Color(0xFFFFB300); // Warm Yellow/Gold
  static const Color slateDark = Color(0xFF0F172A); // Midnight Slate
  static const Color slateCardDark = Color(0xFF1E293B); // Darker Slate Card
  static const Color slateLight = Colors.white; // Clean Pure White Background
  static const Color slateCardLight = Colors.white;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryCopper,
        secondary: accentGold,
        surface: slateCardLight,
      ),
      scaffoldBackgroundColor: slateLight,
      cardTheme: const CardThemeData(
        color: slateCardLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ), // slate-200 border
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slateCardLight,
        foregroundColor: slateDark,
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryCopper,
        textTheme: ButtonTextTheme.primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryCopper,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryCopper,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryCopper,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryCopper,
        secondary: accentGold,
        surface: slateCardDark,
      ),
      scaffoldBackgroundColor: slateDark,
      cardTheme: const CardThemeData(
        color: slateCardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slateCardDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryCopper,
        textTheme: ButtonTextTheme.primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryCopper,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryCopper,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: slateDark,
        selectedItemColor: primaryCopper,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static const Color primaryBlue = Color(0xFF002758); // Logo Deep Blue
  static const Color secondaryBlue = Color(0xFF305E89); // Logo Slate Blue

  static ThemeData get logoBlueLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: slateCardLight,
      ),
      scaffoldBackgroundColor: slateLight,
      cardTheme: const CardThemeData(
        color: slateCardLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ), // slate-200 border
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slateCardLight,
        foregroundColor: slateDark,
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryBlue,
        textTheme: ButtonTextTheme.primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryBlue,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData get logoBlueDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF64B5F6), // Bright contrast brand blue for dark theme
        secondary: secondaryBlue,
        surface: slateCardDark,
      ),
      scaffoldBackgroundColor: slateDark,
      cardTheme: const CardThemeData(
        color: slateCardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slateCardDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF64B5F6),
        textTheme: ButtonTextTheme.primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF64B5F6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF64B5F6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: slateDark,
        selectedItemColor: Color(0xFF64B5F6),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
