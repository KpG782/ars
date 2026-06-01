/// Domain Layer: Booking Repository Interface
///
/// Defines contract for booking/navigation operations
library;

import 'package:latlong2/latlong.dart';

/// Repository for managing booking navigation and routes
abstract class BookingRepository {
  /// Fetch route from mechanic location to user location
  /// Returns list of coordinates representing the route
  Future<List<LatLng>> getRoute({
    required LatLng mechanicLocation,
    required LatLng userLocation,
  });

  /// Cancel current navigation
  Future<void> cancelNavigation();
}

/// Booking-specific exceptions
class BookingException implements Exception {
  final String message;
  final BookingErrorCode code;

  BookingException(this.message, this.code);

  @override
  String toString() => 'BookingException: $message (${code.name})';
}

/// Error codes for booking operations
enum BookingErrorCode {
  routeFetchFailed,
  navigationCancelled,
  apiError,
  networkError,
}
