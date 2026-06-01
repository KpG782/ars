import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../../core/utils/toast_helper.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/openroute_booking_repository.dart';

class BookingRequestMapScreen extends StatefulWidget {
  final LatLng mechanicLocation = const LatLng(14.5995, 120.9842); // Manila
  final LatLng userLocation = const LatLng(14.5547, 121.0244); // Makati

  const BookingRequestMapScreen({super.key});

  @override
  State<BookingRequestMapScreen> createState() =>
      _BookingRequestMapScreenState();
}

class _BookingRequestMapScreenState extends State<BookingRequestMapScreen> {
  List<LatLng> routePoints = [];
  Timer? _timer;
  bool _isActive = true;

  // Repository (Dependency Injection)
  late final BookingRepository _bookingRepository;

  @override
  void initState() {
    super.initState();
    // Initialize repository (in production, use dependency injection)
    _bookingRepository = OpenRouteServiceBookingRepository(
      apiKey:
          'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImFhZWI3MmM4MDNlNDRhMTk4MTJjNmNlODkwN2Q4NjBiIiwiaCI6Im11cm11cjY0In0=',
    );
    _fetchRoute();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isActive) {
        _fetchRoute();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    if (!_isActive) return;

    try {
      final route = await _bookingRepository.getRoute(
        mechanicLocation: widget.mechanicLocation,
        userLocation: widget.userLocation,
      );

      if (mounted && _isActive) {
        setState(() {
          routePoints = route;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to fetch route: $e');
      }
    }
  }

  void _stopNavigation() async {
    setState(() {
      _isActive = false;
      routePoints = [];
    });
    _timer?.cancel();

    await _bookingRepository.cancelNavigation();

    if (mounted) {
      ToastHelper.showError(context, 'Navigation to user stopped.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Request Map'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.mechanicLocation,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
            userAgentPackageName: 'com.example.arsapplication',
            maxZoom: 20,
            subdomains: const ['a', 'b', 'c', 'd'],
            retinaMode: true,
            tileProvider: NetworkTileProvider(),
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: AppTheme.blue,
                  strokeWidth: 4,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.mechanicLocation,
                width: 60,
                height: 60,
                child: const Column(
                  children: [
                    Icon(
                      LucideIcons.wrench,
                      color: AppTheme.primaryColor,
                      size: 36,
                    ),
                    Text(
                      "You",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSize12,
                      ),
                    ),
                  ],
                ),
              ),
              Marker(
                point: widget.userLocation,
                width: 60,
                height: 60,
                child: const Column(
                  children: [
                    Icon(LucideIcons.map_pin, color: AppTheme.red, size: 36),
                    Text(
                      "User",
                      style: TextStyle(
                        color: AppTheme.red,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSize12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _isActive
          ? FloatingActionButton.extended(
              onPressed: _stopNavigation,
              backgroundColor: AppTheme.red,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Navigation'),
            )
          : null,
    );
  }
}
