import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF81C784);

  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);

  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color infoBlue = Color(0xFF1976D2);

  // Text Styles
  static TextStyle get arabicTextStyle => GoogleFonts.cairo();
  static TextStyle get englishTextStyle => GoogleFonts.roboto();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: lightGreen,
        surface: primaryWhite,
        error: errorRed,
        onPrimary: primaryWhite,
        onSecondary: primaryWhite,
        onSurface: darkGray,
        onError: primaryWhite,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: primaryWhite,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: arabicTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryWhite,
        ),
        iconTheme: const IconThemeData(color: primaryWhite),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: primaryWhite,
        elevation: 4,
        shadowColor: darkGray.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: primaryWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: arabicTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: arabicTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: arabicTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: arabicTextStyle.copyWith(
          color: darkGray,
          fontSize: 14,
        ),
        hintStyle: arabicTextStyle.copyWith(
          color: darkGray.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: arabicTextStyle.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        displayMedium: arabicTextStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        displaySmall: arabicTextStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        headlineLarge: arabicTextStyle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        headlineMedium: arabicTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        headlineSmall: arabicTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleLarge: arabicTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleMedium: arabicTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        titleSmall: arabicTextStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        bodyLarge: arabicTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        bodyMedium: arabicTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        bodySmall: arabicTextStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        labelLarge: arabicTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        labelMedium: arabicTextStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        labelSmall: arabicTextStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkGray,
        size: 24,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: primaryWhite,
        elevation: 6,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: darkGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: primaryWhite,
        elevation: 16,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: lightGreen,
        secondary: accentGreen,
        surface: Color(0xFF1E1E1E),
        error: errorRed,
        onPrimary: Color(0xFF121212),
        onSecondary: Color(0xFF121212),
        onSurface: Color(0xFFE0E0E0),
        onError: primaryWhite,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: const Color(0xFFE0E0E0),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: arabicTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE0E0E0),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Text Theme for Dark Mode
      textTheme: TextTheme(
        displayLarge: arabicTextStyle.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE0E0E0),
        ),
        bodyLarge: arabicTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFE0E0E0),
        ),
        // Add other text styles as needed
      ),
    );
  }
}
