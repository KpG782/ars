/// Booking Map Widget - Displays interactive map with markers
///
/// A reusable map component for the booking feature.
/// Handles map display, markers, and route polylines.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/models/mechanic.dart';
import '../../domain/models/mechanic_shop.dart';

/// Widget for displaying the booking map
class BookingMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentPosition;
  final List<MechanicShop> nearbyShops;
  final List<Mechanic> availableMechanics;
  final MechanicShop? selectedShop;
  final Mechanic? selectedMechanic;
  final List<LatLng> routePoints;
  final bool showShops;
  final List<Mechanic> onlineMechanics;
  final bool showMechanics;
  final Function(MechanicShop)? onShopTap;
  final Function(Mechanic)? onMechanicTap;

  const BookingMapWidget({
    super.key,
    required this.mapController,
    required this.currentPosition,
    this.nearbyShops = const [],
    this.availableMechanics = const [],
    this.selectedShop,
    this.selectedMechanic,
    this.routePoints = const [],
    this.showShops = true,
    this.onlineMechanics = const [],
    this.showMechanics = false,
    this.onShopTap,
    this.onMechanicTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 14,
        minZoom: 8,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Map tiles
        TileLayer(
          urlTemplate:
              "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
          userAgentPackageName: 'com.example.arsapplication',
          maxZoom: 20,
          subdomains: const ['a', 'b', 'c', 'd'],
          retinaMode: true,
          tileProvider: NetworkTileProvider(),
        ),

        // Route polyline
        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: AppTheme.primaryColor,
                strokeWidth: 4.0,
                borderColor: Colors.white,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // Markers
        MarkerLayer(
          markers: [
            // User location marker
            _buildUserMarker(),

            // Shop markers
            if (showShops) ..._buildShopMarkers(),

            // Online mechanics layer (toggle)
            if (showMechanics) ..._buildOnlineMechanicMarkers(),

            // Route mechanic markers (assigned/confirmed booking)
            ..._buildMechanicMarkers(),
          ],
        ),
      ],
    );
  }

  /// Build user location marker
  Marker _buildUserMarker() {
    return Marker(
      point: currentPosition,
      width: 40,
      height: 40,
      child: const Icon(Icons.location_pin, size: 40, color: AppTheme.red),
    );
  }

  /// Build shop markers
  List<Marker> _buildShopMarkers() {
    return nearbyShops.map((shop) {
      final isSelected = shop == selectedShop;
      final markerColor = isSelected
          ? AppTheme.primaryColor
          : (shop.isPartner
                ? (shop.isOpen ? AppTheme.green : AppTheme.orange)
                : AppTheme.grey);

      return Marker(
        point: shop.location,
        width: 60,
        height: 85,
        child: GestureDetector(
          onTap: () => onShopTap?.call(shop),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: markerColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  shop.isPartner ? Icons.store : Icons.store_outlined,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  shop.shopName.split(' ')[0],
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build online mechanics layer markers (shown when mechanics toggle is on)
  List<Marker> _buildOnlineMechanicMarkers() {
    return onlineMechanics.map((mechanic) {
      return Marker(
        point: mechanic.location,
        width: 60,
        height: 85,
        child: GestureDetector(
          onTap: () => onMechanicTap?.call(mechanic),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.infoTx,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.build, size: 22, color: Colors.white),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  mechanic.name.split(' ')[0],
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build mechanic markers
  List<Marker> _buildMechanicMarkers() {
    return availableMechanics.map((mechanic) {
      final isSelected = mechanic == selectedMechanic;

      return Marker(
        point: mechanic.location,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => onMechanicTap?.call(mechanic),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primaryColor : AppTheme.orange,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.build, size: 24, color: Colors.white),
          ),
        ),
      );
    }).toList();
  }
}
