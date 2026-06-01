/// Data Layer: Firebase Implementation of ServiceHistoryRepository
///
/// Provides Firestore implementation for service history operations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/service_history_repository.dart';
import '../../../dashboard/domain/models/service_request.dart';

class FirebaseServiceHistoryRepository implements ServiceHistoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseServiceHistoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ServiceRequest>> getServiceHistory({
    required String mechanicId,
    ServiceHistoryFilter? filter,
  }) {
    try {
      Query query = _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .orderBy('completionTime', descending: true);

      // Apply filter
      if (filter == ServiceHistoryFilter.completed) {
        query = query.where('status', isEqualTo: 'completed');
      } else if (filter == ServiceHistoryFilter.cancelled) {
        query = query.where('status', isEqualTo: 'cancelled');
      } else {
        // For 'all', include both completed and cancelled
        query = query.where('status', whereIn: ['completed', 'cancelled']);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => _mapDocToServiceRequest(doc))
            .toList();
      });
    } catch (e) {
      throw ServiceHistoryException(
        'Failed to fetch service history: $e',
        ServiceHistoryErrorCode.fetchFailed,
      );
    }
  }

  @override
  Future<ServiceRequest?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore
          .collection('service_requests')
          .doc(serviceId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return _mapDocToServiceRequest(doc);
    } catch (e) {
      throw ServiceHistoryException(
        'Failed to fetch service: $e',
        ServiceHistoryErrorCode.serviceNotFound,
      );
    }
  }

  @override
  Future<ServiceStatistics> getServiceStatistics({
    required String mechanicId,
  }) async {
    try {
      final completedQuery = await _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', isEqualTo: 'completed')
          .get();

      final cancelledQuery = await _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', isEqualTo: 'cancelled')
          .get();

      final completedServices = completedQuery.docs
          .map((doc) => _mapDocToServiceRequest(doc))
          .toList();

      final totalServices = completedServices.length + cancelledQuery.size;
      final completedCount = completedServices.length;
      final cancelledCount = cancelledQuery.size;

      // Calculate statistics
      double totalEarnings = 0;
      double totalRating = 0;
      int ratedServices = 0;
      Duration totalDuration = Duration.zero;

      for (var service in completedServices) {
        totalEarnings += service.mechanicEarnings;

        if (service.customerRating != null) {
          totalRating += service.customerRating!;
          ratedServices++;
        }

        if (service.startTime != null && service.completionTime != null) {
          totalDuration += service.completionTime!.difference(
            service.startTime!,
          );
        }
      }

      final averageRating = ratedServices > 0
          ? totalRating / ratedServices
          : 0.0;
      final averageDuration = completedCount > 0
          ? Duration(
              milliseconds: totalDuration.inMilliseconds ~/ completedCount,
            )
          : Duration.zero;

      return ServiceStatistics(
        totalServices: totalServices,
        completedServices: completedCount,
        cancelledServices: cancelledCount,
        averageRating: averageRating,
        totalEarnings: totalEarnings,
        averageServiceDuration: averageDuration,
      );
    } catch (e) {
      throw ServiceHistoryException(
        'Failed to fetch service statistics: $e',
        ServiceHistoryErrorCode.fetchFailed,
      );
    }
  }

  // Helper: Map Firestore doc to ServiceRequest
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
      status: _parseRequestStatus(data['status']),
      customerPhone: data['customerPhone'],
      customerPhoto: data['customerPhoto'],
      tipAmount: (data['tipAmount'] ?? 0).toDouble(),
      appliedPromoCode: data['appliedPromoCode'],
      discountApplied: (data['discountApplied'] ?? 0).toDouble(),
      workPhotos: data['workPhotos'] != null
          ? List<String>.from(data['workPhotos'])
          : null,
      mechanicNotes: data['mechanicNotes'],
      customerRating: data['customerRating']?.toDouble(),
      customerReview: data['customerReview'],
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
    );
  }

  // Helper: Parse status string to RequestStatus enum
  RequestStatus _parseRequestStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'inprogress':
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }
}
