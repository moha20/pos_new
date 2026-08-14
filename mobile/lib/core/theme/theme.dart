import 'package:flutter/material.dart';

class AppTheme {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CORE PALETTE TOKENS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Modern Copper / Amber Palette
  static const Color primaryCopper = Color(0xFFEA580C); // Modern vibrant amber-orange
  static const Color primaryCopperLight = Color(0xFFFB923C);
  static const Color accentGold = Color(0xFFF59E0B); // Amber 500

  // Modern Logo Blue / Tech Indigo Palette
  static const Color primaryBlue = Color(0xFF1E40AF); // Deep Indigo-Blue
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Vibrant Sky-Blue
  static const Color secondaryBlue = Color(0xFF475569); // Slate 600

  // Neutral Background & Surface Tokens
  static const Color slateBgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color slateCardLight = Color(0xFFFFFFFF); // Pure White Surface
  static const Color slateBorderLight = Color(0xFFE2E8F0); // Slate 200

  static const Color slateBgDark = Color(0xFF0B111E); // Deep Tech Slate Dark
  static const Color slateCardDark = Color(0xFF131D31); // Elevated Dark Card Surface
  static const Color slateCardElevatedDark = Color(0xFF1C2841); // Hover/Header Dark
  static const Color slateBorderDark = Color(0xFF22324F); // Dark Border Stroke

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF06B6D4); // Cyan 500

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // THEME GENERATORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        primary: primaryCopper,
        secondary: accentGold,
        background: slateBgLight,
        cardColor: slateCardLight,
        borderColor: slateBorderLight,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        primary: primaryCopperLight,
        secondary: accentGold,
        background: slateBgDark,
        cardColor: slateCardDark,
        borderColor: slateBorderDark,
      );

  static ThemeData get logoBlueLight => _buildTheme(
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: secondaryBlue,
        background: slateBgLight,
        cardColor: slateCardLight,
        borderColor: slateBorderLight,
      );

  static ThemeData get logoBlueDark => _buildTheme(
        brightness: Brightness.dark,
        primary: primaryBlueLight,
        secondary: Color(0xFF94A3B8),
        background: slateBgDark,
        cardColor: slateCardDark,
        borderColor: slateBorderDark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color cardColor,
    required Color borderColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withValues(alpha: isDark ? 0.2 : 0.1),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondary.withValues(alpha: isDark ? 0.2 : 0.1),
      onSecondaryContainer: secondary,
      error: error,
      onError: Colors.white,
      surface: cardColor,
      onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      surfaceContainerHighest: isDark ? slateCardElevatedDark : const Color(0xFFF1F5F9),
      outline: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
      outlineVariant: borderColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: cardColor,
      cardColor: cardColor,
      dividerColor: borderColor,
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        shape: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0E1626) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        suffixIconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: borderColor, width: 1),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1A263E) : const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 0.8),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        elevation: 8,
      ),
    );
  }
}
