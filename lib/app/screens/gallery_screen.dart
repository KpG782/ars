import 'package:flutter/material.dart';

import '../../core/design/design.dart';

/// Living style guide: renders every token and component so the design
/// system can be reviewed in the real engine (light + dark) at a glance.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talyer Design System'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: TalyerSpacing.x4),
            child: Center(
              child: StatusChip(t.isDark ? 'Dark' : 'Light',
                  icon: t.isDark ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TalyerSpacing.screen),
        children: [
          const _Section('Brand colours'),
          Wrap(
            spacing: TalyerSpacing.x3,
            runSpacing: TalyerSpacing.x3,
            children: [
              _Swatch('Brand', t.brand),
              _Swatch('Primary', t.primary),
              _Swatch('Accent', t.accent),
              _Swatch('Emergency', t.emergency),
              _Swatch('Verified', t.verified),
              _Swatch('Success', t.success),
              _Swatch('Warning', t.warning),
              _Swatch('Info', t.info),
            ],
          ),

          const _Section('Typography'),
          Text('Display Small', style: context.tt.displaySmall),
          Text('Headline', style: context.tt.headlineMedium),
          Text('Title Medium', style: context.tt.titleMedium),
          Text('Body large — Verified mechanics, on demand. No surprises.',
              style: context.tt.bodyLarge),
          Text('Caption / helper text', style: TalyerType.caption.copyWith(color: t.text3)),

          const _Section('Buttons'),
          const TalyerButton(label: 'Tawag ng Talyer', icon: Icons.handyman_rounded, onPressed: _noop),
          const SizedBox(height: TalyerSpacing.x3),
          Row(children: [
            Expanded(child: TalyerButton(label: 'Approve quote', variant: TalyerButtonVariant.accent, onPressed: _noop)),
            const SizedBox(width: TalyerSpacing.x3),
            Expanded(child: TalyerButton(label: 'SOS', variant: TalyerButtonVariant.emergency, icon: Icons.warning_amber_rounded, onPressed: _noop)),
          ]),
          const SizedBox(height: TalyerSpacing.x3),
          Row(children: [
            Expanded(child: TalyerButton(label: 'Outline', variant: TalyerButtonVariant.outline, onPressed: _noop)),
            const SizedBox(width: TalyerSpacing.x3),
            const Expanded(child: TalyerButton(label: 'Loading', loading: true)),
            const SizedBox(width: TalyerSpacing.x3),
            const Expanded(child: TalyerButton(label: 'Disabled')),
          ]),

          const _Section('Badges & status'),
          Wrap(spacing: TalyerSpacing.x2, runSpacing: TalyerSpacing.x2, children: const [
            VerifiedBadge(),
            StatusChip('En route', tone: StatusTone.primary, icon: Icons.navigation_rounded),
            StatusChip('Completed', tone: StatusTone.success, icon: Icons.check_rounded),
            StatusChip('Pending', tone: StatusTone.warning, icon: Icons.schedule_rounded),
            StatusChip('Emergency', tone: StatusTone.emergency, icon: Icons.warning_amber_rounded),
          ]),

          const _Section('Service tile'),
          ServiceTile(
            title: 'Tire Problem',
            subtitle: "Flat, busted, or damaged tires? We've got you covered.",
            icon: Icons.tire_repair_rounded,
            priceRange: '₱300–₱800',
            selected: true,
            onTap: _noop,
          ),

          const _Section('Mechanic card'),
          MechanicCard(
            name: 'Mang Ramon Dela Cruz',
            specialization: 'Engine • Brakes • Electrical',
            rating: 4.8,
            reviews: 213,
            distanceKm: 1.4,
            etaMinutes: 8,
            priceFrom: '₱350',
            onTap: _noop,
          ),

          const _Section('Input'),
          const TalyerTextField(
            label: 'Plate number',
            hint: 'ABC 1234',
            prefixIcon: Icons.pin_rounded,
            helper: 'Para mas mabilis ang booking.',
          ),

          const _Section('Bottom sheet'),
          TalyerButton(
            label: 'Open service sheet',
            variant: TalyerButtonVariant.outline,
            onPressed: () => showTalyerSheet(
              context: context,
              builder: (_) => const _DemoSheet(),
            ),
          ),

          const _Section('Empty / degraded state'),
          SizedBox(
            height: 360,
            child: TalyerEmptyState.noMechanic(onNotify: _noop, onWiden: _noop),
          ),
          const SizedBox(height: TalyerSpacing.x10),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _DemoSheet extends StatelessWidget {
  const _DemoSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TalyerSheetHeader(
          title: "Ano'ng kailangan ng sasakyan mo?",
          subtitle: 'Select a service to get an instant estimate.',
        ),
        Padding(
          padding: const EdgeInsets.all(TalyerSpacing.x6),
          child: Column(
            children: [
              ServiceTile(
                title: 'Brake Problem',
                subtitle: 'Squeaky or unresponsive brakes? Stay safe.',
                icon: Icons.car_crash_rounded,
                tint: context.talyer.warning,
                priceRange: '₱500–₱1,500',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: TalyerSpacing.x3),
              TalyerButton(label: 'Continue', onPressed: () => Navigator.of(context).maybePop()),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: TalyerSpacing.x8, bottom: TalyerSpacing.x4),
      child: Text(title.toUpperCase(),
          style: TalyerType.overline.copyWith(color: context.talyer.text3)),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: TalyerRadii.all(TalyerRadii.sm),
            border: Border.all(color: t.border),
          ),
        ),
        const SizedBox(height: TalyerSpacing.x1),
        Text(label, style: TalyerType.caption.copyWith(color: t.text2)),
      ],
    );
  }
}
