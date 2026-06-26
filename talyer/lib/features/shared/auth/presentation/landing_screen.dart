import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../app/router.dart';

/// Landing / welcome — the first screen a new user sees. Marketplace-trust
/// pattern: brand + value prop + trust signals + two clear CTAs (Get Started /
/// Log in). Owns the "verified mechanic" promise up front.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _trust = [
    (Icons.verified_rounded, 'Verified mechanics', 'TESDA-certified, licensed, ID-checked.'),
    (Icons.payments_rounded, 'No-surprise pricing', 'Approve the price before any work starts.'),
    (Icons.near_me_rounded, 'Anywhere, anytime', 'Roadside, home, or office — live ETA.'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TalyerSpacing.screen),
          child: Column(
            children: [
              const SizedBox(height: TalyerSpacing.x8),
              const TalyerMark(size: 72),
              const SizedBox(height: TalyerSpacing.x5),
              Text('Talyer', style: context.tt.displaySmall),
              const SizedBox(height: TalyerSpacing.x2),
              Text(
                'Sira ang sasakyan? May Talyer ka.',
                textAlign: TextAlign.center,
                style: TalyerType.bodyLarge.copyWith(color: t.text2),
              ),
              const SizedBox(height: TalyerSpacing.x8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (icon, title, body) in _trust) ...[
                      _TrustRow(icon: icon, title: title, body: body),
                      const SizedBox(height: TalyerSpacing.x5),
                    ],
                  ],
                ),
              ),
              TalyerButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go(Routes.signup),
              ),
              const SizedBox(height: TalyerSpacing.x3),
              TalyerButton(
                label: 'Log in',
                variant: TalyerButtonVariant.outline,
                onPressed: () => context.go(Routes.login),
              ),
              const SizedBox(height: TalyerSpacing.x4),
              Text(
                'Sa pag-sign up, sumasang-ayon ka sa aming Terms & Privacy Policy.',
                textAlign: TextAlign.center,
                style: TalyerType.caption.copyWith(color: t.text3),
              ),
              const SizedBox(height: TalyerSpacing.x5),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: t.primary.withValues(alpha: 0.12),
            borderRadius: TalyerRadii.all(TalyerRadii.sm),
          ),
          child: Icon(icon, color: t.primary, size: 22),
        ),
        const SizedBox(width: TalyerSpacing.x4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.tt.titleMedium),
              const SizedBox(height: 2),
              Text(body, style: TalyerType.bodyMedium.copyWith(color: t.text2)),
            ],
          ),
        ),
      ],
    );
  }
}
