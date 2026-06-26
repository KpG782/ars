import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'rating_stars.dart';
import 'status_chip.dart';
import 'talyer_card.dart';
import 'verified_badge.dart';

/// The trust-forward mechanic result card: avatar, name + Verified seal,
/// specialization, rating, distance/ETA and an upfront price. This is the
/// single highest-leverage surface for converting the customer — it makes
/// the otherwise-invisible verification visible.
class MechanicCard extends StatelessWidget {
  const MechanicCard({
    super.key,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.etaMinutes,
    this.priceFrom,
    this.verified = true,
    this.initials,
    this.onTap,
  });

  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final double distanceKm;
  final int etaMinutes;
  final String? priceFrom;
  final bool verified;
  final String? initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return TalyerCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.brand.withValues(alpha: 0.15),
                  borderRadius: TalyerRadii.all(TalyerRadii.sm),
                ),
                child: Text(
                  initials ?? _initials(name),
                  style: TalyerType.titleMedium.copyWith(color: t.primaryTx),
                ),
              ),
              const SizedBox(width: TalyerSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(name,
                              style: TalyerType.titleMedium
                                  .copyWith(color: t.text1),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (verified) ...[
                          const SizedBox(width: TalyerSpacing.x2),
                          const VerifiedBadge(compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(specialization,
                        style: TalyerType.caption.copyWith(color: t.text3)),
                    const SizedBox(height: TalyerSpacing.x2),
                    RatingStars(value: rating, count: reviews),
                  ],
                ),
              ),
              if (priceFrom != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('from',
                        style: TalyerType.caption.copyWith(color: t.text3)),
                    Text(priceFrom!,
                        style:
                            TalyerType.titleMedium.copyWith(color: t.text1)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: TalyerSpacing.x3),
          Row(
            children: [
              StatusChip('${distanceKm.toStringAsFixed(1)} km',
                  icon: Icons.near_me_rounded, tone: StatusTone.neutral),
              const SizedBox(width: TalyerSpacing.x2),
              StatusChip('$etaMinutes min away',
                  icon: Icons.schedule_rounded, tone: StatusTone.primary),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
