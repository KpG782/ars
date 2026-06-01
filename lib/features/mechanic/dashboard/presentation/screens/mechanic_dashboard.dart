import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arsapplication/main.dart';

// Import services
import '../../../../../core/services/osrm_service.dart';
import '../../../../../core/utils/toast_helper.dart';

// Import components
import '../widgets/mechanic_drawer.dart';
import '../widgets/mechanic_enums.dart';
import '../widgets/mechanic_bottom_panels.dart';
import '../../domain/models/service_request.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});

  @override
  State<MechanicDashboard> createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  final OSRMService _osrmService = OSRMService();

  static const LatLng _defaultLocation = LatLng(14.5995, 120.9842);
  LatLng _currentPosition = _defaultLocation;
  bool _isInitialLoading = true;
  bool _isLoadingLocation = false;
  bool _isLoadingRequests = false;
  bool _locationRequested = false;
  bool _isOnline = false;

  MechanicStatus _mechanicStatus = MechanicStatus.offline;
  List<ServiceRequest> _nearbyRequests = [];
  ServiceRequest? _acceptedRequest;
  List<LatLng> _routePoints = [];
  String _etaText = '15 minutes';
  String _distanceText = '0 km';
  StreamSubscription<Position>? _positionSubscription;
  bool _isLoadingRoute = false;
  bool _isMapReady = false;
  bool _isTogglingOnline = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ToastHelper.init(context);
    });
    _initializeDashboard();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    if (!mounted) return;

    // Show initial loading state
    setState(() => _isInitialLoading = true);

    try {
      // Load location + backend status in parallel
      await Future.wait([
        _getCurrentLocation(),
        _syncOnlineStatusFromBackend(),
        // Minimum loading time for smooth UX (prevents flashing)
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);

      if (_isOnline) {
        await _updateBackendLocation();
      }

      // Load requests after online state is known
      await _loadNearbyRequests();
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error initializing dashboard');
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Prevent exit if actively working on a service
    if (_mechanicStatus == MechanicStatus.working ||
        _mechanicStatus == MechanicStatus.enRoute) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Active Service',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mechanicStatus == MechanicStatus.working
                    ? 'You are currently working on a service.'
                    : 'You are on your way to a customer.',
                style: const TextStyle(fontSize: AppTheme.fontSize15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.red.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exiting now will affect your rating and may result in penalties.',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize13,
                          color: AppTheme.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please complete the service first, then you can safely exit.',
                style: TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Continue Service',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Force Exit',
                style: TextStyle(color: AppTheme.red),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }

    // Normal exit for other statuses
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _logout() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      if (_isOnline) {
        try {
          await _persistOnlineStatus(false);
        } catch (_) {}
      }

      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const UserTypeSelectionScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        ToastHelper.showError(context, 'Error logging out: ${e.toString()}');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_locationRequested) return;
    _locationRequested = true;

    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ToastHelper.showWarning(context, 'Location services are disabled');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ToastHelper.showError(context, 'Location permission denied');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ToastHelper.showError(
            context,
            'Location permissions permanently denied. Please enable in settings.',
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Safely move map controller
        try {
          _mapController.move(_currentPosition, 15.0);
        } catch (e) {
          // Map controller not ready yet, will be set when map loads
          debugPrint('Map controller not ready: $e');
        }

        // Keep backend location fresh for discovery when online
        if (_isOnline) {
          await _updateBackendLocation();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error getting location';

        // Provide more specific error messages
        if (e.toString().contains('permission')) {
          errorMessage = 'Location permission denied';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Location request timed out';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error while getting location';
        }

        ToastHelper.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _loadNearbyRequests() async {
    setState(() => _isLoadingRequests = true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate nearby service requests
      if (mounted) {
        setState(() {
          _nearbyRequests = [
            ServiceRequest(
              id: '1',
              customerName: 'Juan Dela Cruz',
              location: LatLng(
                _currentPosition.latitude + 0.01,
                _currentPosition.longitude + 0.01,
              ),
              serviceType: 'Tire Problem',
              description: 'Flat tire need immediate assistance',
              estimatedPrice: 300.0,
              requestTime: DateTime.now().subtract(const Duration(minutes: 5)),
              customerNotes: 'Please hurry, I\'m on the side of the highway',
              isEmergency: true,
            ),
            ServiceRequest(
              id: '2',
              customerName: 'Maria Santos',
              location: LatLng(
                _currentPosition.latitude - 0.015,
                _currentPosition.longitude + 0.02,
              ),
              serviceType: 'Brake Problem',
              description: 'Brake making squeaking noise',
              estimatedPrice: 500.0,
              requestTime: DateTime.now().subtract(const Duration(minutes: 10)),
              customerNotes: 'Check both front brakes if possible',
              appliedPromoCode: 'FIRST50',
              discountApplied: 50.0,
            ),
            ServiceRequest(
              id: '3',
              customerName: 'Pedro Garcia',
              location: LatLng(
                _currentPosition.latitude + 0.02,
                _currentPosition.longitude - 0.01,
              ),
              serviceType: 'Engine Problems',
              description: 'Car won\'t start, possible battery issue',
              estimatedPrice: 400.0,
              requestTime: DateTime.now().subtract(const Duration(minutes: 15)),
              customerNotes:
                  'Battery might be dead, please bring jumper cables',
              tipAmount: 50.0,
            ),
          ];
        });

        // Sort requests: Emergency first, then by time
        _nearbyRequests.sort((a, b) {
          // Emergency requests always come first
          if (a.isEmergency && !b.isEmergency) return -1;
          if (!a.isEmergency && b.isEmergency) return 1;

          // If both are emergency or both are regular, sort by request time (newer first)
          return b.requestTime.compareTo(a.requestTime);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error loading service requests');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  Future<void> _syncOnlineStatusFromBackend() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(uid)
          .get();
      final data = doc.data();
      final backendOnline = data?['isOnline'] == true;

      if (!mounted) return;
      setState(() {
        _isOnline = backendOnline;
        _mechanicStatus = backendOnline
            ? MechanicStatus.available
            : MechanicStatus.offline;
      });
    } catch (_) {
      // Keep local defaults if backend read fails
    }
  }

  Future<void> _updateBackendLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('mechanics').doc(uid).set({
      'location': {
        'lat': _currentPosition.latitude,
        'lng': _currentPosition.longitude,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _persistOnlineStatus(bool isOnline) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No authenticated mechanic');
    }

    final data = <String, dynamic>{
      'isOnline': isOnline,
      'status': isOnline ? 'available' : 'offline',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isOnline) {
      data['location'] = {
        'lat': _currentPosition.latitude,
        'lng': _currentPosition.longitude,
      };
    }

    await FirebaseFirestore.instance
        .collection('mechanics')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  void _toggleOnlineStatus() async {
    if (_isTogglingOnline) return;

    // Prevent going offline if actively serving
    if (_isOnline &&
        (_mechanicStatus == MechanicStatus.working ||
            _mechanicStatus == MechanicStatus.enRoute)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.block, color: AppTheme.red, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cannot Go Offline',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'You have an active service. Please complete the current service before going offline.',
            style: TextStyle(fontSize: AppTheme.fontSize15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Show confirmation when going offline
    if (_isOnline) {
      final shouldGoOffline = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Go Offline?',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You will stop receiving new service requests.',
                style: TextStyle(fontSize: AppTheme.fontSize15),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can go online again anytime',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go Offline',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (shouldGoOffline != true) return;
    }

    final nextOnline = !_isOnline;

    setState(() => _isTogglingOnline = true);
    try {
      await _persistOnlineStatus(nextOnline);
      if (!mounted) return;

      setState(() {
        _isOnline = nextOnline;
        _mechanicStatus = nextOnline
            ? MechanicStatus.available
            : MechanicStatus.offline;
      });

      if (_isOnline) {
        await _loadNearbyRequests();
        if (!mounted) return;
        ToastHelper.showSuccess(
          context,
          'You are now online and available for requests',
        );
      } else {
        ToastHelper.showInfo(context, 'You are now offline');
      }
    } catch (_) {
      if (mounted) {
        ToastHelper.showError(
          context,
          'Failed to update online status. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingOnline = false);
      }
    }
  }

  void _onStatusChanged(MechanicStatus status) {
    setState(() {
      _mechanicStatus = status;
      // Clear accepted request and route when returning to available state
      if (status == MechanicStatus.available) {
        _acceptedRequest = null;
        _routePoints = [];
        _etaText = '15 minutes';
        _distanceText = '0 km';
        _positionSubscription?.cancel();
        _positionSubscription = null;
        _isLoadingRoute = false;
      }
    });
  }

  void _onRequestAccepted(ServiceRequest request) async {
    setState(() {
      _acceptedRequest = request;
      _mechanicStatus = MechanicStatus.enRoute;
      _isLoadingRoute = true;
      // Show loading state with straight line
      _routePoints = [_currentPosition, request.location];
      _etaText = 'Calculating...';
      _distanceText = 'Calculating...';
    });

    // Center map on mechanic at start (only if map is ready)
    if (_isMapReady) {
      _mapController.move(_currentPosition, 16);
    }

    // Start real-time location tracking
    _startLocationTracking();

    // Fetch initial route from OSRM
    await _updateRouteAndETA();

    setState(() {
      _isLoadingRoute = false;
    });
  }

  void _startLocationTracking() {
    // Listen to position changes every 10 seconds
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((Position position) async {
          if (!mounted || _mechanicStatus != MechanicStatus.enRoute) return;

          final newPosition = LatLng(position.latitude, position.longitude);

          // Only update if position changed significantly (more than 15 meters)
          final distance = Geolocator.distanceBetween(
            _currentPosition.latitude,
            _currentPosition.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );

          if (distance > 15) {
            setState(() {
              _currentPosition = newPosition;
            });

            // Keep map centered on mechanic (navigation mode, only if map is ready)
            if (_isMapReady) {
              _mapController.move(_currentPosition, 16);
            }

            // Update route and ETA with new position
            _updateRouteAndETA();

            if (_isOnline) {
              try {
                await _updateBackendLocation();
              } catch (_) {}
            }

            debugPrint(
              '📍 Position updated: ${distance.toStringAsFixed(0)}m moved',
            );
          }
        });
  }

  Future<void> _updateRouteAndETA() async {
    if (_acceptedRequest == null) return;

    try {
      debugPrint('🚗 Fetching route from mechanic to customer...');
      final routeResult = await _osrmService.getRoute(
        origin: _currentPosition,
        destination: _acceptedRequest!.location,
      );

      if (routeResult != null && mounted) {
        setState(() {
          // Use OSRM route coordinates for realistic path
          _routePoints = routeResult.coordinates;

          // Update with real ETA from OSRM
          final minutes = (routeResult.duration / 60).ceil();
          _etaText = minutes <= 1 ? '< 1 minute' : '$minutes minutes';

          // Update distance in kilometers
          final distanceKm = routeResult.distance / 1000;
          if (distanceKm < 0.1) {
            _distanceText = '${(routeResult.distance).toStringAsFixed(0)} m';
          } else if (distanceKm < 1) {
            _distanceText = '${(distanceKm * 1000).toStringAsFixed(0)} m';
          } else {
            _distanceText = '${distanceKm.toStringAsFixed(1)} km';
          }
        });
        debugPrint(
          '✅ Route updated: ${_routePoints.length} points, ETA: $_etaText, Distance: $_distanceText',
        );
      } else if (mounted) {
        // Fallback to straight line if OSRM fails
        setState(() {
          _etaText = '~15 minutes';
          _distanceText = '~5 km';
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching route: $e');
      if (mounted) {
        setState(() {
          _etaText = '~15 minutes';
          _distanceText = '~5 km';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: MechanicDrawer(onLogout: _logout, scaffoldKey: _scaffoldKey),
        body: _isInitialLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading Dashboard...',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize16,
                        color: AppTheme.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoadingLocation
                          ? 'Getting your location...'
                          : _isLoadingRequests
                          ? 'Loading service requests...'
                          : 'Initializing...',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.grey500,
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition,
                      initialZoom: 14,
                      minZoom: 8,
                      maxZoom: 18,
                      onMapReady: () {
                        setState(() => _isMapReady = true);
                        // Move to current position once map is ready
                        if (_currentPosition != _defaultLocation) {
                          _mapController.move(_currentPosition, 15.0);
                        }
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
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
                      // Polyline layer - shows route to customer
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              strokeWidth: 4.0,
                              color: AppTheme.blue,
                              borderStrokeWidth: 2.0,
                              borderColor: Colors.white,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          // Mechanic location marker
                          Marker(
                            point: _currentPosition,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isOnline
                                    ? AppTheme.primaryColor
                                    : AppTheme.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.wrench,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                          // Customer location marker (when request accepted)
                          if (_acceptedRequest != null)
                            Marker(
                              point: _acceptedRequest!.location,
                              width: 50,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_pin,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          // Service request markers (only show when available)
                          if (_isOnline && _acceptedRequest == null)
                            ..._nearbyRequests.map(
                              (request) => Marker(
                                point: request.location,
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () {
                                    // Show request details
                                    _showRequestDetails(request);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  // Route loading indicator
                  if (_isLoadingRoute)
                    Positioned(
                      top: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Loading route...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTheme.fontSize14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Top Bar - Menu button and Search bar row
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Menu button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            icon: const Icon(
                              Icons.menu,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Search bar
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, right: 8),
                                  child: Icon(
                                    Icons.search,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSize14,
                                      color: Colors.black87,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Search requests...',
                                      hintStyle: TextStyle(
                                        color: AppTheme.grey400,
                                        fontSize: AppTheme.fontSize14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      // TODO: Implement request search
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Online/Offline Status Button
                  Positioned(
                    top: 110,
                    right: 20,
                    child: GestureDetector(
                      onTap: _toggleOnlineStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _isOnline
                              ? AppTheme.primaryColor
                              : AppTheme.grey600,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOnline
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.fontSize14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recenter button (when in navigation mode)
                  if (_mechanicStatus == MechanicStatus.enRoute)
                    Positioned(
                      right: 20,
                      bottom: 240,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (_isMapReady) {
                            _mapController.move(_currentPosition, 16);
                            ToastHelper.showInfo(
                              context,
                              'Map centered on your location',
                              duration: const Duration(seconds: 1),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                  // Bottom Panels (Offline, Available, EnRoute, Working, Completed)
                  MechanicBottomPanels(
                    mechanicStatus: _mechanicStatus,
                    nearbyRequests: _nearbyRequests,
                    acceptedRequest: _acceptedRequest,
                    isOnline: _isOnline,
                    onStatusChanged: _onStatusChanged,
                    onRequestAccepted: _onRequestAccepted,
                    onToggleOnline: _toggleOnlineStatus,
                    etaText: _etaText,
                    distanceText: _distanceText,
                  ),
                ],
              ),
      ),
    );
  }

  void _showRequestDetails(ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.user, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  request.customerName,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Service: ${request.serviceType}',
              style: const TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              request.description,
              style: const TextStyle(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Estimated Price: ₱${request.estimatedPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _onRequestAccepted(request);
                },
                child: const Text(
                  'Accept Request',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
