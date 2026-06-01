/// Firebase Implementation of MechanicRepository
///
/// Provides Firebase Firestore implementation for mechanic profile operations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/dashboard_repository.dart';

class FirebaseMechanicRepository implements MechanicRepository {
  final FirebaseFirestore _firestore;

  FirebaseMechanicRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updateStatus({
    required String mechanicId,
    required String status,
  }) async {
    try {
      await _firestore.collection('mechanics').doc(mechanicId).update({
        'status': status,
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DashboardException(
        'Failed to update status: ${e.message}',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> updateLocation({
    required String mechanicId,
    required LatLng location,
  }) async {
    try {
      await _firestore.collection('mechanics').doc(mechanicId).update({
        'location': GeoPoint(location.latitude, location.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DashboardException(
        'Failed to update location: ${e.message}',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getMechanicProfile(String mechanicId) async {
    try {
      final doc = await _firestore
          .collection('mechanics')
          .doc(mechanicId)
          .get();

      if (!doc.exists) {
        throw DashboardException(
          'Mechanic profile not found',
          DashboardErrorCode.requestNotFound,
        );
      }

      return doc.data();
    } on FirebaseException catch (e) {
      throw DashboardException(
        'Failed to get profile: ${e.message}',
        DashboardErrorCode.networkError,
      );
    }
  }

  @override
  Future<void> updateProfile({
    required String mechanicId,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      // Add timestamp
      final updates = Map<String, dynamic>.from(profileData ?? {});
      updates['lastUpdated'] = FieldValue.serverTimestamp();

      await _firestore.collection('mechanics').doc(mechanicId).update(updates);
    } on FirebaseException catch (e) {
      throw DashboardException(
        'Failed to update profile: ${e.message}',
        DashboardErrorCode.updateFailed,
      );
    }
  }
}
