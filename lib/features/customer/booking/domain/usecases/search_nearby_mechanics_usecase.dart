import 'package:latlong2/latlong.dart';

import '../models/mechanic.dart';
import '../repositories/mechanic_repository.dart';

class SearchNearbyMechanicsUseCase {
  final MechanicRepository _repository;
  SearchNearbyMechanicsUseCase(this._repository);

  Future<List<Mechanic>> call({
    required LatLng location,
    double radiusKm = 10.0,
    String? serviceType,
  }) {
    return _repository.searchNearbyMechanics(
      location: location,
      radiusKm: radiusKm,
      serviceType: serviceType,
    );
  }
}
