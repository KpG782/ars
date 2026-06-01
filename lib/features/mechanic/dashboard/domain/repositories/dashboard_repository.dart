/// Repository Interfaces for Dashboard
///
/// Defines contracts for service request operations following the Repository Pattern.
/// These interfaces enable dependency inversion and testability.
library;

import '../models/service_request.dart';
import 'package:latlong2/latlong.dart';

/// Repository for managing service requests
abstract class ServiceRequestRepository {
  /// Get nearby service requests based on mechanic's location
  Stream<List<ServiceRequest>> getNearbyRequests({
    required LatLng mechanicLocation,
    double radiusKm = 10.0,
  });

  /// Get a specific service request by ID
  Future<ServiceRequest?> getRequestById(String requestId);

  /// Accept a service request
  Future<void> acceptRequest({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
  });

  /// Update service request status
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    DateTime? startTime,
    DateTime? completionTime,
  });

  /// Complete a service request with payment details
  Future<void> completeRequest({
    required String requestId,
    required double actualPrice,
    double tipAmount = 0.0,
    String? mechanicNotes,
    List<String>? workPhotos,
  });

  /// Cancel a service request
  Future<void> cancelRequest({
    required String requestId,
    required String cancellationReason,
  });

  /// Reject a service request
  Future<void> rejectRequest({
    required String requestId,
    required String rejectionReason,
  });

  /// Get mechanic's active requests
  Stream<List<ServiceRequest>> getMechanicActiveRequests(String mechanicId);

  /// Get mechanic's completed requests
  Future<List<ServiceRequest>> getMechanicCompletedRequests({
    required String mechanicId,
    int limit = 20,
  });

  /// Add work photos to a service request
  Future<void> addWorkPhotos({
    required String requestId,
    required List<String> photoUrls,
  });
}

/// Repository for mechanic profile and status management
abstract class MechanicRepository {
  /// Update mechanic availability status
  Future<void> updateStatus({
    required String mechanicId,
    required String status,
  });

  /// Update mechanic location
  Future<void> updateLocation({
    required String mechanicId,
    required LatLng location,
  });

  /// Get mechanic profile data
  Future<Map<String, dynamic>?> getMechanicProfile(String mechanicId);

  /// Update mechanic profile
  Future<void> updateProfile({
    required String mechanicId,
    Map<String, dynamic> profileData,
  });
}

/// Custom exceptions for dashboard operations
class DashboardException implements Exception {
  final String message;
  final DashboardErrorCode code;

  DashboardException(this.message, this.code);

  @override
  String toString() => 'DashboardException: $message (${code.name})';
}

/// Error codes for dashboard operations
enum DashboardErrorCode {
  requestNotFound,
  requestAlreadyAccepted,
  permissionDenied,
  networkError,
  invalidData,
  updateFailed,
  unknown,
}
