import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import 'mechanic_providers.dart';

/// Reference feature slice: domain → repository interface → (fake) data →
/// Riverpod → design-system UI, with every async state designed. This is the
/// pattern every migrated feature follows.
class FindMechanicScreen extends ConsumerWidget {
  const FindMechanicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nearbyMechanicsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verified Talyer near you')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(nearbyMechanicsProvider.future),
        child: async.when(
          loading: () => const _SkeletonList(),
          error: (e, _) => _ErrorState(
            onRetry: () => ref.invalidate(nearbyMechanicsProvider),
          ),
          data: (mechanics) {
            if (mechanics.isEmpty) {
              return TalyerEmptyState.noMechanic(
                onNotify: () {},
                onWiden: () => ref.invalidate(nearbyMechanicsProvider),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(TalyerSpacing.screen),
              itemCount: mechanics.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: TalyerSpacing.x3),
              itemBuilder: (_, i) {
                final m = mechanics[i];
                return MechanicCard(
                  name: m.name,
                  specialization: m.specialization,
                  rating: m.rating,
                  reviews: m.reviews,
                  distanceKm: m.distanceKm,
                  etaMinutes: m.etaMinutes,
                  priceFrom: m.priceFrom,
                  verified: m.verified,
                  onTap: () {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return ListView.separated(
      padding: const EdgeInsets.all(TalyerSpacing.screen),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: TalyerSpacing.x3),
      itemBuilder: (_, __) => Container(
        height: 132,
        decoration: BoxDecoration(
          color: t.surfaceMuted,
          borderRadius: TalyerRadii.card,
          border: Border.all(color: t.border),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        TalyerEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Hmm, may problema sa koneksyon.',
          message: "Check mo lang ang internet at subukan ulit.",
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
      ],
    );
  }
}
