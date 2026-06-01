/// Domain Layer: Service History Repository Interface
///
/// Defines contract for retrieving completed service history
library;

import '../../../dashboard/domain/models/service_request.dart';

/// Repository for managing service history
abstract class ServiceHistoryRepository {
  /// Get all completed services for a mechanic
  Stream<List<ServiceRequest>> getServiceHistory({
    required String mechanicId,
    ServiceHistoryFilter? filter,
  });

  /// Get service details by ID
  Future<ServiceRequest?> getServiceById(String serviceId);

  /// Get service statistics summary
  Future<ServiceStatistics> getServiceStatistics({required String mechanicId});
}

/// Filter options for service history
enum ServiceHistoryFilter { all, completed, cancelled }

/// Service statistics summary
class ServiceStatistics {
  final int totalServices;
  final int completedServices;
  final int cancelledServices;
  final double averageRating;
  final double totalEarnings;
  final Duration averageServiceDuration;

  ServiceStatistics({
    required this.totalServices,
    required this.completedServices,
    required this.cancelledServices,
    required this.averageRating,
    required this.totalEarnings,
    required this.averageServiceDuration,
  });
}

/// Service history specific exceptions
class ServiceHistoryException implements Exception {
  final String message;
  final ServiceHistoryErrorCode code;

  ServiceHistoryException(this.message, this.code);

  @override
  String toString() => 'ServiceHistoryException: $message (${code.name})';
}

/// Error codes for service history operations
enum ServiceHistoryErrorCode {
  fetchFailed,
  serviceNotFound,
  permissionDenied,
  unknown,
}
