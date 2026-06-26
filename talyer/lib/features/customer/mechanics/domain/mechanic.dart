/// Domain entity — pure Dart, no Flutter/Firebase. The data layer maps
/// Firestore documents into this; the UI only ever sees this type.
class Mechanic {
  const Mechanic({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.etaMinutes,
    required this.priceFrom,
    this.verified = true,
  });

  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final double distanceKm;
  final int etaMinutes;
  final String priceFrom;
  final bool verified;

  Mechanic copyWith({double? distanceKm, int? etaMinutes}) => Mechanic(
        id: id,
        name: name,
        specialization: specialization,
        rating: rating,
        reviews: reviews,
        distanceKm: distanceKm ?? this.distanceKm,
        etaMinutes: etaMinutes ?? this.etaMinutes,
        priceFrom: priceFrom,
        verified: verified,
      );
}
