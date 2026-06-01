/// Mechanic Map Widget
///
/// Reusable map component for mechanic dashboard showing:
/// - Mechanic's current location
/// - Service request locations
/// - Route to accepted request
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

import '../../domain/models/service_request.dart';
import '../../domain/models/mechanic_status.dart';

class MechanicMapWidget extends StatelessWidget {
  final MapController? mapController;
  final LatLng currentPosition;
  final MechanicStatus mechanicStatus;
  final List<ServiceRequest> nearbyRequests;
  final ServiceRequest? acceptedRequest;
  final List<LatLng> routePoints;
  final Function(ServiceRequest)? onRequestTap;

  const MechanicMapWidget({
    super.key,
    this.mapController,
    required this.currentPosition,
    required this.mechanicStatus,
    this.nearbyRequests = const [],
    this.acceptedRequest,
    this.routePoints = const [],
    this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 15.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Map tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.arsapplication',
          maxZoom: 19,
        ),

        // Route polyline
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: AppTheme.infoTx,
                strokeWidth: 5.0,
                borderColor: Colors.white.withValues(alpha: 0.7),
                borderStrokeWidth: 2.0,
              ),
            ],
          ),

        // Service request markers
        if (mechanicStatus == MechanicStatus.available)
          MarkerLayer(markers: _buildRequestMarkers()),

        // Accepted request destination marker
        if (acceptedRequest != null)
          MarkerLayer(markers: [_buildDestinationMarker(acceptedRequest!)]),

        // Mechanic's current location marker
        MarkerLayer(
          markers: [
            Marker(
              point: currentPosition,
              width: 50,
              height: 50,
              child: _buildMechanicMarker(),
            ),
          ],
        ),
      ],
    );
  }

  /// Build mechanic's current location marker
  Widget _buildMechanicMarker() {
    return Container(
      decoration: BoxDecoration(
        color: _getMechanicMarkerColor(),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.build, color: Colors.white, size: 24),
    );
  }

  Color _getMechanicMarkerColor() {
    switch (mechanicStatus) {
      case MechanicStatus.offline:
        return AppTheme.grey;
      case MechanicStatus.available:
        return AppTheme.successColor;
      case MechanicStatus.enRoute:
        return AppTheme.infoColor;
      case MechanicStatus.working:
        return AppTheme.warningColor;
      case MechanicStatus.completed:
        return AppTheme.trustColor;
    }
  }

  /// Build markers for nearby requests
  List<Marker> _buildRequestMarkers() {
    return nearbyRequests.map((request) {
      return Marker(
        point: request.location,
        width: 50,
        height: 60,
        child: GestureDetector(
          onTap: () => onRequestTap?.call(request),
          child: _buildRequestMarkerWidget(request),
        ),
      );
    }).toList();
  }

  Widget _buildRequestMarkerWidget(ServiceRequest request) {
    final isEmergency = request.isEmergency;
    final markerColor = isEmergency ? AppTheme.red : AppTheme.warningColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: markerColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isEmergency ? Icons.warning : Icons.car_repair,
            color: Colors.white,
            size: 20,
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _MarkerPointerPainter(color: markerColor),
        ),
      ],
    );
  }

  /// Build destination marker for accepted request
  Marker _buildDestinationMarker(ServiceRequest request) {
    return Marker(
      point: request.location,
      width: 60,
      height: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
          ),
          CustomPaint(
            size: const Size(14, 10),
            painter: _MarkerPointerPainter(color: AppTheme.successColor),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for marker pointer
class _MarkerPointerPainter extends CustomPainter {
  final Color color;

  _MarkerPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
