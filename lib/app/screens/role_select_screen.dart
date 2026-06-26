import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../router.dart';

/// "Who are you?" role selection, written in Talyer's Taglish-for-warmth /
/// English-for-trust voice. Demonstrates the design system in a real screen.
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _role;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TalyerSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TalyerSpacing.x8),
              const Center(child: TalyerMark(size: 56)),
              const SizedBox(height: TalyerSpacing.x6),
              Text('Sino ka?',
                  textAlign: TextAlign.center, style: context.tt.displaySmall),
              const SizedBox(height: TalyerSpacing.x2),
              Text('Pumili ng role para sa tamang karanasan.',
                  textAlign: TextAlign.center,
                  style: TalyerType.bodyMedium.copyWith(color: t.text2)),
              const SizedBox(height: TalyerSpacing.x8),
              _RoleCard(
                icon: Icons.directions_car_filled_rounded,
                title: 'Magpa-ayos',
                subtitle: 'Find a verified Talyer near you.',
                selected: _role == 'customer',
                onTap: () => setState(() => _role = 'customer'),
              ),
              const SizedBox(height: TalyerSpacing.x4),
              _RoleCard(
                icon: Icons.handyman_rounded,
                title: 'Maging Talyer',
                subtitle: 'Get verified, get jobs, keep 100% of parts cost.',
                selected: _role == 'mechanic',
                onTap: () => setState(() => _role = 'mechanic'),
              ),
              const Spacer(),
              TalyerButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _role == null ? null : () => context.go(Routes.gallery),
              ),
              const SizedBox(height: TalyerSpacing.x4),
              Center(
                child: TextButton(
                  onPressed: () => context.go(Routes.gallery),
                  child: const Text('View the design system →'),
                ),
              ),
              const SizedBox(height: TalyerSpacing.x6),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return TalyerCard(
      onTap: onTap,
      selected: selected,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? t.primary.withValues(alpha: 0.15)
                  : t.surfaceMuted,
              borderRadius: TalyerRadii.all(TalyerRadii.sm),
            ),
            child: Icon(icon,
                color: selected ? t.primary : t.text3, size: 24),
          ),
          const SizedBox(width: TalyerSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.tt.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TalyerType.caption.copyWith(color: t.text3)),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? t.primary : t.borderStrong,
          ),
        ],
      ),
    );
  }
}
