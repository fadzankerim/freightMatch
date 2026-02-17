import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // ── Raw Palette ──────────────────────────────────────────
  static const Color inkBlack  = Color(0xFF01161E);
  static const Color darkTeal  = Color(0xFF124559);
  static const Color airForce  = Color(0xFF598392);
  static const Color ashGrey   = Color(0xFFAEC3B0);
  static const Color beige     = Color(0xFFEFF6E0);

  // ── Background hierarchy ─────────────────────────────────
  static const Color bgPrimary   = Color(0xFF01161E);
  static const Color bgSecondary = Color(0xFF0D2030);
  static const Color bgCard      = Color(0xFF0F2535);
  static const Color bgElevated  = Color(0xFF124559);
  static const Color bgInput     = Color(0xFF0D2030);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEFF6E0);
  static const Color textSecondary = Color(0xFFAEC3B0);
  static const Color textMuted     = Color(0xFF6B8A8F);
  static const Color textInverse   = Color(0xFF01161E);

  // ── Brand ────────────────────────────────────────────────
  static const Color primary        = Color(0xFF598392);
  static const Color primaryLight   = Color(0xFF6D98A8);
  static const Color primaryDark    = Color(0xFF3D6472);
  static const Color primarySurface = Color(0xFF0F2D38);

  // ── Borders ──────────────────────────────────────────────
  static const Color border      = Color(0xFF1E3A4A);
  static const Color borderLight = Color(0xFF2A4A5A);

  // ── Status ───────────────────────────────────────────────
  static const Color success        = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFF0F2A1A);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFF2A1F0A);
  static const Color error          = Color(0xFFEF4444);
  static const Color errorSurface   = Color(0xFF2A0F0F);
  static const Color info           = Color(0xFF3B82F6);

  // ── Vehicle type accent colours ──────────────────────────
  static const Color van        = Color(0xFF8B5CF6);
  static const Color pickup     = Color(0xFF10B981);
  static const Color smallTruck = Color(0xFF3B82F6);
  static const Color largeTruck = Color(0xFF598392);
  static const Color flatbed    = Color(0xFFF59E0B);
}

class AppRadius {
  AppRadius._();
  static const double xs   = 4;
  static const double sm   = 6;
  static const double md   = 10;
  static const double lg   = 14;
  static const double xl   = 20;
  static const double xxl  = 28;
  static const double full = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

class AppTheme {
  AppTheme._();

  static SystemUiOverlayStyle get systemUiStyle => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.bgSecondary,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgPrimary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.darkTeal,
        surface: AppColors.bgCard,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
        outline: AppColors.border,
      ),

      textTheme: _buildTextTheme(base.textTheme),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemUiStyle,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(
            fontSize: 14, color: AppColors.textSecondary),
        hintStyle:
            GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
        errorStyle:
            GoogleFonts.dmSans(fontSize: 12, color: AppColors.error),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: GoogleFonts.dmSans(
            fontSize: 14, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCard,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.dmSans(
            fontSize: 13, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.syne(
          fontSize: 40, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -1),
      displayMedium: GoogleFonts.syne(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.5),
      displaySmall: GoogleFonts.syne(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.syne(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.syne(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      titleMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary),
      titleSmall: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary),
      bodyLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary),
      bodySmall: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textMuted),
      labelLarge: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      labelMedium: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary),
      labelSmall: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textMuted, letterSpacing: 0.5),
    );
  }
}