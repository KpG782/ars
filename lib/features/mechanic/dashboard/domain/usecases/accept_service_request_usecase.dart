import '../../../../customer/booking/domain/repositories/service_request_repository.dart';

class AcceptServiceRequestUseCase {
  final ServiceRequestRepository _repository;
  AcceptServiceRequestUseCase(this._repository);

  Future<void> call({required String requestId, required String mechanicId}) {
    return _repository.acceptServiceRequest(
      requestId: requestId,
      mechanicId: mechanicId,
    );
  }
}
