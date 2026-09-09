import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette (Rose Gold, Deep Velvet, Midnight, Emerald)
  static const Color primaryRose = Color(0xFFE91E63);
  static const Color primaryRoseDark = Color(0xFFC2185B);
  static const Color accentGold = Color(0xFFFFD54F);
  static const Color accentViolet = Color(0xFF9C27B0);
  
  // Dark Mode Canvas (Deep Velvet / Onyx)
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkCard = Color(0xFF1E1C2B);
  static const Color darkCardHover = Color(0xFF2A273C);
  static const Color darkTextPrimary = Color(0xFFFFFFFE);
  static const Color darkTextSecondary = Color(0xFFA7A9BE);

  // Light Mode Canvas (Warm Pearl / Rose Tint)
  static const Color lightBackground = Color(0xFFFAF7F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardHover = Color(0xFFF3EBF0);
  static const Color lightTextPrimary = Color(0xFF272343);
  static const Color lightTextSecondary = Color(0xFF757575);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryRose,
        secondary: accentGold,
        tertiary: accentViolet,
        surface: darkCard,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextPrimary),
        titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: darkTextPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryRose,
        secondary: accentGold,
        tertiary: accentViolet,
        surface: lightCard,
        onSurface: lightTextPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextPrimary),
        titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: lightTextPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: lightTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shadowColor: primaryRose.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withOpacity(0.04), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  // Glassmorphic Card Container Decoration
  static BoxDecoration glassBox({
    required BuildContext context,
    double radius = 24,
    Color? borderColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1C2B).withOpacity(0.75) : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (isDark ? Colors.white.withOpacity(0.12) : primaryRose.withOpacity(0.12)),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : primaryRose.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
