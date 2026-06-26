import 'package:flutter/material.dart';

import '../theme/talyer_theme.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Shows a Talyer-styled modal bottom sheet (rounded top, drag handle,
/// safe-area aware, scroll-controlled).
Future<T?> showTalyerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final t = context.talyer;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: t.surface,
    barrierColor: const Color(0x66000000),
    shape: const RoundedRectangleBorder(borderRadius: TalyerRadii.sheet),
    builder: (ctx) => SafeArea(top: false, child: builder(ctx)),
  );
}

/// Sheet header: drag handle, title, optional subtitle + close button.
class TalyerSheetHeader extends StatelessWidget {
  const TalyerSheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Column(
      children: [
        const SizedBox(height: TalyerSpacing.x3),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: t.borderStrong,
            borderRadius: TalyerRadii.all(TalyerRadii.pill),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(TalyerSpacing.x6, TalyerSpacing.x4,
              TalyerSpacing.x3, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TalyerType.titleLarge.copyWith(color: t.text1)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style:
                              TalyerType.bodyMedium.copyWith(color: t.text3)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: t.text3),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
