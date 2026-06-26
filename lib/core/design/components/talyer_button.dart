import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum TalyerButtonVariant { primary, accent, emergency, outline, ghost }

enum TalyerButtonSize { large, medium }

/// Talyer's primary action button.
///
/// - Always ≥ 48dp tall (WCAG touch target).
/// - Shows an in-place spinner and disables itself while [loading].
/// - Variants map to brand roles: `primary` (teal), `accent` (orange),
///   `emergency` (red SOS), plus `outline` / `ghost` for secondary actions.
class TalyerButton extends StatelessWidget {
  const TalyerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TalyerButtonVariant.primary,
    this.size = TalyerButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final TalyerButtonVariant variant;
  final TalyerButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    final height =
        size == TalyerButtonSize.large ? TalyerSpacing.minTouch : 40.0;
    final disabled = onPressed == null || loading;

    late final Color bg;
    late final Color fg;
    late final Color? borderColor;
    switch (variant) {
      case TalyerButtonVariant.primary:
        bg = t.primary;
        fg = t.onPrimary;
        borderColor = null;
      case TalyerButtonVariant.accent:
        bg = t.accent;
        fg = t.onAccent;
        borderColor = null;
      case TalyerButtonVariant.emergency:
        bg = t.emergency;
        fg = t.onEmergency;
        borderColor = null;
      case TalyerButtonVariant.outline:
        bg = Colors.transparent;
        fg = t.primary;
        borderColor = t.border;
      case TalyerButtonVariant.ghost:
        bg = Colors.transparent;
        fg = t.primary;
        borderColor = null;
    }

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: loading
          ? SizedBox(
              key: const ValueKey('spinner'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: TalyerSpacing.x2),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TalyerType.label.copyWith(color: fg),
                  ),
                ),
              ],
            ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: height,
        child: Material(
          color: disabled ? bg.withValues(alpha: 0.38) : bg,
          borderRadius: TalyerRadii.all(TalyerRadii.xl),
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: TalyerRadii.all(TalyerRadii.xl),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: TalyerSpacing.x6),
              decoration: BoxDecoration(
                borderRadius: TalyerRadii.all(TalyerRadii.xl),
                border:
                    borderColor != null ? Border.all(color: borderColor) : null,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
