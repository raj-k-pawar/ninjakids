import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryPurple = Color(0xFF6C3FE8);
  static const Color secondaryYellow = Color(0xFFFFD93D);
  static const Color accentOrange = Color(0xFFFF7B2C);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color darkNavy = Color(0xFF1E1B4B);
  static const Color lightBg = Color(0xFFF8F7FF);
  static const Color cardBg = Color(0xFFEDE9FF);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
          secondary: accentOrange,
          tertiary: accentGreen,
          background: lightBg,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: lightBg,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 20,
            color: darkNavy,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: darkNavy),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8E4FF), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryPurple,
            side: const BorderSide(color: primaryPurple, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryPurple,
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2DDFF), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2DDFF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            color: Color(0xFFB0A8CC),
            fontSize: 14,
            fontFamily: 'Nunito',
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'FredokaOne', fontSize: 32, color: darkNavy),
          displayMedium: TextStyle(fontFamily: 'FredokaOne', fontSize: 26, color: darkNavy),
          displaySmall: TextStyle(fontFamily: 'FredokaOne', fontSize: 22, color: darkNavy),
          headlineLarge: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w800, color: darkNavy),
          headlineMedium: TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.w800, color: darkNavy),
          headlineSmall: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700, color: darkNavy),
          titleLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: darkNavy),
          titleMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: darkNavy),
          bodyLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF333355)),
          bodyMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF555577)),
          bodySmall: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF888899)),
          labelLarge: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall: TextStyle(fontFamily: 'Nunito', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: cardBg,
          selectedColor: primaryPurple,
          labelStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryPurple,
          unselectedItemColor: Color(0xFFB0A8CC),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 10),
          unselectedLabelStyle: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 10),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryPurple,
          linearTrackColor: cardBg,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE8E4FF),
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkNavy,
          contentTextStyle: const TextStyle(fontFamily: 'Nunito', color: Colors.white, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
            fontFamily: 'FredokaOne', fontSize: 20, color: darkNavy,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: const Color(0xFF9D7BFF),
          secondary: accentOrange,
          tertiary: accentGreen,
          background: const Color(0xFF0E0C1E),
          surface: const Color(0xFF1A1730),
          onPrimary: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E0C1E),
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'FredokaOne', fontSize: 20, color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1730),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E2A50), width: 1.5),
          ),
        ),
      );

  // Subject color map
  static const Map<String, Color> subjectColors = {
    'Mathematics': Color(0xFFFFF3CD),
    'English': Color(0xFFDCF5E7),
    'Science': Color(0xFFE0EEFF),
    'History': Color(0xFFFFF0E8),
    'Geography': Color(0xFFFFE8F1),
    'GK': Color(0xFFF3E8FF),
    'Marathi': Color(0xFFE8F4FF),
    'Coding Basics': Color(0xFFE8FFE8),
    'Logical Reasoning': Color(0xFFFFEEE8),
  };

  static const Map<String, Color> subjectTextColors = {
    'Mathematics': Color(0xFF92660A),
    'English': Color(0xFF166534),
    'Science': Color(0xFF1D4ED8),
    'History': Color(0xFF9A3412),
    'Geography': Color(0xFFBE185D),
    'GK': Color(0xFF7E22CE),
    'Marathi': Color(0xFF075985),
    'Coding Basics': Color(0xFF166534),
    'Logical Reasoning': Color(0xFF9A3412),
  };
}
