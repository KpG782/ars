/// Domain Model: MechanicShop
///
/// Represents a mechanic shop in the business domain
library;

import 'package:latlong2/latlong.dart';

/// Mechanic shop entity
class MechanicShop {
  final String id;
  final String shopName;
  final LatLng location;
  final String address;
  final String phoneNumber;
  final List<String> services;
  final double rating;
  final int totalReviews;
  final String priceRange;
  final Map<String, String> operatingHours;
  final bool isOpen;
  final bool isPartner;
  final String? photoUrl;
  final String? description;
  final int availableMechanics;
  final String? owner;

  MechanicShop({
    required this.id,
    required this.shopName,
    required this.location,
    required this.address,
    required this.phoneNumber,
    required this.services,
    required this.rating,
    required this.totalReviews,
    required this.priceRange,
    required this.operatingHours,
    required this.isOpen,
    this.isPartner = false,
    this.photoUrl,
    this.description,
    this.availableMechanics = 0,
    this.owner,
  });

  // Business logic: Check if shop is highly rated
  bool get isHighlyRated => rating >= 4.5;

  // Business logic: Check if shop has good reviews
  bool get hasGoodReviews => totalReviews >= 50 && rating >= 4.0;

  // Business logic: Check if shop offers specific service
  bool offersService(String service) {
    return services.any((s) => s.toLowerCase().contains(service.toLowerCase()));
  }

  // Business logic: Check if shop is available
  bool get isAvailable => isOpen && availableMechanics > 0;

  // Business logic: Get today's hours
  String getTodayHours() {
    final now = DateTime.now();
    final day = _getDayName(now.weekday);
    return operatingHours[day] ?? 'Hours not available';
  }

  /// Get distance string from current position
  String getDistanceString(LatLng currentPosition) {
    const double earthRadius = 6371; // km
    final lat1 = currentPosition.latitude * (3.14159 / 180);
    final lon1 = currentPosition.longitude * (3.14159 / 180);
    final lat2 = location.latitude * (3.14159 / 180);
    final lon2 = location.longitude * (3.14159 / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = (dLat / 2) * (dLat / 2) + lat1 * lat2 * (dLon / 2) * (dLon / 2);
    final c = 2 * (a < 0 ? -1 : 1) * (a).abs();
    final distance = earthRadius * c;

    if (distance < 1) {
      return '${(distance * 1000).round()} m away';
    } else {
      return '${distance.toStringAsFixed(1)} km away';
    }
  }

  static String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }

  // Build directly from a shops/{id} document.
  // availableMechanics = count of online+approved mechanics linked to this shop.
  factory MechanicShop.fromShop(
    Map<String, dynamic> shopData,
    String docId, {
    int availableMechanics = 0,
  }) {
    return MechanicShop(
      id: docId,
      shopName: shopData['shopName'] as String? ?? 'Unknown Shop',
      location: LatLng(
        (shopData['latitude'] as num?)?.toDouble() ?? 14.5995,
        (shopData['longitude'] as num?)?.toDouble() ?? 120.9842,
      ),
      address: shopData['address'] as String? ?? '',
      phoneNumber: shopData['phoneNumber'] as String? ?? '',
      services: const [],
      rating: (shopData['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: shopData['totalReviews'] as int? ?? 0,
      priceRange: shopData['priceRange'] as String? ?? '₱300-₱2,000',
      operatingHours: Map<String, String>.from(
        shopData['operatingHours'] as Map? ?? {},
      ),
      isOpen: availableMechanics > 0,
      isPartner: shopData['isPartner'] as bool? ?? false,
      photoUrl: shopData['photoUrl'] as String?,
      description: shopData['description'] as String?,
      availableMechanics: availableMechanics,
      owner: null,
    );
  }

  factory MechanicShop.fromFirestore(
    Map<String, dynamic> mechanicData,
    String docId, {
    Map<String, dynamic>? shopData,
    int availableMechanics = 1,
  }) {
    final basicInfo = mechanicData['basicInfo'] as Map<String, dynamic>? ?? {};
    final prof =
        mechanicData['professionalDetails'] as Map<String, dynamic>? ?? {};
    final docs = mechanicData['documents'] as Map<String, dynamic>? ?? {};
    final locMap = mechanicData['location'] as Map<String, dynamic>? ?? {};
    final specialization = prof['specialization'] as String?;
    final years = prof['yearsOfExperience'] as int?;
    String? description;
    if (shopData == null &&
        specialization != null &&
        specialization.isNotEmpty) {
      description = years != null
          ? '$specialization specialist with $years years of experience'
          : '$specialization specialist';
    }
    final businessName = (prof['businessName'] as String?)?.trim() ?? '';
    return MechanicShop(
      id: docId,
      shopName: shopData != null
          ? (shopData['shopName'] as String? ?? 'Unknown Shop')
          : (businessName.isNotEmpty
                ? businessName
                : (basicInfo['fullName'] as String? ?? 'Unknown Shop')),
      location: shopData != null
          ? LatLng(
              (shopData['latitude'] as num?)?.toDouble() ?? 14.5995,
              (shopData['longitude'] as num?)?.toDouble() ?? 120.9842,
            )
          : LatLng(
              (locMap['lat'] as num?)?.toDouble() ?? 14.5995,
              (locMap['lng'] as num?)?.toDouble() ?? 120.9842,
            ),
      address: shopData != null
          ? (shopData['address'] as String? ?? '')
          : (prof['serviceLocation'] as String? ?? ''),
      phoneNumber: shopData != null
          ? (shopData['phoneNumber'] as String? ?? '')
          : (basicInfo['phoneNumber'] as String? ?? ''),
      services: (specialization != null && specialization.isNotEmpty)
          ? [specialization]
          : [],
      rating: (mechanicData['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: mechanicData['totalReviews'] as int? ?? 0,
      priceRange: shopData != null
          ? (shopData['priceRange'] as String? ?? '₱300-₱2,000')
          : '₱300-₱2,000',
      operatingHours: shopData != null
          ? Map<String, String>.from(shopData['operatingHours'] as Map? ?? {})
          : const {},
      isOpen: mechanicData['isOnline'] as bool? ?? false,
      isPartner: shopData?['isPartner'] as bool? ?? false,
      photoUrl: shopData != null
          ? shopData['photoUrl'] as String?
          : docs['profilePhotoUrl'] as String?,
      description: shopData != null
          ? shopData['description'] as String?
          : description,
      availableMechanics: availableMechanics,
      owner: basicInfo['fullName'] as String?,
    );
  }

  MechanicShop copyWith({
    String? id,
    String? shopName,
    LatLng? location,
    String? address,
    String? phoneNumber,
    List<String>? services,
    double? rating,
    int? totalReviews,
    String? priceRange,
    Map<String, String>? operatingHours,
    bool? isOpen,
    bool? isPartner,
    String? photoUrl,
    String? description,
    int? availableMechanics,
    String? owner,
  }) {
    return MechanicShop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      priceRange: priceRange ?? this.priceRange,
      operatingHours: operatingHours ?? this.operatingHours,
      isOpen: isOpen ?? this.isOpen,
      isPartner: isPartner ?? this.isPartner,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      availableMechanics: availableMechanics ?? this.availableMechanics,
      owner: owner ?? this.owner,
    );
  }
}
