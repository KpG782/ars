import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../domain/models/mechanic_shop.dart';
import '../../domain/repositories/shop_repository.dart';

class FirestoreShopRepository implements ShopRepository {
  final FirebaseFirestore _firestore;

  FirestoreShopRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<MechanicShop>> getShopsNearLocation({
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    try {
      // 1. Fetch all shops (admin-managed, small collection)
      final shopSnapshot = await _firestore.collection('shops').get();

      // 2. Filter by Haversine distance; skip docs missing lat/lng
      final nearbyDocs = <String, Map<String, dynamic>>{};
      for (final doc in shopSnapshot.docs) {
        final data = doc.data();
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        if (_haversineKm(location.latitude, location.longitude, lat, lng) <=
            radiusKm) {
          nearbyDocs[doc.id] = data;
        }
      }

      if (nearbyDocs.isEmpty) {
        appLogger.i('No shops found near location');
        return [];
      }

      // 3. Count online+approved mechanics per nearby shop
      final mechanicsSnap = await _firestore
          .collection('mechanics')
          .where('verification.status', isEqualTo: 'approved')
          .where('isOnline', isEqualTo: true)
          .get();

      final mechanicsPerShop = <String, int>{};
      for (final doc in mechanicsSnap.docs) {
        final shopId = doc.data()['shopId'] as String?;
        if (shopId != null && nearbyDocs.containsKey(shopId)) {
          mechanicsPerShop[shopId] = (mechanicsPerShop[shopId] ?? 0) + 1;
        }
      }

      // 4. Every nearby shop appears — even those with 0 online mechanics
      final result = nearbyDocs.entries.map((e) {
        return MechanicShop.fromShop(
          e.value,
          e.key,
          availableMechanics: mechanicsPerShop[e.key] ?? 0,
        );
      }).toList();

      appLogger.i('Loaded ${result.length} shops near location');
      return result;
    } catch (e, st) {
      appLogger.e('getShopsNearLocation failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<MechanicShop?> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('mechanics').doc(shopId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final linkedShopId = data['shopId'] as String?;
      Map<String, dynamic>? shopData;

      if (linkedShopId != null && linkedShopId.isNotEmpty) {
        final shopDoc = await _firestore
            .collection('shops')
            .doc(linkedShopId)
            .get();
        if (shopDoc.exists) {
          shopData = shopDoc.data();
        }
      }

      return MechanicShop.fromFirestore(data, doc.id, shopData: shopData);
    } catch (e, st) {
      appLogger.e('getShopById failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<MechanicShop>> searchShopsByService({
    required String serviceType,
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    final shops = await getShopsNearLocation(
      location: location,
      radiusKm: radiusKm,
    );
    return shops.where((s) => s.offersService(serviceType)).toList();
  }

  @override
  Future<List<MechanicShop>> getOpenShops({
    required LatLng location,
    double radiusKm = 10.0,
  }) async {
    final shops = await getShopsNearLocation(
      location: location,
      radiusKm: radiusKm,
    );
    return shops.where((s) => s.isOpen).toList();
  }

  @override
  double calculateDistance({
    required LatLng shopLocation,
    required LatLng targetLocation,
  }) {
    return _haversineKm(
      shopLocation.latitude,
      shopLocation.longitude,
      targetLocation.latitude,
      targetLocation.longitude,
    );
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
