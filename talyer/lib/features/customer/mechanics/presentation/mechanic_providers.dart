import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_mechanic_repository.dart';
import '../domain/mechanic.dart';
import '../domain/mechanic_repository.dart';

/// Wires the contract to an implementation. Swap the override here (or in a
/// test/ProviderScope) to move from Fake → Firestore — nothing else changes.
final mechanicRepositoryProvider = Provider<MechanicRepository>(
  (ref) => const FakeMechanicRepository(),
);

/// Async read of nearby mechanics. The screen renders its `AsyncValue`
/// directly into skeleton / empty / error / data states.
final nearbyMechanicsProvider =
    FutureProvider.autoDispose<List<Mechanic>>((ref) {
  return ref.watch(mechanicRepositoryProvider).nearby();
});
