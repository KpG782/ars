import 'package:flutter/material.dart';

/// Soft, low-alpha shadows. Talyer leans on borders + tint over heavy
/// elevation; shadows stay subtle so cards feel calm and trustworthy.
abstract final class TalyerElevation {
  static List<BoxShadow> card(Brightness b) => b == Brightness.dark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0F0F172A), // slate-900 @ ~6%
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ];

  static List<BoxShadow> sheet(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, -6)),
        ]
      : const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 24, offset: Offset(0, -6)),
        ];

  static List<BoxShadow> fab(Brightness b) => const [
        BoxShadow(color: Color(0x331F8079), blurRadius: 16, offset: Offset(0, 6)),
      ];
}
