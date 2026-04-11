import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chirp's text theme built on Inter.
abstract final class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = GoogleFonts.interTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
    );

    return base.copyWith(
      // Large timer display (home screen countdown)
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w200,
        letterSpacing: -1.0,
      ),
      // Smaller timer display (pomodoro)
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w200,
        letterSpacing: -0.5,
      ),
      // Break screen title, section headers
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w300,
      ),
      // App title in header
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      // Card titles, stat values
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      // Section labels
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
