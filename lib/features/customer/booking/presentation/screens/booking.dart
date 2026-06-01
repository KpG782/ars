import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arsapplication/features/customer/auth/data/repositories/firebase_auth_repository.dart';
import 'package:arsapplication/features/customer/auth/domain/repositories/auth_repository.dart';
import 'package:arsapplication/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:arsapplication/core/utils/toast_helper.dart';

// Import components
import '../widgets/booking_drawer.dart';
import '../widgets/booking_bottom_panels.dart';
import '../widgets/booking_enums.dart';
import '../../domain/models/mechanic.dart';
import '../../domain/models/mechanic_shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/firestore_shop_repository.dart';
import '../../../../../core/services/osrm_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  // Repositories (Dependency Injection)
  late final ShopRepository _shopRepository;
  late final AuthRepository _authRepository;
  final OSRMService _osrmService = OSRMService();

  static const LatLng _defaultLocation = LatLng(
    14.5995,
    120.9842,
  ); // Fallback only
  LatLng? _currentPosition; // Nullable - no default until location is fetched
  bool _isInitialLoading = true;
  bool _locationRequested = false;

  String? _selectedService;
  String? _selectedSubService;
  BookingStatus _bookingStatus = BookingStatus.initial;

  // Mechanic management
  List<Mechanic> _availableMechanics = [];
  Mechanic? _selectedMechanic;

  // Shop management
  List<MechanicShop> _nearbyShops = [];
  MechanicShop? _selectedShop;
  bool _showShopsOnMap = true;

  // Route display
  List<LatLng> _routePoints = [];
  Timer? _routeUpdateTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 BookingScreen initState called');

    // Initialize repositories
    _shopRepository = FirestoreShopRepository();
    _authRepository = FirebaseAuthRepository();

    // Force load shops immediately with default location
    _currentPosition = _defaultLocation;
    _loadNearbyShops();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    debugPrint('🏁 _initializeScreen started');
    if (!mounted) return;

    setState(() => _isInitialLoading = true);

    try {
      debugPrint('📡 Getting current location...');
      // Add timeout to prevent hanging
      await _getCurrentLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // Use fallback location on timeout
          if (mounted) {
            setState(() {
              _currentPosition = _defaultLocation;
            });
            ToastHelper.showWarning(
              context,
              'Could not get location. Using default location.',
            );
          }
        },
      );

      // Minimum load time for smooth UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Ensure we have a location
      if (_currentPosition == null) {
        debugPrint('⚠️ No position found, using default');
        setState(() {
          _currentPosition = _defaultLocation;
        });
      } else {
        debugPrint('📍 Current position set: $_currentPosition');
      }

      // Load nearby shops after location is set
      debugPrint(
        '🏪 About to call _loadNearbyShops, position: $_currentPosition',
      );
      if (_currentPosition != null) {
        _loadNearbyShops();
      } else {
        debugPrint('❌ Cannot load shops - no current position!');
      }
    } catch (e) {
      if (mounted) {
        // Fallback to default location on error
        setState(() {
          _currentPosition = _defaultLocation;
        });

        ToastHelper.showInfo(context, 'Using default location');

        // Still load shops with default location
        _loadNearbyShops();
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  /// Load nearby mechanic shops
  void _loadNearbyShops() async {
    debugPrint('🔍 _loadNearbyShops called');
    debugPrint('📍 Current position: $_currentPosition');

    if (_currentPosition == null) {
      debugPrint('❌ No current position, skipping shop load');
      return;
    }

    try {
      final shops = await _shopRepository.getShopsNearLocation(
        location: _currentPosition!,
        radiusKm: 10.0,
      );

      if (mounted) {
        setState(() {
          _nearbyShops = shops;
        });
        debugPrint('✅ Loaded ${shops.length} shops');
      }
    } catch (e) {
      debugPrint('❌ Error loading shops: $e');
      if (mounted) {
        ToastHelper.showError(context, 'Failed to load nearby shops');
      }
    }
  }

  @override
  void dispose() {
    _routeUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await _authRepository.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const UserTypeSelectionScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error logging out: ${e.toString()}');
      }
    }
  }

  /// Shows confirmation dialog before canceling active booking
  Future<void> _confirmCancelBooking(BuildContext context) async {
    // Determine the message based on booking status
    String title = 'Cancel Booking?';
    String message = 'Are you sure you want to cancel this booking?';
    String confirmText = 'Yes, Cancel';

    if (_bookingStatus == BookingStatus.confirmed) {
      title = 'Cancel Active Service?';
      message =
          'A mechanic is on the way to your location. Canceling now may result in a cancellation fee. Do you want to continue?';
      confirmText = 'Cancel Service';
    } else if (_bookingStatus == BookingStatus.searching) {
      message =
          'We are currently finding a mechanic for you. Do you want to cancel the search?';
    } else if (_bookingStatus == BookingStatus.serviceSelection ||
        _bookingStatus == BookingStatus.subServiceSelection) {
      message = 'Do you want to cancel and start over?';
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: AppTheme.fontSize15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (confirmed == true) {
      _resetBookingState();

      // Show confirmation message
      ToastHelper.showSuccess(
        context,
        'Booking canceled successfully',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _resetBookingState() {
    if (mounted) {
      // Cancel live route updates
      _routeUpdateTimer?.cancel();

      setState(() {
        _bookingStatus = BookingStatus.initial;
        _selectedService = null;
        _selectedSubService = null;
        _availableMechanics = [];
        _selectedMechanic = null;
        _routePoints = []; // Clear route
      });
    }
  }

  /// Checks if user is in an active booking state
  bool _hasActiveBooking() {
    return _bookingStatus != BookingStatus.initial &&
        _bookingStatus != BookingStatus.serviceSelection &&
        _bookingStatus != BookingStatus.subServiceSelection;
  }

  /// Shows warning when user tries to navigate away during active booking
  Future<bool> _onWillPop() async {
    if (!_hasActiveBooking()) {
      return true; // Allow navigation
    }

    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app, color: AppTheme.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Leave Booking?',
                style: TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'You have an active booking in progress. Leaving this screen will not cancel your booking. Do you want to continue?',
            style: TextStyle(fontSize: AppTheme.fontSize15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Stay Here',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  void _handleEmergencyBooking() {
    setState(() {
      _bookingStatus = BookingStatus.emergency;
      _selectedService = 'Emergency';
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_locationRequested) return;
    _locationRequested = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentPosition = _defaultLocation;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentPosition = _defaultLocation;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentPosition = _defaultLocation;
          });
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
        // Reload shops with new location
        _loadNearbyShops();
        // Don't try to move map here - it's not rendered yet!
        // The map will use _currentPosition as initialCenter
      }
    } catch (e) {
      debugPrint('⚠️ Location error: $e');
      if (mounted) {
        // Use fallback location on error
        setState(() {
          _currentPosition = _defaultLocation;
        });
        // Load shops even with default location
        _loadNearbyShops();
      }
    }
  }

  // Search for nearby mechanics and calculate real ETA using OSRM
  Future<void> _searchMechanics() async {
    if (_currentPosition == null) return; // Don't search if no location yet

    setState(() {
      _availableMechanics = [];
      _selectedMechanic = null;
    });

    // Simulate search delay (in real app, this would query Firebase)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _currentPosition == null) return;

    // Simulate 5 mechanics around user location
    final userLoc = _currentPosition!;
    final mechanicLocations = [
      Mechanic(
        name: "Juan Dela Cruz",
        location: LatLng(userLoc.latitude + 0.01, userLoc.longitude + 0.01),
        etaMinutes: 10,
        id: "mech_001",
        phoneNumber: "+63 917 123 4567",
        rating: 4.8,
      ),
      Mechanic(
        name: "Pedro Santos",
        location: LatLng(userLoc.latitude + 0.02, userLoc.longitude - 0.01),
        etaMinutes: 15,
        id: "mech_002",
        phoneNumber: "+63 918 234 5678",
        rating: 4.9,
      ),
      Mechanic(
        name: "Maria Lopez",
        location: LatLng(userLoc.latitude - 0.01, userLoc.longitude + 0.02),
        etaMinutes: 8,
        id: "mech_003",
        phoneNumber: "+63 919 345 6789",
        rating: 4.6,
      ),
      Mechanic(
        name: "Jose Garcia",
        location: LatLng(userLoc.latitude - 0.02, userLoc.longitude - 0.02),
        etaMinutes: 20,
        id: "mech_004",
        phoneNumber: "+63 920 456 7890",
        rating: 4.7,
      ),
      Mechanic(
        name: "Ana Reyes",
        location: LatLng(userLoc.latitude + 0.015, userLoc.longitude - 0.015),
        etaMinutes: 12,
        id: "mech_005",
        phoneNumber: "+63 921 567 8901",
        rating: 4.5,
      ),
    ];

    debugPrint(
      '🔍 Calculating real-time ETA for ${mechanicLocations.length} mechanics...',
    );

    // Calculate real ETA using OSRM for each mechanic
    final List<MapEntry<Mechanic, ETAResult>> mechanicsWithETA = [];

    for (final mechanic in mechanicLocations) {
      try {
        final eta = await _osrmService.calculateETA(
          origin: mechanic.location,
          destination: userLoc,
        );

        mechanicsWithETA.add(MapEntry(mechanic, eta));

        debugPrint(
          '✅ ${mechanic.name}: ${eta.durationText} (${eta.distanceText})',
        );
      } catch (e) {
        debugPrint('⚠️ Failed to calculate ETA for ${mechanic.name}: $e');
        // Use fallback ETA if OSRM fails
        mechanicsWithETA.add(
          MapEntry(
            mechanic,
            ETAResult(
              durationInSeconds: mechanic.etaMinutes * 60,
              distanceInMeters: 0,
              durationText: '${mechanic.etaMinutes} min',
              distanceText: 'N/A',
              isAccurate: false,
            ),
          ),
        );
      }
    }

    // Sort by ETA (shortest first)
    mechanicsWithETA.sort(
      (a, b) => a.value.durationInSeconds.compareTo(b.value.durationInSeconds),
    );

    // Update mechanics with real ETA values
    final sortedMechanics = mechanicsWithETA.map((entry) {
      final mechanic = entry.key;
      final eta = entry.value;

      return mechanic.copyWith(etaMinutes: eta.durationInMinutes);
    }).toList();

    if (mounted) {
      setState(() {
        _availableMechanics = sortedMechanics;
        _selectedMechanic = sortedMechanics.first; // Select nearest mechanic
        _bookingStatus = BookingStatus.confirmed;
      });

      debugPrint(
        '✅ Found ${sortedMechanics.length} mechanics. Nearest: ${sortedMechanics.first.name} (${sortedMechanics.first.etaMinutes} min)',
      );

      // Fetch and display route on map
      _fetchAndDisplayRoute();

      // Start live route updates (every 30 seconds)
      _startLiveRouteUpdates();
    }
  }

  // Fetch route from OSRM and display on map
  Future<void> _fetchAndDisplayRoute() async {
    if (_selectedMechanic == null || _currentPosition == null) return;

    debugPrint('🗺️ Fetching route for map display...');

    try {
      final route = await _osrmService.getRoute(
        origin: _selectedMechanic!.location,
        destination: _currentPosition!,
      );

      if (route != null && mounted) {
        setState(() {
          _routePoints = route.coordinates;
        });
        debugPrint('✅ Route displayed: ${route.coordinates.length} points');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch route: $e');
    }
  }

  // Start live route updates
  void _startLiveRouteUpdates() {
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_bookingStatus == BookingStatus.confirmed) {
        _fetchAndDisplayRoute();
      } else {
        _routeUpdateTimer?.cancel();
      }
    });
  }

  void _onServiceSelected(String service) {
    setState(() {
      _selectedService = service;
      _selectedSubService = null;
    });
  }

  void _onSubServiceSelected(String subService) {
    setState(() {
      _selectedSubService = subService;
    });

    // If emergency service was selected, auto-search mechanics
    if (_selectedService == 'Emergency') {
      _searchMechanics().then((_) {
        if (mounted && _availableMechanics.isNotEmpty) {
          // Auto-select closest mechanic for emergency
          setState(() {
            _selectedMechanic = _availableMechanics.first;
          });

          ToastHelper.showError(
            context,
            'Emergency broadcast! ${_availableMechanics.length} mechanics notified.',
            duration: const Duration(seconds: 3),
          );
        }
      });
    }
  }

  void _onBookingStatusChanged(BookingStatus status) {
    setState(() {
      _bookingStatus = status;
    });

    // Trigger mechanic search when status changes to searching
    if (status == BookingStatus.searching) {
      _searchMechanics();
    }
  }

  void _showMechanicDetails(Mechanic mechanic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with photo and basic info
            Row(
              children: [
                // Mechanic photo or placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.grey300,
                    shape: BoxShape.circle,
                    image: mechanic.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(mechanic.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: mechanic.photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: AppTheme.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Rating stars
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < mechanic.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mechanic.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact info
            if (mechanic.phoneNumber != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, color: AppTheme.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mechanic.phoneNumber!,
                      style: const TextStyle(fontSize: AppTheme.fontSize16),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final phone = mechanic.phoneNumber;
                      if (phone != null && phone.isNotEmpty) {
                        final uri = Uri(scheme: 'tel', path: phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    icon: const Icon(Icons.call, color: AppTheme.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ETA info
            Row(
              children: [
                const Icon(Icons.access_time, color: AppTheme.orange),
                const SizedBox(width: 12),
                Text(
                  'ETA: ${mechanic.etaMinutes} minutes',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedMechanic = mechanic;
                    _bookingStatus = BookingStatus.searching;
                  });
                  _searchMechanics();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select This Mechanic',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// Show shop details in a bottom sheet
  void _showShopDetails(MechanicShop shop) {
    if (_currentPosition == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Shop header with status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  shop.shopName,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSize22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (shop.isPartner)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'PARTNER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTheme.fontSize10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Rating
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < shop.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${shop.rating.toStringAsFixed(1)} (${shop.totalReviews} reviews)',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSize14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Open/Closed status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: shop.isOpen ? AppTheme.green50 : AppTheme.red50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: shop.isOpen ? AppTheme.green : AppTheme.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        shop.isOpen ? Icons.check_circle : Icons.cancel,
                        color: shop.isOpen ? AppTheme.green : AppTheme.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shop.isOpen ? 'Open Now' : 'Closed',
                        style: TextStyle(
                          color: shop.isOpen ? AppTheme.green : AppTheme.red,
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.fontSize14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shop.getTodayHours(),
                        style: TextStyle(
                          color: shop.isOpen
                              ? AppTheme.green700
                              : AppTheme.red700,
                          fontSize: AppTheme.fontSize12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Distance and price range
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'Distance',
                        value: shop.getDistanceString(_currentPosition!),
                        color: AppTheme.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.attach_money,
                        title: 'Price Range',
                        value: shop.priceRange,
                        color: AppTheme.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                if (shop.description != null) ...[
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shop.description!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize14,
                      color: AppTheme.grey700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Services offered
                const Text(
                  'Services Offered',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shop.services.map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Contact info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shop.address,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSize13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            shop.phoneNumber,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize13,
                            ),
                          ),
                        ],
                      ),
                      if (shop.owner != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Owner: ${shop.owner}',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSize13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                if (shop.isPartner && shop.isOpen) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ToastHelper.showSuccess(
                          context,
                          'Selected ${shop.shopName}',
                        );
                        setState(() {
                          _selectedShop = shop;
                        });
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Request Service from This Shop',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            shop.isPartner
                                ? 'This shop is currently closed. Check back during operating hours.'
                                : 'This shop is not yet partnered with us. You can view details but cannot request services.',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSize11,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint(
      '🎨 BUILD: _nearbyShops.length = ${_nearbyShops.length}, _showShopsOnMap = $_showShopsOnMap',
    );
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
        drawer: BookingDrawer(onLogout: _logout, scaffoldKey: _scaffoldKey),
        body: _isInitialLoading || _currentPosition == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize16,
                        color: AppTheme.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
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
                      initialCenter: _currentPosition!,
                      initialZoom: 14,
                      minZoom: 8,
                      maxZoom: 18,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag
                            .all, // Enable all interactions including rotation
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
                      // Polyline route from mechanic to customer (live updates)
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: AppTheme.primaryColor,
                              strokeWidth: 4.0,
                              borderColor: Colors.white,
                              borderStrokeWidth: 1.5,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          // User location marker
                          Marker(
                            point: _currentPosition!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: AppTheme.red,
                            ),
                          ),
                          // Shop markers (when shops should be shown)
                          if (_showShopsOnMap)
                            ..._nearbyShops.map(
                              (shop) => Marker(
                                point: shop.location,
                                width: 60,
                                height: 85,
                                child: GestureDetector(
                                  onTap: () => _showShopDetails(shop),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: shop == _selectedShop
                                              ? AppTheme.primaryColor
                                              : (shop.isPartner
                                                    ? (shop.isOpen
                                                          ? AppTheme.green
                                                          : AppTheme.orange)
                                                    : AppTheme.grey),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          shop.isPartner
                                              ? Icons.store
                                              : Icons.store_outlined,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
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
                              ),
                            ),
                          // Mechanic markers (when available)
                          ..._availableMechanics.map(
                            (mechanic) => Marker(
                              point: mechanic.location,
                              width: 50,
                              height: 50,
                              child: GestureDetector(
                                onTap: () => _showMechanicDetails(mechanic),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mechanic == _selectedMechanic
                                        ? AppTheme.primaryColor
                                        : AppTheme.orange,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.build,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Menu button and Search bar row
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
                                      hintText: 'Search location...',
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
                                      // TODO: Implement location search
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.my_location,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      _locationRequested = false;
                                      await _getCurrentLocation();
                                      if (_currentPosition != null) {
                                        _mapController.move(
                                          _currentPosition!,
                                          14,
                                        );
                                      }
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
                  // Shop filter button (below search bar, right side)
                  Positioned(
                    top:
                        106, // 50 (search bar top) + 48 (search bar height) + 8 (gap)
                    right: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _showShopsOnMap
                                  ? AppTheme.primaryColor
                                  : AppTheme.grey300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showShopsOnMap = !_showShopsOnMap;
                                });
                                ToastHelper.showInfo(
                                  context,
                                  _showShopsOnMap
                                      ? 'Showing ${_nearbyShops.length} shops'
                                      : 'Shops hidden',
                                );
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  _showShopsOnMap
                                      ? Icons.store
                                      : Icons.store_outlined,
                                  color: _showShopsOnMap
                                      ? AppTheme.primaryColor
                                      : AppTheme.grey,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Badge showing shop count
                        if (_nearbyShops.isNotEmpty && _showShopsOnMap)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '${_nearbyShops.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.fontSize10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  BookingBottomPanels(
                    bookingStatus: _bookingStatus,
                    selectedService: _selectedService,
                    selectedSubService: _selectedSubService,
                    onServiceSelected: _onServiceSelected,
                    onSubServiceSelected: _onSubServiceSelected,
                    onBookingStatusChanged: _onBookingStatusChanged,
                    onResetBooking: () => _confirmCancelBooking(context),
                    mechanic: _selectedMechanic,
                    customerLocation:
                        _currentPosition!, // Not null in this context
                    onEmergencyPressed: _handleEmergencyBooking,
                  ),
                ],
              ),
      ),
    );
  }
}
