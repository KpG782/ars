import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Semantic tone for a [StatusChip]. Colour is paired with an icon/label so
/// status is never communicated by colour alone (accessibility).
enum StatusTone { neutral, primary, success, warning, info, emergency, verified }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = StatusTone.neutral, this.icon});

  final String label;
  final StatusTone tone;
  final IconData? icon;

  ({Color bg, Color fg}) _colors(TalyerColors t) {
    switch (tone) {
      case StatusTone.primary:
        return (bg: t.primaryBg, fg: t.primaryTx);
      case StatusTone.success:
        return (bg: t.successBg, fg: t.successTx);
      case StatusTone.warning:
        return (bg: t.warningBg, fg: t.warningTx);
      case StatusTone.info:
        return (bg: t.infoBg, fg: t.infoTx);
      case StatusTone.emergency:
        return (bg: t.emergencyBg, fg: t.emergencyTx);
      case StatusTone.verified:
        return (bg: t.verifiedBg, fg: t.verifiedTx);
      case StatusTone.neutral:
        return (bg: t.surfaceMuted, fg: t.text2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors(context.talyer);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TalyerSpacing.x3, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: TalyerRadii.all(TalyerRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c.fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: TalyerType.overline.copyWith(color: c.fg)),
        ],
      ),
    );
  }
}
