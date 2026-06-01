import '../models/service_request.dart';

abstract class ServiceRequestRepository {
  Future<ServiceRequest> createServiceRequest(ServiceRequest request);
  Future<ServiceRequest?> getServiceRequest(String requestId);
  Stream<ServiceRequest> watchServiceRequest(String requestId);
  Future<List<ServiceRequest>> getCustomerHistory(String customerId);
  Future<void> cancelServiceRequest(String requestId);
  Stream<List<ServiceRequest>> watchPendingRequestsNearLocation({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  });
  Future<void> acceptServiceRequest({
    required String requestId,
    required String mechanicId,
  });
  Future<void> updateStatus({
    required String requestId,
    required ServiceRequestStatus status,
  });
}
