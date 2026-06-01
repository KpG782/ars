import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'dart:math';

/// Service for calculating routes, ETA, and distances using OSRM
/// (Open Source Routing Machine) with Philippines road network data.
class OSRMService {
  // Your deployed OSRM server URL
  static const String baseUrl =
      'https://pacebeats-osrm-philippines.kygozf.easypanel.host';

  /// Calculate ETA and distance between two points using road network
  ///
  /// Returns [ETAResult] with duration, distance, and accuracy indicator
  /// Falls back to straight-line calculation if OSRM is unavailable
  Future<ETAResult> calculateETA({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=false&steps=false',
      );

      debugPrint('🗺️ Fetching route from OSRM...');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] != 'Ok') {
          throw Exception('OSRM returned: ${data['code']}');
        }

        final route = data['routes'][0];
        final durationSeconds = (route['duration'] as num).toInt();
        final distanceMeters = (route['distance'] as num).toDouble();

        debugPrint(
          '✅ Route found: ${_formatDuration(durationSeconds)} / ${_formatDistance(distanceMeters)}',
        );

        return ETAResult(
          durationInSeconds: durationSeconds,
          distanceInMeters: distanceMeters.toInt(),
          durationText: _formatDuration(durationSeconds),
          distanceText: _formatDistance(distanceMeters),
          isAccurate: true,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ OSRM failed: $e');
      debugPrint('📍 Using straight-line fallback...');
      return _calculateStraightLineETA(origin, destination);
    }
  }

  /// Get route with geometry for map display
  ///
  /// Returns [RouteResult] with coordinates to draw polyline on map
  /// Returns null if route cannot be calculated
  Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] != 'Ok') return null;

        final route = data['routes'][0];
        final coordinates = (route['geometry']['coordinates'] as List)
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        return RouteResult(
          coordinates: coordinates,
          duration: (route['duration'] as num).toInt(),
          distance: (route['distance'] as num).toInt(),
        );
      }
    } catch (e) {
      debugPrint('Failed to get route geometry: $e');
    }
    return null;
  }

  /// Calculate ETA for multiple destinations (batch processing)
  ///
  /// Useful for finding nearest mechanic from multiple options
  Future<List<ETAResult>> calculateBatchETA({
    required LatLng origin,
    required List<LatLng> destinations,
  }) async {
    final results = <ETAResult>[];

    for (final destination in destinations) {
      final eta = await calculateETA(origin: origin, destination: destination);
      results.add(eta);
    }

    return results;
  }

  /// Fallback calculation using straight-line distance (Haversine formula)
  ///
  /// Used when OSRM server is unavailable or times out
  ETAResult _calculateStraightLineETA(LatLng origin, LatLng destination) {
    final distanceKm = _haversineDistance(origin, destination);

    // Estimate speed based on location and time
    final avgSpeed = _estimateSpeed(origin, destination);
    final durationSeconds = (distanceKm / avgSpeed * 3600).toInt();

    return ETAResult(
      durationInSeconds: durationSeconds,
      distanceInMeters: (distanceKm * 1000).toInt(),
      durationText: _formatDuration(durationSeconds),
      distanceText: _formatDistance(distanceKm * 1000),
      isAccurate: false, // Mark as estimate
    );
  }

  /// Estimate average speed based on location and time of day
  double _estimateSpeed(LatLng origin, LatLng destination) {
    // Check if in Metro Manila (slower traffic)
    if (_isMetroManila(origin) || _isMetroManila(destination)) {
      final hour = DateTime.now().hour;

      // Rush hour (7-10 AM, 5-8 PM)
      if ((hour >= 7 && hour <= 10) || (hour >= 17 && hour <= 20)) {
        return 15.0; // km/h - heavy traffic
      }
      return 25.0; // km/h - moderate traffic
    }

    // Provincial/highway
    return 40.0; // km/h - lighter traffic
  }

  /// Check if location is within Metro Manila bounds
  bool _isMetroManila(LatLng location) {
    return location.latitude >= 14.3 &&
        location.latitude <= 14.8 &&
        location.longitude >= 120.9 &&
        location.longitude <= 121.2;
  }

  /// Calculate straight-line distance using Haversine formula
  double _haversineDistance(LatLng from, LatLng to) {
    const R = 6371; // Earth radius in km
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLon = _toRadians(to.longitude - from.longitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(from.latitude)) *
            cos(_toRadians(to.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  /// Format duration in seconds to human-readable text
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours hr $mins min';
  }

  /// Format distance in meters to human-readable text
  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Health check - verify OSRM server is online
  Future<bool> isServerHealthy() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('OSRM health check failed: $e');
      return false;
    }
  }
}

/// Result from ETA calculation
class ETAResult {
  final int durationInSeconds;
  final int distanceInMeters;
  final String durationText;
  final String distanceText;
  final bool isAccurate; // true if from OSRM, false if estimated

  ETAResult({
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.durationText,
    required this.distanceText,
    required this.isAccurate,
  });

  Duration get duration => Duration(seconds: durationInSeconds);
  double get distanceKm => distanceInMeters / 1000;
  int get durationInMinutes => (durationInSeconds / 60).round();

  @override
  String toString() {
    return 'ETAResult(duration: $durationText, distance: $distanceText, accurate: $isAccurate)';
  }
}

/// Route with full geometry for map display
class RouteResult {
  final List<LatLng> coordinates;
  final int duration; // seconds
  final int distance; // meters

  RouteResult({
    required this.coordinates,
    required this.duration,
    required this.distance,
  });

  String get durationText => OSRMService()._formatDuration(duration);
  String get distanceText => OSRMService()._formatDistance(distance.toDouble());
}
