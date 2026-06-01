import 'package:latlong2/latlong.dart';

import '../models/service_request.dart';
import '../repositories/service_request_repository.dart';

class CreateBookingUseCase {
  final ServiceRequestRepository _repository;
  CreateBookingUseCase(this._repository);

  Future<ServiceRequest> call({
    required String customerId,
    required String serviceType,
    String? subServiceType,
    required LatLng customerLocation,
    String? customerAddress,
    bool isEmergency = false,
    String? description,
  }) {
    final request = ServiceRequest(
      id: '',
      customerId: customerId,
      status: ServiceRequestStatus.pending,
      serviceType: serviceType,
      subServiceType: subServiceType,
      isEmergency: isEmergency,
      customerLocation: customerLocation,
      customerAddress: customerAddress,
      description: description,
      createdAt: DateTime.now(),
    );
    return _repository.createServiceRequest(request);
  }
}
