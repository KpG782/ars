import '../../../../customer/booking/domain/repositories/mechanic_repository.dart';

class UpdateMechanicStatusUseCase {
  final MechanicRepository _repository;
  UpdateMechanicStatusUseCase(this._repository);

  Future<void> call({required String mechanicId, required bool isOnline}) {
    return _repository.updateMechanicAvailability(
      mechanicId: mechanicId,
      isAvailable: isOnline,
    );
  }
}
