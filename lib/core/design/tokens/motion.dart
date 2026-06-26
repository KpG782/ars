import 'package:flutter/widgets.dart';

/// Motion tokens. Micro-interactions stay in the 150–300ms band; respect the
/// platform "reduce motion" setting via [respectReduceMotion].
abstract final class TalyerMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration page = Duration(milliseconds: 350);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  /// Returns [d], or [Duration.zero] when the user has asked the OS to
  /// reduce motion — so animations honour accessibility preferences.
  static Duration respectReduceMotion(BuildContext context, Duration d) =>
      MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : d;
}
