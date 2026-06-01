/// Booking Screen - Main booking interface (Refactored)
///
/// Displays map, handles service booking flow, and mechanic search.
/// Uses modular components for maintainability and testability.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:arsapplication/features/customer/auth/data/repositories/firebase_auth_repository.dart';
import 'package:arsapplication/features/customer/auth/domain/repositories/auth_repository.dart';
import 'package:arsapplication/core/routing/app_router.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import 'package:go_router/go_router.dart';

// Feature components
import '../widgets/booking_drawer.dart';
import '../widgets/booking_bottom_panels.dart';
import '../widgets/booking_enums.dart';
import '../widgets/booking_map_widget.dart';
import '../widgets/booking_search_bar.dart';
import '../widgets/booking_dialogs.dart';
import '../widgets/mechanic_details_sheet.dart';
import '../widgets/shop_details_sheet.dart';
import '../controllers/booking_controller.dart';
import 'ai_chat_screen.dart';
import '../../domain/models/mechanic.dart';
import '../../domain/models/mechanic_shop.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  late final AuthRepository _authRepository;

  bool _locationRequested = false;

  static const LatLng _defaultLocation = LatLng(14.5995, 120.9842);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeScreen());
  }

  Future<void> _initializeScreen() async {
    final bookingController = ref.read(bookingControllerProvider.notifier);
    bookingController.setLoading(true);

    try {
      await _getCurrentLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          bookingController.initialize(_defaultLocation);
          if (mounted) {
            ToastHelper.showWarning(
              context,
              'Could not get location. Using default.',
            );
          }
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await bookingController.loadNearbyShops();
    } catch (e) {
      bookingController.initialize(_defaultLocation);
      await bookingController.loadNearbyShops();
      if (mounted) {
        ToastHelper.showInfo(context, 'Using default location');
      }
    } finally {
      bookingController.setLoading(false);
      // After map renders, fit camera to show user + all shop pins
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToShops());
    }
  }

  void _fitMapToShops() {
    final s = ref.read(bookingControllerProvider);
    if (s.currentPosition == null) return;
    if (s.nearbyShops.isEmpty) {
      _mapController.move(s.currentPosition!, 14);
      return;
    }
    final points = [
      s.currentPosition!,
      ...s.nearbyShops.map((sh) => sh.location),
    ];
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(80),
          maxZoom: 14,
        ),
      );
    } catch (_) {
      // controller not ready yet — fall back to user position
      _mapController.move(s.currentPosition!, 13);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_locationRequested) return;
    _locationRequested = true;

    try {
      final bookingController = ref.read(bookingControllerProvider.notifier);
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bookingController.initialize(_defaultLocation);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          bookingController.initialize(_defaultLocation);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        bookingController.initialize(_defaultLocation);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      bookingController.initialize(newPosition);
      await bookingController.loadNearbyShops();
    } catch (e) {
      final bookingController = ref.read(bookingControllerProvider.notifier);
      bookingController.initialize(_defaultLocation);
      await bookingController.loadNearbyShops();
    }
  }

  Future<void> _logout() async {
    try {
      await _authRepository.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        context.go(AppRoutes.userType);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error logging out: ${e.toString()}');
      }
    }
  }

  Future<void> _handleCancelBooking() async {
    final confirmed = await BookingDialogs.showCancelConfirmation(
      context,
      bookingStatus: ref.read(bookingControllerProvider).bookingStatus,
    );

    if (confirmed) {
      ref.read(bookingControllerProvider.notifier).resetBooking();
      if (mounted) {
        ToastHelper.showSuccess(context, 'Booking canceled successfully');
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!ref.read(bookingControllerProvider.notifier).hasActiveBooking) {
      return true;
    }
    return await BookingDialogs.showExitConfirmation(context);
  }

  void _showMechanicDetails(Mechanic mechanic) {
    MechanicDetailsSheet.show(
      context,
      mechanic: mechanic,
      onSelect: () {
        final bookingController = ref.read(bookingControllerProvider.notifier);
        bookingController.selectMechanic(mechanic);
        bookingController.updateBookingStatus(BookingStatus.searching);
      },
    );
  }

  void _showShopDetails(MechanicShop shop) {
    final position = ref.read(bookingControllerProvider).currentPosition;
    if (position == null) return;

    ShopDetailsSheet.show(
      context,
      shop: shop,
      customerLocation: position,
      onSelect: () {
        ref.read(bookingControllerProvider.notifier).selectShop(shop);
        if (mounted) {
          ToastHelper.showSuccess(context, 'Selected ${shop.shopName}');
        }
      },
    );
  }

  void _recenterMap() async {
    _locationRequested = false;
    await _getCurrentLocation();
    final position = ref.read(bookingControllerProvider).currentPosition;
    if (position != null) {
      _mapController.move(position, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(bookingControllerProvider);

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
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(BookingState state) {
    if (state.isLoading || state.currentPosition == null) {
      return _buildLoadingView();
    }

    return Stack(
      children: [
        // Map
        BookingMapWidget(
          mapController: _mapController,
          currentPosition: state.currentPosition!,
          nearbyShops: state.nearbyShops,
          availableMechanics: state.availableMechanics,
          selectedShop: state.selectedShop,
          selectedMechanic: state.selectedMechanic,
          routePoints: state.routePoints,
          showShops: state.showShopsOnMap,
          onlineMechanics: state.onlineMechanics,
          showMechanics: state.showMechanicsOnMap,
          onShopTap: _showShopDetails,
          onMechanicTap: _showMechanicDetails,
        ),

        // Search bar
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: BookingSearchBar(
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            onMyLocationPressed: _recenterMap,
          ),
        ),

        // Shop filter button
        Positioned(
          top: 106,
          right: 20,
          child: ShopFilterButton(
            showShops: state.showShopsOnMap,
            shopCount: state.nearbyShops.length,
            onToggle: () {
              ref
                  .read(bookingControllerProvider.notifier)
                  .toggleShopsVisibility();
              ToastHelper.showInfo(
                context,
                state.showShopsOnMap
                    ? 'Shops hidden'
                    : 'Showing ${state.nearbyShops.length} shops',
              );
            },
          ),
        ),

        // Mechanics filter button (below shop button)
        Positioned(
          top: 166,
          right: 20,
          child: MechanicFilterButton(
            showMechanics: state.showMechanicsOnMap,
            mechanicCount: state.onlineMechanics.length,
            onToggle: () {
              ref
                  .read(bookingControllerProvider.notifier)
                  .toggleMechanicsVisibility();
              ToastHelper.showInfo(
                context,
                state.showMechanicsOnMap
                    ? 'Mechanics hidden'
                    : 'Showing ${state.onlineMechanics.length} online mechanics',
              );
            },
          ),
        ),

        // Chatbot launcher button (in line with shop + mechanic controls)
        Positioned(
          top: 226,
          right: 20,
          child: ChatbotLauncherButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AiChatScreen(
                    sessionId:
                        'booking_map_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}',
                    initialContext:
                        'Nearby shops: ${state.nearbyShops.length}, '
                        'Online mechanics: ${state.onlineMechanics.length}, '
                        'Show shops: ${state.showShopsOnMap}, '
                        'Show mechanics: ${state.showMechanicsOnMap}',
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom panels
        BookingBottomPanels(
          bookingStatus: state.bookingStatus,
          selectedService: state.selectedService,
          selectedSubService: state.selectedSubService,
          onServiceSelected: ref
              .read(bookingControllerProvider.notifier)
              .selectService,
          onSubServiceSelected: ref
              .read(bookingControllerProvider.notifier)
              .selectSubService,
          onBookingStatusChanged: ref
              .read(bookingControllerProvider.notifier)
              .updateBookingStatus,
          onResetBooking: _handleCancelBooking,
          mechanic: state.selectedMechanic,
          customerLocation: state.currentPosition!,
          onEmergencyPressed: ref
              .read(bookingControllerProvider.notifier)
              .handleEmergencyBooking,
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primaryColor.withAlpha(120),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading...',
            style: AppTheme.figtreeMedium.copyWith(
              fontSize: AppTheme.fontSize16,
              color: AppTheme.subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your location...',
            style: AppTheme.figtreeRegular.copyWith(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
