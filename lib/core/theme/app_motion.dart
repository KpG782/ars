import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
}
