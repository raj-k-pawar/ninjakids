import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF5A52E0);
  static const primaryLight = Color(0xFF8B85FF);
  static const secondary = Color(0xFFFFB84C);
  static const green = Color(0xFF4CD964);
  static const red = Color(0xFFFF6B6B);
  static const blue = Color(0xFF00C2FF);
  static const purple = Color(0xFFBB6BFF);
  static const orange = Color(0xFFFF8C42);
  static const ninjaRed = Color(0xFFE63946);
  static const ninjaGold = Color(0xFFFFD700);
  static const ninjaDark = Color(0xFF1A1A2E);
  static const ninjaAccent = Color(0xFF16213E);
  static const bgLight = Color(0xFFF7F9FC);
  static const bgWhite = Color(0xFFFFFFFF);
  static const bgDark = Color(0xFF121212);
  static const bgDarkCard = Color(0xFF1E1E2E);
  static const bgDarkSurface = Color(0xFF2A2A3E);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF555555);
  static const textLight = Color(0xFFFFFFFF);
  static const textLightGrey = Color(0xFFBDBDBD);
  static const List<Color> primaryGradient = [Color(0xFF6C63FF), Color(0xFF9C63FF)];
  static const List<Color> goldGradient = [Color(0xFFFFD700), Color(0xFFFFB84C)];
  static const List<Color> greenGradient = [Color(0xFF4CD964), Color(0xFF00C2FF)];
  static const List<Color> redGradient = [Color(0xFFFF6B6B), Color(0xFFFF8C42)];
  static const List<Color> ninjaGradient = [Color(0xFF1A1A2E), Color(0xFF16213E)];
  static const List<Color> splashGradient = [Color(0xFF6C63FF), Color(0xFF1A1A2E)];
  static const mathColor = Color(0xFF6C63FF);
  static const englishColor = Color(0xFF00C2FF);
  static const scienceColor = Color(0xFF4CD964);
  static const marathiColor = Color(0xFFFF8C42);
  static const historyColor = Color(0xFFFFB84C);
  static const geographyColor = Color(0xFF4CD964);
  static const codingColor = Color(0xFFBB6BFF);
  static const gkColor = Color(0xFFFF6B6B);
  static const reasoningColor = Color(0xFF00C2FF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgWhite,
      ),
      textTheme: _textTheme(AppColors.textDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgWhite,
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.bgDarkCard,
      ),
      textTheme: _textTheme(AppColors.textLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgDarkCard,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgDarkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textLightGrey),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, color: textColor),
      displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
      displaySmall: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      headlineLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
      bodyMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400, color: textColor.withValues(alpha: 0.7)),
      labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
    );
  }
}

class AppGradients {
  static LinearGradient get primary => const LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get gold => const LinearGradient(
    colors: AppColors.goldGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get green => const LinearGradient(
    colors: AppColors.greenGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get ninja => const LinearGradient(
    colors: AppColors.ninjaGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get splash => const LinearGradient(
    colors: AppColors.splashGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient subjectGradient(Color color) => LinearGradient(
    colors: [color, color.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
