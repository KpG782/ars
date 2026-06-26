import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/typography.dart';

/// Compact rating display: star + numeric value + optional review count.
/// Pass [count] so a single 5.0 review never outranks a seasoned 4.7.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, this.count, this.size = 15});

  final double value;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Semantics(
      label: count == null
          ? '$value out of 5 stars'
          : '$value out of 5 stars, $count reviews',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: size + 2, color: t.rating),
          const SizedBox(width: 3),
          Text(value.toStringAsFixed(1),
              style: TalyerType.titleSmall.copyWith(color: t.text1)),
          if (count != null) ...[
            const SizedBox(width: 3),
            Text('($count)',
                style: TalyerType.caption.copyWith(color: t.text3)),
          ],
        ],
      ),
    );
  }
}
