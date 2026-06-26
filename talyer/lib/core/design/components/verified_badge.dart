import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// The signature Talyer trust element: a brass "Verified Talyer" seal.
///
/// Surface it everywhere a mechanic appears (selection sheet, tracking,
/// chat header) — it converts the otherwise-invisible TESDA/license/ID
/// verification into a visible trust signal.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.label = 'Verified', this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Semantics(
      label: 'Verified Talyer mechanic',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? TalyerSpacing.x2 : TalyerSpacing.x3,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: t.verifiedBg,
          borderRadius: TalyerRadii.all(TalyerRadii.pill),
          border: Border.all(color: t.verified.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: compact ? 13 : 15, color: t.verified),
            if (!compact) const SizedBox(width: 4),
            if (!compact)
              Text(
                label,
                style: TalyerType.overline.copyWith(color: t.verifiedTx),
              ),
          ],
        ),
      ),
    );
  }
}
