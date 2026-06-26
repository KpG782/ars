import 'package:flutter/widgets.dart';

/// Corner radius scale.
abstract final class TalyerRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16; // cards
  static const double lg = 20; // bottom sheets
  static const double xl = 28; // pill buttons
  static const double pill = 999;

  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);

  static BorderRadius all(double r) => BorderRadius.circular(r);
  static const BorderRadius card = BorderRadius.all(rMd);
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(lg));
}
