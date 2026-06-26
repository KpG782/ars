import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'talyer_button.dart';

/// A degraded/empty state that always offers the next action — Talyer never
/// leaves the user at a silent dead-end (the most-hit "no mechanic available"
/// case included). Pair [title]/[message] with an [actionLabel] + [onAction].
class TalyerEmptyState extends StatelessWidget {
  const TalyerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.tone = _Tone.neutral,
  });

  /// Convenience for the launch-critical "no mechanic available" state.
  factory TalyerEmptyState.noMechanic({
    VoidCallback? onNotify,
    VoidCallback? onWiden,
  }) =>
      TalyerEmptyState(
        icon: Icons.handyman_outlined,
        title: 'Walang available na Talyer ngayon dito.',
        message:
            "We'll ping you the moment one's free — or try a wider area.",
        actionLabel: 'Notify me',
        onAction: onNotify,
        secondaryLabel: 'Widen search',
        onSecondary: onWiden,
        tone: _Tone.warning,
      );

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    final accent = tone == _Tone.warning ? t.warning : t.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TalyerSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: TalyerRadii.all(TalyerRadii.lg),
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: TalyerSpacing.x5),
            Text(title,
                textAlign: TextAlign.center,
                style: TalyerType.titleLarge.copyWith(color: t.text1)),
            const SizedBox(height: TalyerSpacing.x2),
            Text(message,
                textAlign: TextAlign.center,
                style: TalyerType.bodyMedium.copyWith(color: t.text2)),
            if (actionLabel != null) ...[
              const SizedBox(height: TalyerSpacing.x6),
              TalyerButton(label: actionLabel!, onPressed: onAction),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: TalyerSpacing.x3),
              TalyerButton(
                label: secondaryLabel!,
                onPressed: onSecondary,
                variant: TalyerButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Tone { neutral, warning }
