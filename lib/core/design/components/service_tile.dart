import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'talyer_card.dart';

/// Selectable service option (Tire / Brake / Engine / Other …).
///
/// Surfaces an estimated price range at the point of choice — the
/// "no-surprise pricing" promise, shown before booking.
class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.tint,
    this.priceRange,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? tint;
  final String? priceRange;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    final accent = tint ?? t.primary;
    return TalyerCard(
      onTap: onTap,
      selected: selected,
      elevated: false,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: selected ? 0.18 : 0.10),
              borderRadius: TalyerRadii.all(TalyerRadii.sm),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: TalyerSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TalyerType.titleMedium.copyWith(color: t.text1)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TalyerType.caption.copyWith(color: t.text3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (priceRange != null) ...[
                  const SizedBox(height: TalyerSpacing.x2),
                  Text('Est. $priceRange',
                      style: TalyerType.titleSmall.copyWith(color: t.primaryTx)),
                ],
              ],
            ),
          ),
          const SizedBox(width: TalyerSpacing.x2),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            color: selected ? t.primary : t.text3,
          ),
        ],
      ),
    );
  }
}
