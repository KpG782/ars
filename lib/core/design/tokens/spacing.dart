/// 4-point spacing scale. Use these instead of magic numbers.
abstract final class TalyerSpacing {
  static const double x0 = 0;
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16; // base gutter
  static const double x5 = 20;
  static const double x6 = 24; // screen padding
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;

  /// Default horizontal screen padding.
  static const double screen = x6;

  /// Minimum interactive target (WCAG / Material): 48dp.
  static const double minTouch = 48;
}
