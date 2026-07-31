import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryNavy = Color(0xFF0A2342);
  static const Color secondaryGold = Color(0xFFD4AF37);
  static const Color accentWhite = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF28A745);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF6C757D);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryNavy,
      secondary: secondaryGold,
      surface: accentWhite,
      error: errorRed,
      onPrimary: accentWhite,
      onSecondary: primaryNavy,
      onSurface: textDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundGrey,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: accentWhite,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: accentWhite,
        ),
        iconTheme: const IconThemeData(color: accentWhite),
      ),

      // Text Themes
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryNavy,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryNavy,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryNavy,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMedium,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: accentWhite,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryGold,
          foregroundColor: primaryNavy,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: primaryNavy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: accentWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: accentWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textMedium.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textMedium,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryNavy,
        selectedItemColor: secondaryGold,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryGold,
        foregroundColor: primaryNavy,
        elevation: 4,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: textMedium.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: backgroundGrey,
        selectedColor: secondaryGold.withOpacity(0.3),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          color: textDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
