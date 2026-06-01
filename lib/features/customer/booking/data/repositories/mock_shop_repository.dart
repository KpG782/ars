/// Data Layer: Mock Implementation of ShopRepository
///
/// Provides mock shop data (to be replaced with Firebase in production)
library;

import 'package:latlong2/latlong.dart';
import 'dart:math';
import '../../domain/models/mechanic_shop.dart';
import '../../domain/repositories/shop_repository.dart';

class MockShopRepository implements ShopRepository {
  @override
  Future<List<MechanicShop>> getShopsNearLocation({
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    try {
      // Generate mock shops around location
      return _generateShopsAroundLocation(location, radiusKm);
    } catch (e) {
      throw ShopException(
        'Failed to fetch shops: $e',
        ShopErrorCode.searchFailed,
      );
    }
  }

  @override
  Future<MechanicShop?> getShopById(String shopId) async {
    try {
      // TODO: Fetch from Firebase
      return null;
    } catch (e) {
      throw ShopException('Shop not found', ShopErrorCode.notFound);
    }
  }

  @override
  Future<List<MechanicShop>> searchShopsByService({
    required String serviceType,
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    try {
      final allShops = await getShopsNearLocation(
        location: location,
        radiusKm: radiusKm,
      );

      return allShops.where((shop) => shop.offersService(serviceType)).toList();
    } catch (e) {
      throw ShopException(
        'Failed to search shops: $e',
        ShopErrorCode.searchFailed,
      );
    }
  }

  @override
  Future<List<MechanicShop>> getOpenShops({
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    try {
      final allShops = await getShopsNearLocation(
        location: location,
        radiusKm: radiusKm,
      );

      return allShops.where((shop) => shop.isOpen).toList();
    } catch (e) {
      throw ShopException(
        'Failed to get open shops: $e',
        ShopErrorCode.searchFailed,
      );
    }
  }

  @override
  double calculateDistance({
    required LatLng shopLocation,
    required LatLng targetLocation,
  }) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, shopLocation, targetLocation);
  }

  // Helper: Generate mock shops around location
  List<MechanicShop> _generateShopsAroundLocation(
    LatLng userLocation,
    double radiusKm,
  ) {
    final List<MechanicShop> shops = [];
    final random = Random();

    // Generate 10 shops within radius
    for (int i = 0; i < 10; i++) {
      final distance = 0.5 + random.nextDouble() * (radiusKm - 0.5);
      final angle = random.nextDouble() * 2 * pi;

      final latOffset = (distance / 111) * cos(angle);
      final lngOffset =
          (distance / (111 * cos(userLocation.latitude * pi / 180))) *
          sin(angle);

      final shopLocation = LatLng(
        userLocation.latitude + latOffset,
        userLocation.longitude + lngOffset,
      );

      shops.add(_createMockShop(i + 1, shopLocation));
    }

    return shops;
  }

  MechanicShop _createMockShop(int index, LatLng location) {
    final random = Random();
    final isPartner = random.nextBool();
    final isOpen = random.nextBool();

    final shopNames = [
      'AutoFix Pro Garage',
      'SpeedTech Auto Care',
      'City Motors Workshop',
      'Elite Auto Repair',
      'Quick Fix Auto Shop',
      'Metro Garage Services',
      'Premium Auto Works',
      'Roadside Auto Clinic',
      'South Auto Experts',
      'North Star Auto Repair',
    ];

    final owners = [
      'Juan dela Cruz',
      'Pedro Santos',
      'Maria Garcia',
      'Roberto Tan',
      'Carlos Reyes',
    ];

    final rating = 4.3 + random.nextDouble() * 0.7;
    final reviews = 50 + random.nextInt(250);

    return MechanicShop(
      id: 'shop_${index.toString().padLeft(3, '0')}',
      shopName: shopNames[(index - 1) % shopNames.length],
      location: location,
      address: 'Shop $index, Near Current Location',
      phoneNumber:
          '+63 917 ${random.nextInt(900) + 100} ${random.nextInt(9000) + 1000}',
      services: _getRandomServices(random),
      rating: rating,
      totalReviews: reviews,
      priceRange:
          '₱${300 + random.nextInt(500)}-${2000 + random.nextInt(3000)}',
      operatingHours: _getOperatingHours(index),
      isOpen: isOpen,
      isPartner: isPartner,
      description: 'Quality auto repair service with experienced technicians.',
      availableMechanics: random.nextInt(5) + 1,
      owner: owners[(index - 1) % owners.length],
    );
  }

  List<String> _getRandomServices(Random random) {
    final allServices = [
      'Engine Repair',
      'Brake Service',
      'Oil Change',
      'Tire Replacement',
      'AC Repair',
      'Battery Service',
      'Electrical System',
      'Transmission Service',
      'Suspension Work',
    ];

    final count = 4 + random.nextInt(5);
    allServices.shuffle(random);
    return allServices.take(count).toList();
  }

  Map<String, String> _getOperatingHours(int index) {
    if (index == 8) {
      return {
        'monday': '24 Hours',
        'tuesday': '24 Hours',
        'wednesday': '24 Hours',
        'thursday': '24 Hours',
        'friday': '24 Hours',
        'saturday': '24 Hours',
        'sunday': '24 Hours',
      };
    }

    return {
      'monday': '8:00 AM - 6:00 PM',
      'tuesday': '8:00 AM - 6:00 PM',
      'wednesday': '8:00 AM - 6:00 PM',
      'thursday': '8:00 AM - 6:00 PM',
      'friday': '8:00 AM - 6:00 PM',
      'saturday': '9:00 AM - 5:00 PM',
      'sunday': index % 3 == 0 ? 'Closed' : '10:00 AM - 3:00 PM',
    };
  }
}
