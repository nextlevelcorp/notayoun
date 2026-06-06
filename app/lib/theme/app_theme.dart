import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'dimens.dart';

/// NotaOyun teması. FLUTTER_TOKENS.md bölüm 2 & 8.
ThemeData buildNotaOyunTheme() {
  const cs = kNotaOyunColorScheme;
  final onBg = cs.onSurface;

  final textTheme = TextTheme(
    // Display
    displayLarge: GoogleFonts.baloo2(
      fontSize: 32, fontWeight: FontWeight.w800, height: 1.0, color: onBg,
    ),
    displayMedium: GoogleFonts.baloo2(
      fontSize: 24, fontWeight: FontWeight.w800, height: 1.0, color: onBg,
    ),
    // Title
    titleLarge: GoogleFonts.baloo2(
      fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, color: onBg,
    ),
    titleMedium: GoogleFonts.baloo2(
      fontSize: 16, fontWeight: FontWeight.w600, height: 1.2, color: onBg,
    ),
    // Body
    bodyLarge: GoogleFonts.nunito(
      fontSize: 15, fontWeight: FontWeight.w700, height: 1.5, color: onBg,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: onBg,
    ),
    bodySmall: GoogleFonts.nunito(
      fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: onBg,
    ),
    // Label
    labelLarge: GoogleFonts.nunito(
      fontSize: 13, fontWeight: FontWeight.w700, height: 1.3, color: onBg,
    ),
    labelMedium: GoogleFonts.nunito(
      fontSize: 11, fontWeight: FontWeight.w700, height: 1.3, color: onBg,
    ),
    labelSmall: GoogleFonts.nunito(
      fontSize: 10, fontWeight: FontWeight.w700, height: 1.2, color: onBg,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: kBgBase,
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        textStyle: textTheme.labelLarge,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        minimumSize: const Size(0, AppA11y.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: cs.primary, width: 2.5),
        foregroundColor: cs.primary,
        textStyle: textTheme.labelLarge,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        minimumSize: const Size(0, AppA11y.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: cs.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBgBase,
      foregroundColor: onBg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    extensions: const [NotaOyunColors()],
  );
}
