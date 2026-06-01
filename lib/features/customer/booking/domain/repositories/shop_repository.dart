/// Domain Layer: Shop Repository Interface
///
/// Defines contract for mechanic shop operations
library;

import 'package:latlong2/latlong.dart';
import '../models/mechanic_shop.dart';

/// Repository for managing mechanic shops
abstract class ShopRepository {
  /// Get shops near a location
  Future<List<MechanicShop>> getShopsNearLocation({
    required LatLng location,
    double radiusKm = 10.0,
  });

  /// Get shop by ID
  Future<MechanicShop?> getShopById(String shopId);

  /// Search shops by service type
  Future<List<MechanicShop>> searchShopsByService({
    required String serviceType,
    required LatLng location,
    double radiusKm = 10.0,
  });

  /// Get shops that are currently open
  Future<List<MechanicShop>> getOpenShops({
    required LatLng location,
    double radiusKm = 10.0,
  });

  /// Calculate distance from shop to location
  double calculateDistance({
    required LatLng shopLocation,
    required LatLng targetLocation,
  });
}

/// Shop-specific exceptions
class ShopException implements Exception {
  final String message;
  final ShopErrorCode code;

  ShopException(this.message, this.code);

  @override
  String toString() => 'ShopException: $message (${code.name})';
}

/// Error codes for shop operations
enum ShopErrorCode {
  notFound,
  noShopsAvailable,
  searchFailed,
  networkError,
  unknown,
}
