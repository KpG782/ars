import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Talyer type system.
///
/// - **Display / headings → Space Grotesk**: an engineered, precise grotesk
///   that nods to tools & mechanics without the kinetic feel of a
///   motorsport face. Confident, trustworthy, characterful.
/// - **Body / UI → Inter**: a workhorse with excellent small-size legibility.
///
/// Both are free (OFL) and resolved via `google_fonts`, so the repo needs no
/// bundled binary font assets. Body text never drops below 16px on mobile.
abstract final class TalyerType {
  static TextStyle _display(double size, double height, FontWeight w) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        height: height / size,
        fontWeight: w,
        letterSpacing: -0.4,
      );

  static TextStyle _text(double size, double height, FontWeight w,
          {double spacing = 0}) =>
      GoogleFonts.inter(
        fontSize: size,
        height: height / size,
        fontWeight: w,
        letterSpacing: spacing,
      );

  // Display & headings (Space Grotesk)
  static TextStyle get displayLarge => _display(40, 48, FontWeight.w700);
  static TextStyle get displaySmall => _display(32, 40, FontWeight.w700);
  static TextStyle get headline => _display(28, 36, FontWeight.w700);
  static TextStyle get titleLarge => _display(22, 28, FontWeight.w600);

  // Titles & body (Inter)
  static TextStyle get titleMedium => _text(17, 24, FontWeight.w600);
  static TextStyle get titleSmall => _text(15, 20, FontWeight.w600);
  static TextStyle get bodyLarge => _text(16, 24, FontWeight.w400);
  static TextStyle get bodyMedium => _text(14, 20, FontWeight.w400);
  static TextStyle get label => _text(15, 20, FontWeight.w600, spacing: 0.1);
  static TextStyle get caption => _text(13, 18, FontWeight.w400);
  static TextStyle get overline =>
      _text(11, 16, FontWeight.w700, spacing: 0.8);

  /// Builds a Material [TextTheme] coloured for the given primary text colour.
  static TextTheme textTheme(Color onSurface) => TextTheme(
        displayLarge: displayLarge.copyWith(color: onSurface),
        displaySmall: displaySmall.copyWith(color: onSurface),
        headlineMedium: headline.copyWith(color: onSurface),
        titleLarge: titleLarge.copyWith(color: onSurface),
        titleMedium: titleMedium.copyWith(color: onSurface),
        titleSmall: titleSmall.copyWith(color: onSurface),
        bodyLarge: bodyLarge.copyWith(color: onSurface),
        bodyMedium: bodyMedium.copyWith(color: onSurface),
        labelLarge: label.copyWith(color: onSurface),
        bodySmall: caption.copyWith(color: onSurface),
        labelSmall: overline.copyWith(color: onSurface),
      );
}
