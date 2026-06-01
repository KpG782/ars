/// Data Layer: Firestore + OSRM Implementation of MechanicRepository
///
/// Queries real online mechanics from Firestore, calculates ETA via OSRM.
library;

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/services/osrm_service.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/models/mechanic.dart';
import '../../domain/repositories/mechanic_repository.dart';

class FirestoreMechanicRepository implements MechanicRepository {
  final FirebaseFirestore _firestore;
  final OSRMService _osrmService;

  FirestoreMechanicRepository({
    FirebaseFirestore? firestore,
    OSRMService? osrmService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _osrmService = osrmService ?? OSRMService();

  @override
  Future<List<Mechanic>> searchNearbyMechanics({
    required LatLng location,
    double radiusKm = 10.0,
    String? serviceType,
  }) async {
    try {
      Query query = _firestore
          .collection('mechanics')
          .where('isOnline', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      if (serviceType != null && serviceType.isNotEmpty) {
        query = query.where('specializations', arrayContains: serviceType);
      }

      final snapshot = await query.limit(50).get();

      final mechanics = snapshot.docs
          .map(
            (doc) => Mechanic.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      final nearby = mechanics.where((m) {
        final distKm = _haversineKm(
          location.latitude,
          location.longitude,
          m.location.latitude,
          m.location.longitude,
        );
        return distKm <= radiusKm;
      }).toList();

      if (nearby.isEmpty) {
        appLogger.w('No online mechanics found within ${radiusKm}km');
        return [];
      }

      final withEta = await _enrichWithEta(nearby, location);
      withEta.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
      return withEta;
    } catch (e, st) {
      appLogger.e('searchNearbyMechanics failed', error: e, stackTrace: st);
      throw MechanicException(
        'Failed to search mechanics: $e',
        MechanicErrorCode.searchFailed,
      );
    }
  }

  @override
  Future<Mechanic?> getMechanicById(String mechanicId) async {
    try {
      final doc = await _firestore
          .collection('mechanics')
          .doc(mechanicId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return Mechanic.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e, st) {
      appLogger.e('getMechanicById failed', error: e, stackTrace: st);
      throw MechanicException(
        'Mechanic not found: $e',
        MechanicErrorCode.notFound,
      );
    }
  }

  @override
  Future<int> calculateETA({
    required LatLng mechanicLocation,
    required LatLng customerLocation,
  }) async {
    try {
      final result = await _osrmService.calculateETA(
        origin: mechanicLocation,
        destination: customerLocation,
      );
      return result.durationInMinutes;
    } catch (_) {
      final distKm = _haversineKm(
        mechanicLocation.latitude,
        mechanicLocation.longitude,
        customerLocation.latitude,
        customerLocation.longitude,
      );
      return (distKm / 30.0 * 60).ceil().clamp(2, 120);
    }
  }

  @override
  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final result = await _osrmService.getRoute(
        origin: origin,
        destination: destination,
      );
      return result?.coordinates ?? [];
    } catch (e, st) {
      appLogger.e('getRoute failed', error: e, stackTrace: st);
      throw MechanicException(
        'Failed to get route: $e',
        MechanicErrorCode.routeCalculationFailed,
      );
    }
  }

  @override
  Future<void> updateMechanicAvailability({
    required String mechanicId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore.collection('mechanics').doc(mechanicId).update({
        'isOnline': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLogger.e(
        'updateMechanicAvailability failed',
        error: e,
        stackTrace: st,
      );
      throw MechanicException(
        'Failed to update availability: $e',
        MechanicErrorCode.unknown,
      );
    }
  }

  Future<List<Mechanic>> _enrichWithEta(
    List<Mechanic> mechanics,
    LatLng destination,
  ) async {
    final results = <Mechanic>[];
    for (final m in mechanics) {
      try {
        final eta = await _osrmService.calculateETA(
          origin: m.location,
          destination: destination,
        );
        results.add(m.copyWith(etaMinutes: eta.durationInMinutes));
      } catch (_) {
        results.add(m);
      }
    }
    return results;
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

class OSRMMechanicRepository extends FirestoreMechanicRepository {
  OSRMMechanicRepository({super.firestore, super.osrmService});
}
