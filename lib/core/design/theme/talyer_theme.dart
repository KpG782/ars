import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Builds Talyer's light & dark [ThemeData] from the design tokens.
///
/// The Material [ColorScheme] is derived from the semantic [TalyerColors]
/// set, and the full token set is attached as a [ThemeExtension] so brand
/// colours Material doesn't model (brand teal, accent, emergency, verified,
/// status, 3-level text) remain first-class and themable.
abstract final class TalyerTheme {
  static ThemeData light = _build(TalyerColors.light);
  static ThemeData dark = _build(TalyerColors.dark);

  static ColorScheme _scheme(TalyerColors c) => ColorScheme(
        brightness: c.brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        primaryContainer: c.primaryBg,
        onPrimaryContainer: c.primaryTx,
        secondary: c.accent,
        onSecondary: c.onAccent,
        secondaryContainer: c.accentBg,
        onSecondaryContainer: c.accentPressed,
        tertiary: c.verified,
        onTertiary: c.onVerified,
        tertiaryContainer: c.verifiedBg,
        onTertiaryContainer: c.verifiedTx,
        error: c.emergency,
        onError: c.onEmergency,
        errorContainer: c.emergencyBg,
        onErrorContainer: c.emergencyTx,
        surface: c.surface,
        onSurface: c.text1,
        onSurfaceVariant: c.text2,
        surfaceContainerHighest: c.surfaceRaised,
        surfaceContainerHigh: c.surfaceMuted,
        outline: c.border,
        outlineVariant: c.borderStrong,
        shadow: const Color(0xFF0F172A),
        inverseSurface: c.isDark ? c.text1 : TalyerPalette.slate800,
        onInverseSurface: c.isDark ? TalyerPalette.slate900 : TalyerPalette.slate50,
      );

  static ThemeData _build(TalyerColors c) {
    final scheme = _scheme(c);
    final text = TalyerType.textTheme(c.text1);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: text,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text1,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TalyerType.titleLarge.copyWith(color: c.text1),
      ),

      // Filled primary button: ≥48dp, pill, clear pressed state.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.38),
          disabledForegroundColor: c.onPrimary.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(TalyerSpacing.minTouch),
          elevation: 0,
          textStyle: TalyerType.label,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TalyerRadii.xl)),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed)
                ? c.primaryPressed.withValues(alpha: 0.24)
                : null,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.border),
          minimumSize: const Size.fromHeight(TalyerSpacing.minTouch),
          textStyle: TalyerType.label,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TalyerRadii.xl)),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: TalyerType.label,
          minimumSize: const Size(TalyerSpacing.minTouch, TalyerSpacing.minTouch),
        ),
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: TalyerRadii.card,
          side: BorderSide(color: c.border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TalyerSpacing.x4,
          vertical: TalyerSpacing.x4,
        ),
        hintStyle: TalyerType.bodyLarge.copyWith(color: c.text3),
        labelStyle: TalyerType.bodyMedium.copyWith(color: c.text2),
        enabledBorder: OutlineInputBorder(
          borderRadius: TalyerRadii.all(TalyerRadii.sm),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TalyerRadii.all(TalyerRadii.sm),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TalyerRadii.all(TalyerRadii.sm),
          borderSide: BorderSide(color: c.emergency),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: TalyerRadii.all(TalyerRadii.sm),
          borderSide: BorderSide(color: c.emergency, width: 2),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: TalyerRadii.sheet),
        showDragHandle: false,
      ),

      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceMuted,
        labelStyle: TalyerType.caption.copyWith(color: c.text2),
        side: BorderSide(color: c.border),
        shape: const StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            TalyerType.bodyMedium.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: TalyerRadii.all(TalyerRadii.sm)),
      ),
    );
  }
}

/// Ergonomic access: `context.talyer.primary`, `context.tt.titleMedium`.
extension TalyerThemeX on BuildContext {
  TalyerColors get talyer =>
      Theme.of(this).extension<TalyerColors>() ?? TalyerColors.light;
  TextTheme get tt => Theme.of(this).textTheme;
  ColorScheme get scheme => Theme.of(this).colorScheme;
}
