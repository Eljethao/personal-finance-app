import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === Electric Oasis Palette ===
  static const Color primary     = Color(0xFF66308F);
  static const Color primaryDark = Color(0xFF4A1C6F);
  static const Color primaryLight= Color(0xFF9055BA);
  static const Color accent      = Color(0xFF00C48C);
  static const Color income      = Color(0xFF00C48C);
  static const Color expense     = Color(0xFFFF4466);
  static const Color investment  = Color(0xFFFF8A00);
  static const Color background  = Color(0xFFF5F7FF);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF0A1128);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color divider       = Color(0xFFECEFF8);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.09),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.38),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  static ThemeData get lightTheme => lightThemeForLocale('en');

  static ThemeData lightThemeForLocale(String locale) {
    final base = _buildBase();
    if (locale == 'lo') {
      // Step 1: patch textTheme so Text() widgets get NotoSansLao
      final loBase = base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'NotoSansLao'),
        primaryTextTheme:
            base.primaryTextTheme.apply(fontFamily: 'NotoSansLao'),
      );
      // Step 2: patch widget-specific text styles that don't inherit textTheme
      return loBase.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: const StadiumBorder(),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: 'NotoSansLao',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontFamily: 'NotoSansLao',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontFamily: 'NotoSansLao',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        appBarTheme: base.appBarTheme.copyWith(
          titleTextStyle: loBase.textTheme.titleLarge?.copyWith(
            fontFamily: 'NotoSansLao',
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          labelStyle: const TextStyle(fontFamily: 'NotoSansLao'),
          secondaryLabelStyle: const TextStyle(fontFamily: 'NotoSansLao'),
        ),
        bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
          selectedLabelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            fontSize: 11,
          ),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          labelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            color: textSecondary,
          ),
          floatingLabelStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            color: primary,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'NotoSansLao',
            color: textSecondary,
          ),
        ),
      );
    }
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.manropeTextTheme(base.primaryTextTheme),
    );
  }

  static ThemeData _buildBase() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: background,
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardBackground,
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: const StadiumBorder(),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: expense),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: textSecondary),
          prefixIconColor: textSecondary,
        ),
        chipTheme: const ChipThemeData(
          shape: StadiumBorder(),
          side: BorderSide.none,
          backgroundColor: Color(0xFFEEF2FF),
          selectedColor: primary,
          labelPadding: EdgeInsets.symmetric(horizontal: 4),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          elevation: 8,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFFB0B8D1),
          selectedLabelStyle:
              TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
          space: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      );
}
