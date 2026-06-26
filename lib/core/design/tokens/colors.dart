import 'package:flutter/material.dart';

/// Talyer raw color palette + semantic tokens.
///
/// Brand strategy: **trust-teal leads, orange energizes.**
/// - Teal  `#3DB3A9` → brand identity; a deepened teal drives interactive fills
///   (so white text clears WCAG AA 4.5:1).
/// - Orange `#F97316` → energy / secondary CTA accent (uses dark ink on fills).
/// - Emergency red → activated for SOS / breakdown only.
/// - Brass → the "Verified Talyer" trust seal.
/// - Slate → neutrals.
///
/// All on-color pairings below are chosen to meet WCAG AA for their use
/// (normal text ≥ 4.5:1; large/icon ≥ 3:1).
abstract final class TalyerPalette {
  // Brand teal scale
  static const Color teal50 = Color(0xFFE8F6F5);
  static const Color teal100 = Color(0xFFD9F0ED);
  static const Color teal200 = Color(0xFF9FDDD7);
  static const Color teal300 = Color(0xFF5EEAD4); // dark-mode accent
  static const Color teal400 = Color(0xFF3DB3A9); // ★ brand identity teal
  static const Color teal500 = Color(0xFF1F8079); // interactive primary (AA on white text)
  static const Color teal600 = Color(0xFF18655F); // pressed
  static const Color teal700 = Color(0xFF0F4B47);
  static const Color teal900 = Color(0xFF06342F); // ink / on-container

  // Energy orange scale
  static const Color orange100 = Color(0xFFFFF7ED);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C); // dark-mode accent
  static const Color orange500 = Color(0xFFF97316); // ★ accent
  static const Color orange600 = Color(0xFFEA580C); // pressed
  static const Color orange900 = Color(0xFF7C2D12); // ink

  // Emergency red
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red300 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFDC2626); // emergency (white text = 4.9:1)
  static const Color red600 = Color(0xFFB91C1C);
  static const Color red900 = Color(0xFF7F1D1D);

  // Brass / verified
  static const Color brass100 = Color(0xFFFBF1D9);
  static const Color brass400 = Color(0xFFD9B65C);
  static const Color brass500 = Color(0xFFB7892B); // seal
  static const Color brass700 = Color(0xFF6B4F12); // ink on brass100

  // Status
  static const Color green500 = Color(0xFF16A34A);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green800 = Color(0xFF166534);
  static const Color amber500 = Color(0xFFF59E0B); // warning + rating
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber800 = Color(0xFF92400E);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue800 = Color(0xFF1D4ED8);

  // Slate neutrals
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF0B1220);

  static const Color white = Color(0xFFFFFFFF);
}

/// Semantic color set. One instance per brightness; consumed by both the
/// Material [ColorScheme] and the [TalyerColors] theme extension so brand
/// tokens that Material doesn't model (brand teal, accent, emergency,
/// verified, status, 3-level text) stay first-class and themable.
@immutable
class TalyerColors extends ThemeExtension<TalyerColors> {
  const TalyerColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.border,
    required this.borderStrong,
    required this.brand,
    required this.primary,
    required this.onPrimary,
    required this.primaryPressed,
    required this.primaryBg,
    required this.primaryTx,
    required this.accent,
    required this.onAccent,
    required this.accentPressed,
    required this.accentBg,
    required this.emergency,
    required this.onEmergency,
    required this.emergencyBg,
    required this.emergencyTx,
    required this.verified,
    required this.onVerified,
    required this.verifiedBg,
    required this.verifiedTx,
    required this.success,
    required this.successBg,
    required this.successTx,
    required this.warning,
    required this.warningBg,
    required this.warningTx,
    required this.info,
    required this.infoBg,
    required this.infoTx,
    required this.rating,
  });

  final Brightness brightness;

  // Surfaces & text
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color text1; // primary text (AAA on surface)
  final Color text2; // secondary text (AA)
  final Color text3; // tertiary / captions
  final Color border;
  final Color borderStrong;

  // Brand teal
  final Color brand; // decorative identity teal (logo, badges)
  final Color primary; // interactive fills
  final Color onPrimary;
  final Color primaryPressed;
  final Color primaryBg; // tinted container
  final Color primaryTx; // text/icon on primaryBg

  // Energy orange
  final Color accent;
  final Color onAccent;
  final Color accentPressed;
  final Color accentBg;

  // Emergency
  final Color emergency;
  final Color onEmergency;
  final Color emergencyBg;
  final Color emergencyTx;

  // Verified seal (brass)
  final Color verified;
  final Color onVerified;
  final Color verifiedBg;
  final Color verifiedTx;

  // Status
  final Color success;
  final Color successBg;
  final Color successTx;
  final Color warning;
  final Color warningBg;
  final Color warningTx;
  final Color info;
  final Color infoBg;
  final Color infoTx;
  final Color rating;

  static const TalyerColors light = TalyerColors(
    brightness: Brightness.light,
    background: TalyerPalette.slate50,
    surface: TalyerPalette.white,
    surfaceMuted: TalyerPalette.slate100,
    surfaceRaised: TalyerPalette.slate200,
    text1: TalyerPalette.slate900,
    text2: TalyerPalette.slate600,
    text3: TalyerPalette.slate500,
    border: TalyerPalette.slate300,
    borderStrong: TalyerPalette.slate400,
    brand: TalyerPalette.teal400,
    primary: TalyerPalette.teal500,
    onPrimary: TalyerPalette.white,
    primaryPressed: TalyerPalette.teal600,
    primaryBg: TalyerPalette.teal50,
    primaryTx: TalyerPalette.teal700,
    accent: TalyerPalette.orange500,
    onAccent: TalyerPalette.slate900,
    accentPressed: TalyerPalette.orange600,
    accentBg: TalyerPalette.orange100,
    emergency: TalyerPalette.red500,
    onEmergency: TalyerPalette.white,
    emergencyBg: TalyerPalette.red100,
    emergencyTx: TalyerPalette.red600,
    verified: TalyerPalette.brass500,
    onVerified: TalyerPalette.white,
    verifiedBg: TalyerPalette.brass100,
    verifiedTx: TalyerPalette.brass700,
    success: TalyerPalette.green500,
    successBg: TalyerPalette.green100,
    successTx: TalyerPalette.green800,
    warning: TalyerPalette.amber500,
    warningBg: TalyerPalette.amber100,
    warningTx: TalyerPalette.amber800,
    info: TalyerPalette.blue500,
    infoBg: TalyerPalette.blue100,
    infoTx: TalyerPalette.blue800,
    rating: TalyerPalette.amber500,
  );

  static const TalyerColors dark = TalyerColors(
    brightness: Brightness.dark,
    background: TalyerPalette.slate950,
    surface: Color(0xFF111827),
    surfaceMuted: TalyerPalette.slate800,
    surfaceRaised: TalyerPalette.slate700,
    text1: TalyerPalette.slate50,
    text2: TalyerPalette.slate300,
    text3: TalyerPalette.slate400,
    border: TalyerPalette.slate700,
    borderStrong: TalyerPalette.slate600,
    brand: TalyerPalette.teal300,
    primary: TalyerPalette.teal300,
    onPrimary: TalyerPalette.teal900,
    primaryPressed: TalyerPalette.teal200,
    primaryBg: Color(0xFF0E3B37),
    primaryTx: TalyerPalette.teal200,
    accent: TalyerPalette.orange400,
    onAccent: TalyerPalette.slate900,
    accentPressed: TalyerPalette.orange300,
    accentBg: Color(0xFF431407),
    emergency: TalyerPalette.red300,
    onEmergency: TalyerPalette.slate900,
    emergencyBg: Color(0xFF450A0A),
    emergencyTx: Color(0xFFFCA5A5),
    verified: TalyerPalette.brass400,
    onVerified: TalyerPalette.slate900,
    verifiedBg: Color(0xFF3A2E12),
    verifiedTx: Color(0xFFF3E2B3),
    success: Color(0xFF4ADE80),
    successBg: Color(0xFF052E16),
    successTx: Color(0xFFBBF7D0),
    warning: Color(0xFFFBBF24),
    warningBg: Color(0xFF451A03),
    warningTx: Color(0xFFFDE68A),
    info: Color(0xFF60A5FA),
    infoBg: Color(0xFF172554),
    infoTx: Color(0xFFBFDBFE),
    rating: Color(0xFFFBBF24),
  );

  bool get isDark => brightness == Brightness.dark;

  @override
  TalyerColors copyWith({Brightness? brightness}) => this; // tokens are fixed sets

  @override
  TalyerColors lerp(ThemeExtension<TalyerColors>? other, double t) {
    if (other is! TalyerColors) return this;
    return t < 0.5 ? this : other;
  }
}
