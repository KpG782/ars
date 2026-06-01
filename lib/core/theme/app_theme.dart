import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ─── Backward-Compatible Color Aliases ─────────────────────────
  // Prefer ArsLightColors/ArsDarkColors for new code. These aliases keep
  // existing screens compiling while the feature-level migration continues.
  static const Color primaryColor = ArsLightColors.primary;
  static const Color primaryLight = ArsLightColors.primaryBg;
  static const Color primaryDark = ArsLightColors.primaryPressed;
  static const Color primarySurface = ArsLightColors.primaryBg;

  static const Color secondaryColor = ArsLightColors.trust;
  static const Color accentYellow = ArsLightColors.warning;

  static const Color surfaceColor = ArsLightColors.background;
  static const Color cardColor = ArsLightColors.surface;
  static const Color onSurfaceColor = ArsLightColors.text1;
  static const Color subtitleColor = ArsLightColors.text2;
  static const Color borderColor = ArsLightColors.border;
  static const Color errorColor = ArsLightColors.emergency;
  static const Color successColor = ArsLightColors.success;

  static const Color onPrimaryColor = ArsLightColors.onPrimary;
  static const Color emergencyColor = ArsLightColors.emergency;
  static const Color warningColor = ArsLightColors.warning;
  static const Color infoColor = ArsLightColors.info;
  static const Color trustColor = ArsLightColors.trust;
  static const Color emergencyBg = ArsLightColors.emergencyBg;
  static const Color emergencyTx = ArsLightColors.emergencyTx;
  static const Color warningBg = ArsLightColors.warningBg;
  static const Color warningTx = ArsLightColors.warningTx;
  static const Color infoBg = ArsLightColors.infoBg;
  static const Color infoTx = ArsLightColors.infoTx;
  static const Color trustBg = ArsLightColors.trustBg;
  static const Color trustTx = ArsLightColors.trustTx;
  static const Color successBg = ArsLightColors.successBg;
  static const Color successTx = ArsLightColors.successTx;

  static const Color grey = ArsLightColors.text3;
  static const Color grey50 = ArsLightColors.background;
  static const Color grey100 = ArsLightColors.surfaceMuted;
  static const Color grey200 = ArsLightColors.border;
  static const Color grey300 = ArsLightColors.border;
  static const Color grey400 = ArsLightColors.borderStrong;
  static const Color grey500 = ArsLightColors.text3;
  static const Color grey600 = ArsLightColors.text2;
  static const Color grey700 = ArsLightColors.text1;
  static const Color grey800 = ArsLightColors.inverseSurface;

  static const Color red = ArsLightColors.emergency;
  static const Color red50 = ArsLightColors.emergencyBg;
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red700 = ArsLightColors.emergencyPressed;
  static const Color red900 = ArsLightColors.emergencyTx;

  static const Color green = ArsLightColors.success;
  static const Color green50 = ArsLightColors.successBg;
  static const Color green600 = ArsLightColors.success;
  static const Color green700 = ArsLightColors.successTx;

  static const Color orange = ArsLightColors.warning;
  static const Color orange50 = Color(0xFFFFFBEB);
  static const Color orange100 = ArsLightColors.warningBg;
  static const Color orange700 = Color(0xFFB45309);
  static const Color orange900 = ArsLightColors.warningTx;

  static const Color blue = ArsLightColors.info;
  static const Color blue50 = ArsLightColors.infoBg;
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue700 = ArsLightColors.infoTx;

  static const double fontSize10 = 10;
  static const double fontSize11 = 11;
  static const double fontSize11_5 = 11.5;
  static const double fontSize12 = 12;
  static const double fontSize13 = 13;
  static const double fontSize13_5 = 13.5;
  static const double fontSize14 = 14;
  static const double fontSize15 = 15;
  static const double fontSize15_5 = 15.5;
  static const double fontSize16 = 16;
  static const double fontSize17 = 17;
  static const double fontSize18 = 18;
  static const double fontSize20 = 20;
  static const double fontSize22 = 22;
  static const double fontSize24 = 24;
  static const double fontSize26 = 26;
  static const double fontSize28 = 28;
  static const double fontSize32 = 32;
  static const double fontSize36 = 36;
  static const double fontSize40 = 40;
  static const double fontSize45 = 45;
  static const double fontSize48 = 48;
  static const double fontSize56 = 56;
  static const double fontSize57 = 57;

  // ─── Text Style Aliases ────────────────────────────────────────
  static TextStyle figtreeRegular = AppTypography.figtree(
    fontWeight: FontWeight.w400,
  );

  static TextStyle figtreeMedium = AppTypography.figtree(
    fontWeight: FontWeight.w500,
  );

  static TextStyle figtreeSemiBold = AppTypography.figtree(
    fontWeight: FontWeight.w600,
  );

  static TextStyle figtreeBold = AppTypography.figtree(
    fontWeight: FontWeight.w700,
  );

  static TextStyle figtreeExtraBold = AppTypography.figtree(
    fontWeight: FontWeight.w800,
  );

  static TextStyle figtreeBlack = AppTypography.figtree(
    fontWeight: FontWeight.w900,
  );

  static TextStyle splashScreenTitle = figtreeBlack.copyWith(
    fontSize: 48,
    height: 56 / 48,
    color: onSurfaceColor,
  );

  static TextStyle splashScreenSubtitle = figtreeRegular.copyWith(
    fontSize: 16,
    height: 24 / 16,
    color: subtitleColor,
  );

  static TextStyle appBarTitle = figtreeSemiBold.copyWith(
    fontSize: 22,
    height: 28 / 22,
    color: onSurfaceColor,
  );

  static TextStyle headlineLarge = figtreeSemiBold.copyWith(
    fontSize: 32,
    height: 40 / 32,
    color: onSurfaceColor,
  );
  static TextStyle headlineMedium = figtreeSemiBold.copyWith(
    fontSize: 28,
    height: 36 / 28,
    color: onSurfaceColor,
  );
  static TextStyle headlineSmall = figtreeSemiBold.copyWith(
    fontSize: 24,
    height: 32 / 24,
    color: onSurfaceColor,
  );

  static TextStyle bodyLarge = figtreeRegular.copyWith(
    fontSize: 16,
    height: 24 / 16,
    color: onSurfaceColor,
  );
  static TextStyle bodyMedium = figtreeRegular.copyWith(
    fontSize: 14,
    height: 20 / 14,
    color: subtitleColor,
  );
  static TextStyle bodySmall = figtreeRegular.copyWith(
    fontSize: 12,
    height: 18 / 12,
    color: subtitleColor,
  );

  static TextStyle buttonLarge = figtreeSemiBold.copyWith(
    fontSize: 14,
    height: 18 / 14,
  );
  static TextStyle buttonMedium = figtreeSemiBold.copyWith(
    fontSize: 14,
    height: 18 / 14,
  );

  static TextStyle labelLarge = figtreeSemiBold.copyWith(
    fontSize: 14,
    height: 18 / 14,
  );
  static TextStyle labelMedium = figtreeMedium.copyWith(
    fontSize: 12,
    height: 16 / 12,
    color: subtitleColor,
  );

  static TextStyle titleMedium = figtreeSemiBold.copyWith(
    fontSize: 16,
    height: 24 / 16,
    color: onSurfaceColor,
  );

  static ThemeData get themeData => lightTheme;

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      colors: _ThemeColors.light(),
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: _ThemeColors.dark(),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required _ThemeColors colors,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: brightness,
        ).copyWith(
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          primaryContainer: colors.primaryBg,
          onPrimaryContainer: colors.primaryTx,
          secondary: colors.trust,
          onSecondary: colors.onTrust,
          secondaryContainer: colors.trustBg,
          onSecondaryContainer: colors.trustTx,
          tertiary: colors.info,
          onTertiary: colors.onInfo,
          tertiaryContainer: colors.infoBg,
          onTertiaryContainer: colors.infoTx,
          error: colors.emergency,
          onError: colors.onEmergency,
          errorContainer: colors.emergencyBg,
          onErrorContainer: colors.emergencyTx,
          surface: colors.surface,
          onSurface: colors.text1,
          outline: colors.border,
          outlineVariant: colors.borderStrong,
          shadow: Colors.black,
        );

    final textTheme = AppTypography.textTheme(
      colors.text1,
      colors.text2,
      colors.text3,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.border,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colors.text2, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text1,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colors.text1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withAlpha(96),
          disabledForegroundColor: colors.onPrimary.withAlpha(128),
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withAlpha(96),
          disabledForegroundColor: colors.onPrimary.withAlpha(128),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.text1,
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.emergency, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colors.emergency, width: 2),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(color: colors.text2),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.text3),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colors.border),
        ),
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceMuted,
        selectedColor: colors.primaryBg,
        disabledColor: colors.surfaceRaised,
        labelStyle: textTheme.labelMedium?.copyWith(color: colors.text2),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.primaryTx,
        ),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }
}

class _ThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color onPrimary;
  final Color primaryBg;
  final Color primaryTx;
  final Color emergency;
  final Color onEmergency;
  final Color emergencyBg;
  final Color emergencyTx;
  final Color trust;
  final Color onTrust;
  final Color trustBg;
  final Color trustTx;
  final Color info;
  final Color onInfo;
  final Color infoBg;
  final Color infoTx;
  final Color inverseSurface;
  final Color onInverseSurface;

  const _ThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.onPrimary,
    required this.primaryBg,
    required this.primaryTx,
    required this.emergency,
    required this.onEmergency,
    required this.emergencyBg,
    required this.emergencyTx,
    required this.trust,
    required this.onTrust,
    required this.trustBg,
    required this.trustTx,
    required this.info,
    required this.onInfo,
    required this.infoBg,
    required this.infoTx,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  factory _ThemeColors.light() => const _ThemeColors(
    background: ArsLightColors.background,
    surface: ArsLightColors.surface,
    surfaceMuted: ArsLightColors.surfaceMuted,
    surfaceRaised: ArsLightColors.surfaceRaised,
    text1: ArsLightColors.text1,
    text2: ArsLightColors.text2,
    text3: ArsLightColors.text3,
    border: ArsLightColors.border,
    borderStrong: ArsLightColors.borderStrong,
    primary: ArsLightColors.primary,
    onPrimary: ArsLightColors.onPrimary,
    primaryBg: ArsLightColors.primaryBg,
    primaryTx: ArsLightColors.primaryTx,
    emergency: ArsLightColors.emergency,
    onEmergency: ArsLightColors.onEmergency,
    emergencyBg: ArsLightColors.emergencyBg,
    emergencyTx: ArsLightColors.emergencyTx,
    trust: ArsLightColors.trust,
    onTrust: ArsLightColors.onTrust,
    trustBg: ArsLightColors.trustBg,
    trustTx: ArsLightColors.trustTx,
    info: ArsLightColors.info,
    onInfo: ArsLightColors.onInfo,
    infoBg: ArsLightColors.infoBg,
    infoTx: ArsLightColors.infoTx,
    inverseSurface: ArsLightColors.inverseSurface,
    onInverseSurface: ArsLightColors.onInverseSurface,
  );

  factory _ThemeColors.dark() => const _ThemeColors(
    background: ArsDarkColors.background,
    surface: ArsDarkColors.surface,
    surfaceMuted: ArsDarkColors.surfaceMuted,
    surfaceRaised: ArsDarkColors.surfaceRaised,
    text1: ArsDarkColors.text1,
    text2: ArsDarkColors.text2,
    text3: ArsDarkColors.text3,
    border: ArsDarkColors.border,
    borderStrong: ArsDarkColors.borderStrong,
    primary: ArsDarkColors.primary,
    onPrimary: ArsDarkColors.onPrimary,
    primaryBg: ArsDarkColors.primaryBg,
    primaryTx: ArsDarkColors.primaryTx,
    emergency: ArsDarkColors.emergency,
    onEmergency: ArsDarkColors.onEmergency,
    emergencyBg: ArsDarkColors.emergencyBg,
    emergencyTx: ArsDarkColors.emergencyTx,
    trust: ArsDarkColors.trust,
    onTrust: ArsDarkColors.onTrust,
    trustBg: ArsDarkColors.trustBg,
    trustTx: ArsDarkColors.trustTx,
    info: ArsDarkColors.info,
    onInfo: ArsDarkColors.onInfo,
    infoBg: ArsDarkColors.infoBg,
    infoTx: ArsDarkColors.infoTx,
    inverseSurface: ArsDarkColors.inverseSurface,
    onInverseSurface: ArsDarkColors.onInverseSurface,
  );
}
