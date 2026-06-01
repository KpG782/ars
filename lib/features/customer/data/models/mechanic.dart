import 'package:latlong2/latlong.dart';

class Mechanic {
  final String name;
  final LatLng location;
  final int etaMinutes;

  Mechanic({
    required this.name,
    required this.location,
    required this.etaMinutes,
  });
}
