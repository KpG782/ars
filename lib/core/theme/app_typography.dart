import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Figtree';

  static TextStyle figtree({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    double? letterSpacing,
    Color? color,
  }) {
    if (GoogleFonts.config.allowRuntimeFetching) {
      return GoogleFonts.figtree(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme textTheme(Color text1, Color text2, Color text3) {
    return TextTheme(
      displayLarge: figtree(
        fontSize: 57,
        height: 64 / 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: text1,
      ),
      displayMedium: figtree(
        fontSize: 45,
        height: 52 / 45,
        fontWeight: FontWeight.w400,
        color: text1,
      ),
      displaySmall: figtree(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w500,
        color: text1,
      ),
      headlineLarge: figtree(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      headlineMedium: figtree(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      headlineSmall: figtree(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      titleLarge: figtree(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w500,
        color: text1,
      ),
      titleMedium: figtree(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: text1,
      ),
      titleSmall: figtree(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: text1,
      ),
      bodyLarge: figtree(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: text1,
      ),
      bodyMedium: figtree(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: text2,
      ),
      bodySmall: figtree(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
        color: text2,
      ),
      labelLarge: figtree(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: text1,
      ),
      labelMedium: figtree(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: text2,
      ),
      labelSmall: figtree(
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w600,
        color: text3,
      ),
    );
  }
}
