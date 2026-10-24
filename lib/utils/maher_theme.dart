import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaherTheme {
  // Brand Colors - High-End Islamic Palette
  static const Color emeraldDark = Color(0xFF022C22);
  static const Color emeraldPrimary = Color(0xFF045D48);
  static const Color emeraldMedium = Color(0xFF0D7E63);
  static const Color emeraldLight = Color(0xFF10B981);
  static const Color emeraldSoft = Color(0xFFECFDF5);
  static const Color emeraldMint = Color(0xFFD1FAE5);

  static const Color goldPrimary = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldSoft = Color(0xFFFFFBEB);

  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color cardLight = Colors.white;

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  // #64748B gives ~4.8:1 contrast on white (WCAG AA); the old #94A3B8 was ~2.6:1
  static const Color textMuted = Color(0xFF64748B);

  // Bundled fonts (see pubspec.yaml) for scripts Outfit doesn't cover:
  // Gujarati questions, Hindi translations and the Arabic greeting.
  static const List<String> scriptFontFallback = [
    'NotoSansGujarati',
    'NotoSansDevanagari',
    'NotoNaskhArabic',
  ];

  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  // Modern Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF022C22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF022C22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardSoftGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF9FAF9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Modern Layered Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: emeraldPrimary.withValues(alpha: 0.04),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: emeraldPrimary.withValues(alpha: 0.08),
          blurRadius: 36,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> glow(Color color, {double opacity = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  // Responsive Breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double contentWidth(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    if (screenW > 1100) return 920;
    if (screenW > 650) return 620;
    return screenW;
  }

  // App ThemeData
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emeraldPrimary,
        primary: emeraldPrimary,
        secondary: goldPrimary,
        surface: cardLight,
      ),
      fontFamily: GoogleFonts.balooBhai2().fontFamily,
      fontFamilyFallback: scriptFontFallback,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: emeraldPrimary.withValues(alpha: 0.07),
            width: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldPrimary, width: 2),
        ),
      ),
    );
  }
}
