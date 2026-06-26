import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/elevation.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';

/// Calm, bordered surface card. Optional [onTap] makes it a tappable
/// surface with ink feedback (and a pointer-style affordance).
class TalyerCard extends StatelessWidget {
  const TalyerCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(TalyerSpacing.x4),
    this.selected = false,
    this.elevated = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool selected;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? t.primaryBg : t.surface,
        borderRadius: TalyerRadii.card,
        border: Border.all(
          color: selected ? t.primary : t.border,
          width: selected ? 2 : 1,
        ),
        boxShadow: elevated && !selected
            ? TalyerElevation.card(t.brightness)
            : const [],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TalyerRadii.card,
        child: content,
      ),
    );
  }
}
