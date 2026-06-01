import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../domain/models/service_request.dart';
import '../../domain/repositories/service_request_repository.dart';

class FirestoreServiceRequestRepository implements ServiceRequestRepository {
  final FirebaseFirestore _firestore;

  FirestoreServiceRequestRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ServiceRequest> createServiceRequest(ServiceRequest request) async {
    try {
      final docRef = _firestore.collection('service_requests').doc();
      final newRequest = request.copyWith(id: docRef.id);
      await docRef.set(newRequest.toFirestore());
      appLogger.i('Service request created: ${docRef.id}');
      return newRequest;
    } catch (e, st) {
      appLogger.e('createServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<ServiceRequest?> getServiceRequest(String requestId) async {
    try {
      final doc = await _firestore
          .collection('service_requests')
          .doc(requestId)
          .get();
      if (!doc.exists) {
        return null;
      }
      return ServiceRequest.fromFirestore(doc);
    } catch (e, st) {
      appLogger.e('getServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<ServiceRequest> watchServiceRequest(String requestId) {
    return _firestore
        .collection('service_requests')
        .doc(requestId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw StateError('Service request not found: $requestId');
          }
          return ServiceRequest.fromFirestore(doc);
        });
  }

  @override
  Future<List<ServiceRequest>> getCustomerHistory(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('service_requests')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map(ServiceRequest.fromFirestore).toList();
    } catch (e, st) {
      appLogger.e('getCustomerHistory failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> cancelServiceRequest(String requestId) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': ServiceRequestStatus.cancelled.value,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLogger.e('cancelServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<ServiceRequest>> watchPendingRequestsNearLocation({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  }) {
    return _firestore
        .collection('service_requests')
        .where('status', isEqualTo: ServiceRequestStatus.pending.value)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map(ServiceRequest.fromFirestore)
              .toList();
          return requests.where((request) {
            final distanceKm = _haversineKm(
              lat,
              lng,
              request.customerLocation.latitude,
              request.customerLocation.longitude,
            );
            return distanceKm <= radiusKm;
          }).toList();
        });
  }

  @override
  Future<void> acceptServiceRequest({
    required String requestId,
    required String mechanicId,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'mechanicId': mechanicId,
        'status': ServiceRequestStatus.accepted.value,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLogger.e('acceptServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required ServiceRequestStatus status,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': status.value,
        if (status == ServiceRequestStatus.completed)
          'completedAt': FieldValue.serverTimestamp(),
        if (status == ServiceRequestStatus.cancelled)
          'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLogger.e('updateStatus failed', error: e, stackTrace: st);
      rethrow;
    }
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
