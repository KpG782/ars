import 'mechanic.dart';

/// Domain contract. `presentation` and use cases depend on THIS, never on a
/// concrete data source — so a Fake (today) and a Firestore impl (Phase 1) are
/// interchangeable without touching a screen.
abstract interface class MechanicRepository {
  /// Verified, available mechanics near the user, nearest-first.
  /// [serviceType] optionally filters by specialization.
  Future<List<Mechanic>> nearby({String? serviceType});
}
