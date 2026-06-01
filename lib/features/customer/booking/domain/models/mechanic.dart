/// Domain Model: Mechanic
///
/// Represents a mechanic available for service requests
library;

import 'package:latlong2/latlong.dart';

/// Mechanic entity in the business domain
class Mechanic {
  final String id;
  final String name;
  final LatLng location;
  final int etaMinutes;
  final String? phoneNumber;
  final double rating;
  final String? photoUrl;
  final bool isAvailable;
  final List<String> specializations;

  Mechanic({
    required this.id,
    required this.name,
    required this.location,
    required this.etaMinutes,
    this.phoneNumber,
    this.rating = 0.0,
    this.photoUrl,
    this.isAvailable = true,
    this.specializations = const [],
  });

  // Business logic: Check if mechanic is highly rated
  bool get isHighlyRated => rating >= 4.5;

  // Business logic: Check if mechanic is nearby (within 10 mins)
  bool get isNearby => etaMinutes <= 10;

  // Business logic: Check if mechanic can accept requests
  bool get canAcceptRequests => isAvailable;

  // Business logic: Format ETA for display
  String get formattedETA {
    if (etaMinutes < 60) {
      return '$etaMinutes min';
    }
    final hours = etaMinutes ~/ 60;
    final minutes = etaMinutes % 60;
    return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
  }

  Mechanic copyWith({
    String? id,
    String? name,
    LatLng? location,
    int? etaMinutes,
    String? phoneNumber,
    double? rating,
    String? photoUrl,
    bool? isAvailable,
    List<String>? specializations,
  }) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      photoUrl: photoUrl ?? this.photoUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      specializations: specializations ?? this.specializations,
    );
  }

  factory Mechanic.fromFirestore(Map<String, dynamic> data, String docId) {
    final locMap = data['location'] as Map<String, dynamic>? ?? {};
    return Mechanic(
      id: docId,
      name: data['fullName'] as String? ?? data['name'] as String? ?? 'Unknown',
      location: LatLng(
        (locMap['lat'] as num?)?.toDouble() ?? 14.5995,
        (locMap['lng'] as num?)?.toDouble() ?? 120.9842,
      ),
      etaMinutes: data['etaMinutes'] as int? ?? 0,
      phoneNumber: data['phoneNumber'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      photoUrl: data['profilePhotoUrl'] as String?,
      isAvailable: data['isOnline'] as bool? ?? false,
      specializations: List<String>.from(
        data['specializations'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'isOnline': isAvailable,
      'rating': rating,
      'specializations': specializations,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': photoUrl,
    };
  }
}
