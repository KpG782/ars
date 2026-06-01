/// Data Layer: OpenRouteService Implementation of BookingRepository
///
/// Provides routing functionality using OpenRouteService API
library;

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/repositories/booking_repository.dart';

class OpenRouteServiceBookingRepository implements BookingRepository {
  final String apiKey;
  bool _isNavigationActive = true;

  OpenRouteServiceBookingRepository({required this.apiKey});

  @override
  Future<List<LatLng>> getRoute({
    required LatLng mechanicLocation,
    required LatLng userLocation,
  }) async {
    if (!_isNavigationActive) {
      throw BookingException(
        'Navigation has been cancelled',
        BookingErrorCode.navigationCancelled,
      );
    }

    try {
      final url =
          'https://api.openrouteservice.org/v2/directions/driving-car'
          '?api_key=$apiKey'
          '&start=${mechanicLocation.longitude},${mechanicLocation.latitude}'
          '&end=${userLocation.longitude},${userLocation.latitude}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['features'][0]['geometry']['coordinates'] as List;

        return geometry
            .map<LatLng>((point) => LatLng(point[1], point[0]))
            .toList();
      } else if (response.statusCode == 401) {
        throw BookingException('Invalid API key', BookingErrorCode.apiError);
      } else {
        throw BookingException(
          'Failed to fetch route: ${response.statusCode}',
          BookingErrorCode.routeFetchFailed,
        );
      }
    } catch (e) {
      if (e is BookingException) rethrow;
      throw BookingException(
        'Network error: $e',
        BookingErrorCode.networkError,
      );
    }
  }

  @override
  Future<void> cancelNavigation() async {
    _isNavigationActive = false;
  }

  /// Reset navigation state
  void resetNavigation() {
    _isNavigationActive = true;
  }

  /// Check if navigation is active
  bool get isNavigationActive => _isNavigationActive;
}
