/// Domain Layer: Mechanic Repository Interface
///
/// Defines contract for mechanic-related operations
library;

import 'package:latlong2/latlong.dart';
import '../models/mechanic.dart';

/// Repository for managing mechanic search and availability
abstract class MechanicRepository {
  /// Search for available mechanics near a location
  Future<List<Mechanic>> searchNearbyMechanics({
    required LatLng location,
    double radiusKm = 10.0,
    String? serviceType,
  });

  /// Get mechanic by ID
  Future<Mechanic?> getMechanicById(String mechanicId);

  /// Calculate real-time ETA for mechanic to customer location
  Future<int> calculateETA({
    required LatLng mechanicLocation,
    required LatLng customerLocation,
  });

  /// Get route coordinates from mechanic to customer
  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  });

  /// Update mechanic availability status
  Future<void> updateMechanicAvailability({
    required String mechanicId,
    required bool isAvailable,
  });
}

/// Mechanic-specific exceptions
class MechanicException implements Exception {
  final String message;
  final MechanicErrorCode code;

  MechanicException(this.message, this.code);

  @override
  String toString() => 'MechanicException: $message (${code.name})';
}

/// Error codes for mechanic operations
enum MechanicErrorCode {
  notFound,
  unavailable,
  routeCalculationFailed,
  searchFailed,
  networkError,
  unknown,
}
