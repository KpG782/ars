import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/elevation.dart';
import '../tokens/radii.dart';

/// The Talyer app mark: a rounded teal tile with a wrench glyph and a small
/// orange "ready" notch. Signals fix + trust + speed; deliberately avoids any
/// moto-taxi / helmet cue (the rideshare-clone tell).
class TalyerMark extends StatelessWidget {
  const TalyerMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.brand, t.primary],
        ),
        borderRadius: TalyerRadii.all(size * 0.26),
        boxShadow: TalyerElevation.fab(t.brightness),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.handyman_rounded, color: Colors.white, size: size * 0.5),
          Positioned(
            right: size * 0.18,
            top: size * 0.18,
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
