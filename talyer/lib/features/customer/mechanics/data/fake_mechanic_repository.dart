import '../domain/mechanic.dart';
import '../domain/mechanic_repository.dart';

/// In-memory implementation so the app runs end-to-end with no backend.
/// Phase 1 replaces this with `FirestoreMechanicRepository` (geohash query on
/// `mechanics` where availability == available) — the screen does not change.
class FakeMechanicRepository implements MechanicRepository {
  const FakeMechanicRepository();

  static const _all = <Mechanic>[
    Mechanic(
      id: 'm1',
      name: 'Mang Ramon Dela Cruz',
      specialization: 'Engine • Brakes • Electrical',
      rating: 4.8,
      reviews: 213,
      distanceKm: 1.4,
      etaMinutes: 8,
      priceFrom: '₱350',
    ),
    Mechanic(
      id: 'm2',
      name: 'Jepoy Motoworks',
      specialization: 'Motorcycle • Tire • Battery',
      rating: 4.9,
      reviews: 96,
      distanceKm: 2.1,
      etaMinutes: 12,
      priceFrom: '₱250',
    ),
    Mechanic(
      id: 'm3',
      name: 'Aling Nena Auto Repair',
      specialization: 'Aircon • General Automotive',
      rating: 4.6,
      reviews: 154,
      distanceKm: 3.0,
      etaMinutes: 17,
      priceFrom: '₱400',
    ),
  ];

  @override
  Future<List<Mechanic>> nearby({String? serviceType}) async {
    // Simulate network latency so loading states are real.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final list = [..._all]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }
}
