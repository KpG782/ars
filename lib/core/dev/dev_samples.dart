import 'package:latlong2/latlong.dart';

import '../../features/customer/booking/domain/models/mechanic.dart';
import '../../features/mechanic/dashboard/domain/models/service_request.dart';

/// Throwaway sample data so screens that require a [Mechanic] or
/// [ServiceRequest] can be opened from the Dev Menu without a backend.
/// Debug tooling only — not used by production flows.
class DevSamples {
  const DevSamples._();

  static const LatLng _manila = LatLng(14.5995, 120.9842);

  static Mechanic mechanic() => Mechanic(
    id: 'dev-mech-1',
    name: 'Dev Mechanic',
    location: _manila,
    etaMinutes: 12,
    phoneNumber: '+639170000000',
    rating: 4.8,
    isAvailable: true,
    specializations: const ['Engine', 'Brake'],
  );

  static ServiceRequest serviceRequest() => ServiceRequest(
    id: 'dev-req-1',
    customerName: 'Dev Customer',
    location: _manila,
    serviceType: 'Brake Repair',
    description: 'Brakes feel soft when stopping.',
    estimatedPrice: 1500,
    requestTime: DateTime(2026, 6, 2, 9, 30),
  );
}
