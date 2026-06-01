/// Firebase Implementation of ServiceRequestRepository
///
/// Provides Firebase Firestore implementation for service request operations
library;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/service_request.dart';
import '../../domain/repositories/dashboard_repository.dart';

class FirebaseServiceRequestRepository implements ServiceRequestRepository {
  final FirebaseFirestore _firestore;

  FirebaseServiceRequestRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ServiceRequest>> getNearbyRequests({
    required LatLng mechanicLocation,
    double radiusKm = 10.0,
  }) {
    try {
      return _firestore
          .collection('service_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => _mapDocToServiceRequest(doc))
                .where((request) {
                  // Calculate distance between mechanic and request location
                  final distance = _calculateDistance(
                    mechanicLocation,
                    request.location,
                  );
                  return distance <= radiusKm;
                })
                .toList();
          });
    } catch (e) {
      throw DashboardException(
        'Failed to get nearby requests: $e',
        DashboardErrorCode.networkError,
      );
    }
  }

  @override
  Future<ServiceRequest?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection('service_requests')
          .doc(requestId)
          .get();

      if (!doc.exists) return null;
      return _mapDocToServiceRequest(doc);
    } catch (e) {
      throw DashboardException(
        'Failed to get request: $e',
        DashboardErrorCode.networkError,
      );
    }
  }

  @override
  Future<void> acceptRequest({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'accepted',
        'mechanicId': mechanicId,
        'mechanicName': mechanicName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw DashboardException(
          'Request not found',
          DashboardErrorCode.requestNotFound,
        );
      }
      throw DashboardException(
        'Failed to accept request: ${e.message}',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    DateTime? startTime,
    DateTime? completionTime,
  }) async {
    try {
      final updates = <String, dynamic>{'status': status.name};

      if (startTime != null) {
        updates['startTime'] = Timestamp.fromDate(startTime);
      }
      if (completionTime != null) {
        updates['completionTime'] = Timestamp.fromDate(completionTime);
      }

      await _firestore
          .collection('service_requests')
          .doc(requestId)
          .update(updates);
    } catch (e) {
      throw DashboardException(
        'Failed to update status: $e',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> completeRequest({
    required String requestId,
    required double actualPrice,
    double tipAmount = 0.0,
    String? mechanicNotes,
    List<String>? workPhotos,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': 'completed',
        'actualPrice': actualPrice,
        'tipAmount': tipAmount,
        'completionTime': FieldValue.serverTimestamp(),
      };

      if (mechanicNotes != null) updates['mechanicNotes'] = mechanicNotes;
      if (workPhotos != null) updates['workPhotos'] = workPhotos;

      await _firestore
          .collection('service_requests')
          .doc(requestId)
          .update(updates);
    } catch (e) {
      throw DashboardException(
        'Failed to complete request: $e',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> cancelRequest({
    required String requestId,
    required String cancellationReason,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'cancelled',
        'cancellationReason': cancellationReason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DashboardException(
        'Failed to cancel request: $e',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String rejectionReason,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'pending', // Return to pending for other mechanics
        'rejectionReason': rejectionReason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DashboardException(
        'Failed to reject request: $e',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  @override
  Stream<List<ServiceRequest>> getMechanicActiveRequests(String mechanicId) {
    try {
      return _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', whereIn: ['accepted', 'inProgress'])
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => _mapDocToServiceRequest(doc))
                .toList(),
          );
    } catch (e) {
      throw DashboardException(
        'Failed to get active requests: $e',
        DashboardErrorCode.networkError,
      );
    }
  }

  @override
  Future<List<ServiceRequest>> getMechanicCompletedRequests({
    required String mechanicId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completionTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _mapDocToServiceRequest(doc)).toList();
    } catch (e) {
      throw DashboardException(
        'Failed to get completed requests: $e',
        DashboardErrorCode.networkError,
      );
    }
  }

  @override
  Future<void> addWorkPhotos({
    required String requestId,
    required List<String> photoUrls,
  }) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'workPhotos': FieldValue.arrayUnion(photoUrls),
      });
    } catch (e) {
      throw DashboardException(
        'Failed to add work photos: $e',
        DashboardErrorCode.updateFailed,
      );
    }
  }

  // Helper: Map Firestore document to ServiceRequest
  ServiceRequest _mapDocToServiceRequest(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;

    return ServiceRequest(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      serviceType: data['serviceType'] ?? '',
      description: data['description'] ?? '',
      estimatedPrice: (data['estimatedPrice'] ?? 0).toDouble(),
      actualPrice: data['actualPrice']?.toDouble(),
      requestTime: (data['requestTime'] as Timestamp).toDate(),
      completionTime: data['completionTime'] != null
          ? (data['completionTime'] as Timestamp).toDate()
          : null,
      status: _parseStatus(data['status']),
      customerPhone: data['customerPhone'],
      customerPhoto: data['customerPhoto'],
      tipAmount: (data['tipAmount'] ?? 0).toDouble(),
      appliedPromoCode: data['appliedPromoCode'],
      discountApplied: (data['discountApplied'] ?? 0).toDouble(),
      workPhotos: data['workPhotos'] != null
          ? List<String>.from(data['workPhotos'])
          : null,
      mechanicNotes: data['mechanicNotes'],
      customerNotes: data['customerNotes'],
      customerRating: data['customerRating']?.toDouble(),
      customerReview: data['customerReview'],
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
      rejectionReason: data['rejectionReason'],
      isEmergency: data['isEmergency'] ?? false,
    );
  }

  // Helper: Parse status string to enum
  RequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'inProgress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  // Helper: Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km

    final lat1 = point1.latitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final dLat = (point2.latitude - point1.latitude) * (pi / 180);
    final dLon = (point2.longitude - point1.longitude) * (pi / 180);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
