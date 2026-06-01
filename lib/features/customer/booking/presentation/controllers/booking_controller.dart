/// Booking Controller - State Management for Booking Feature
///
/// Manages booking state, mechanic search, and route calculations.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/services/osrm_service.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/models/mechanic.dart';
import '../../domain/models/mechanic_shop.dart';
import '../../domain/repositories/mechanic_repository.dart';
import '../../domain/repositories/service_request_repository.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../widgets/booking_enums.dart';

class BookingState {
  final bool isLoading;
  final LatLng? currentPosition;
  final BookingStatus bookingStatus;
  final String? selectedService;
  final String? selectedSubService;
  final List<Mechanic> availableMechanics;
  final Mechanic? selectedMechanic;
  final List<MechanicShop> nearbyShops;
  final MechanicShop? selectedShop;
  final bool showShopsOnMap;
  final List<Mechanic> onlineMechanics;
  final bool showMechanicsOnMap;
  final List<LatLng> routePoints;
  final String? errorMessage;

  const BookingState({
    this.isLoading = true,
    this.currentPosition,
    this.bookingStatus = BookingStatus.initial,
    this.selectedService,
    this.selectedSubService,
    this.availableMechanics = const [],
    this.selectedMechanic,
    this.nearbyShops = const [],
    this.selectedShop,
    this.showShopsOnMap = true,
    this.onlineMechanics = const [],
    this.showMechanicsOnMap = false,
    this.routePoints = const [],
    this.errorMessage,
  });

  BookingState copyWith({
    bool? isLoading,
    LatLng? currentPosition,
    BookingStatus? bookingStatus,
    String? selectedService,
    String? selectedSubService,
    List<Mechanic>? availableMechanics,
    Mechanic? selectedMechanic,
    List<MechanicShop>? nearbyShops,
    MechanicShop? selectedShop,
    bool? showShopsOnMap,
    List<Mechanic>? onlineMechanics,
    bool? showMechanicsOnMap,
    List<LatLng>? routePoints,
    String? errorMessage,
    bool clearMechanic = false,
    bool clearShop = false,
    bool clearService = false,
    bool clearSubService = false,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      selectedService: clearService
          ? null
          : (selectedService ?? this.selectedService),
      selectedSubService: clearSubService
          ? null
          : (selectedSubService ?? this.selectedSubService),
      availableMechanics: availableMechanics ?? this.availableMechanics,
      selectedMechanic: clearMechanic
          ? null
          : (selectedMechanic ?? this.selectedMechanic),
      nearbyShops: nearbyShops ?? this.nearbyShops,
      selectedShop: clearShop ? null : (selectedShop ?? this.selectedShop),
      showShopsOnMap: showShopsOnMap ?? this.showShopsOnMap,
      onlineMechanics: onlineMechanics ?? this.onlineMechanics,
      showMechanicsOnMap: showMechanicsOnMap ?? this.showMechanicsOnMap,
      routePoints: routePoints ?? this.routePoints,
      errorMessage: errorMessage,
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  final MechanicRepository mechanicRepository;
  final ServiceRequestRepository serviceRequestRepository;
  final ShopRepository shopRepository;
  final OSRMService osrmService;

  Timer? _routeUpdateTimer;
  StreamSubscription<QuerySnapshot>? _mechanicsSubscription;
  // Cached nearby shop docs — fetched once, shops rarely change
  final Map<String, Map<String, dynamic>> _nearbyShopDocs = {};

  static const LatLng defaultLocation = LatLng(14.5995, 120.9842);
  static const double _radiusKm = 10.0;

  BookingController({
    required this.mechanicRepository,
    required this.serviceRequestRepository,
    required this.shopRepository,
    OSRMService? osrmService,
  }) : osrmService = osrmService ?? OSRMService(),
       super(const BookingState());

  void initialize(LatLng? position) {
    state = state.copyWith(
      currentPosition: position ?? defaultLocation,
      isLoading: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void updatePosition(LatLng position) {
    state = state.copyWith(currentPosition: position);
  }

  /// Fetches nearby shops once, then starts a real-time listener on mechanics.
  /// When any mechanic's isOnline status changes the map updates automatically.
  Future<void> loadNearbyShops() async {
    if (state.currentPosition == null) return;
    final userLoc = state.currentPosition!;

    try {
      // 1. Fetch shops once — admin-managed, rarely change
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .get();
      _nearbyShopDocs.clear();
      for (final doc in shopSnapshot.docs) {
        final data = doc.data();
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        if (_distKm(userLoc.latitude, userLoc.longitude, lat, lng) <=
            _radiusKm) {
          _nearbyShopDocs[doc.id] = data;
        }
      }

      // 2. Real-time listener: mechanics where approved + isOnline
      _mechanicsSubscription?.cancel();
      _mechanicsSubscription = FirebaseFirestore.instance
          .collection('mechanics')
          .where('verification.status', isEqualTo: 'approved')
          .where('isOnline', isEqualTo: true)
          .snapshots()
          .listen(_onMechanicsUpdate);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to load nearby shops');
    }
  }

  void _onMechanicsUpdate(QuerySnapshot snapshot) {
    if (state.currentPosition == null) return;
    final userLoc = state.currentPosition!;

    final mechanicsPerShop = <String, int>{};
    final independentMechanics = <MechanicShop>[];
    final allOnlineMechanics = <Mechanic>[];

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final locMap = data['location'] as Map<String, dynamic>? ?? {};
      final lat = (locMap['lat'] as num?)?.toDouble();
      final lng = (locMap['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      if (_distKm(userLoc.latitude, userLoc.longitude, lat, lng) > _radiusKm) {
        continue;
      }

      final shopId = data['shopId'] as String?;
      if (shopId != null &&
          shopId.isNotEmpty &&
          _nearbyShopDocs.containsKey(shopId)) {
        mechanicsPerShop[shopId] = (mechanicsPerShop[shopId] ?? 0) + 1;
      } else if (shopId == null || shopId.isEmpty) {
        independentMechanics.add(MechanicShop.fromFirestore(data, doc.id));
      }

      // Track every in-range mechanic for the mechanics toggle layer
      final basicInfo = data['basicInfo'] as Map<String, dynamic>? ?? {};
      final name = (basicInfo['fullName'] as String?)?.trim().isNotEmpty == true
          ? basicInfo['fullName'] as String
          : (data['fullName'] as String? ?? 'Mechanic');
      final prof = data['professionalDetails'] as Map<String, dynamic>? ?? {};
      allOnlineMechanics.add(
        Mechanic(
          id: doc.id,
          name: name,
          location: LatLng(lat, lng),
          etaMinutes: 0,
          isAvailable: true,
          specializations: [
            if ((prof['specialization'] as String?)?.isNotEmpty == true)
              prof['specialization'] as String,
          ],
        ),
      );
    }

    // Rebuild shop list with live mechanic counts
    final shops = _nearbyShopDocs.entries.map((e) {
      return MechanicShop.fromShop(
        e.value,
        e.key,
        availableMechanics: mechanicsPerShop[e.key] ?? 0,
      );
    }).toList();

    state = state.copyWith(
      nearbyShops: [...shops, ...independentMechanics],
      onlineMechanics: allOnlineMechanics,
    );
  }

  double _distKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void selectService(String service) {
    state = state.copyWith(selectedService: service, clearSubService: true);
  }

  void selectSubService(String subService) {
    state = state.copyWith(selectedSubService: subService);
  }

  void updateBookingStatus(BookingStatus status) {
    state = state.copyWith(bookingStatus: status);

    if (status == BookingStatus.searching) {
      searchMechanics();
    }
  }

  void handleEmergencyBooking() {
    state = state.copyWith(
      bookingStatus: BookingStatus.emergency,
      selectedService: 'Emergency',
    );
  }

  void toggleShopsVisibility() {
    state = state.copyWith(showShopsOnMap: !state.showShopsOnMap);
  }

  void toggleMechanicsVisibility() {
    state = state.copyWith(showMechanicsOnMap: !state.showMechanicsOnMap);
  }

  void selectShop(MechanicShop shop) {
    state = state.copyWith(selectedShop: shop);
  }

  void selectMechanic(Mechanic mechanic) {
    state = state.copyWith(selectedMechanic: mechanic);
  }

  Future<void> searchMechanics() async {
    if (state.currentPosition == null) {
      return;
    }

    state = state.copyWith(availableMechanics: [], clearMechanic: true);

    await Future.delayed(const Duration(seconds: 2));

    final userLoc = state.currentPosition!;
    final mechanics = await mechanicRepository.searchNearbyMechanics(
      location: userLoc,
      radiusKm: 10.0,
      serviceType: state.selectedService,
    );

    final mechanicsWithEta = await _calculateMechanicsEta(mechanics, userLoc);
    mechanicsWithEta.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && state.selectedService != null) {
      try {
        final createBooking = CreateBookingUseCase(serviceRequestRepository);
        final createdRequest = await createBooking(
          customerId: uid,
          serviceType: state.selectedService!,
          subServiceType: state.selectedSubService,
          customerLocation: userLoc,
          isEmergency: state.bookingStatus == BookingStatus.emergency,
        );
        appLogger.i('Booking created: ${createdRequest.id}');
      } catch (e, st) {
        appLogger.e('Failed to create booking doc', error: e, stackTrace: st);
      }
    }

    if (mechanicsWithEta.isEmpty) {
      // No online mechanics right now — service request is in Firestore,
      // stay in searching state so the customer keeps waiting.
      state = state.copyWith(availableMechanics: []);
      return;
    }

    state = state.copyWith(
      availableMechanics: mechanicsWithEta,
      selectedMechanic: mechanicsWithEta.first,
      bookingStatus: BookingStatus.confirmed,
    );

    await fetchAndDisplayRoute();
    _startLiveRouteUpdates();
  }

  Future<List<Mechanic>> _calculateMechanicsEta(
    List<Mechanic> mechanics,
    LatLng destination,
  ) async {
    final result = <Mechanic>[];

    for (final mechanic in mechanics) {
      try {
        final eta = await osrmService.calculateETA(
          origin: mechanic.location,
          destination: destination,
        );
        result.add(mechanic.copyWith(etaMinutes: eta.durationInMinutes));
      } catch (_) {
        result.add(mechanic);
      }
    }

    return result;
  }

  Future<void> fetchAndDisplayRoute() async {
    if (state.selectedMechanic == null || state.currentPosition == null) {
      return;
    }

    try {
      final route = await osrmService.getRoute(
        origin: state.selectedMechanic!.location,
        destination: state.currentPosition!,
      );

      if (route != null) {
        state = state.copyWith(routePoints: route.coordinates);
      }
    } catch (_) {}
  }

  void _startLiveRouteUpdates() {
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.bookingStatus == BookingStatus.confirmed) {
        fetchAndDisplayRoute();
      } else {
        _routeUpdateTimer?.cancel();
      }
    });
  }

  void resetBooking() {
    _routeUpdateTimer?.cancel();
    state = BookingState(
      currentPosition: state.currentPosition,
      nearbyShops: state.nearbyShops,
      showShopsOnMap: state.showShopsOnMap,
      isLoading: false,
    );
  }

  bool get hasActiveBooking {
    return state.bookingStatus != BookingStatus.initial &&
        state.bookingStatus != BookingStatus.serviceSelection &&
        state.bookingStatus != BookingStatus.subServiceSelection;
  }

  @override
  void dispose() {
    _routeUpdateTimer?.cancel();
    _mechanicsSubscription?.cancel();
    super.dispose();
  }
}

final bookingControllerProvider =
    StateNotifierProvider.autoDispose<BookingController, BookingState>((ref) {
      final mechanicRepo = ref.watch(mechanicRepositoryProvider);
      final serviceRequestRepo = ref.watch(serviceRequestRepositoryProvider);
      return BookingController(
        mechanicRepository: mechanicRepo,
        serviceRequestRepository: serviceRequestRepo,
        shopRepository: ref.watch(shopRepositoryProvider),
        osrmService: ref.watch(osrmServiceProvider),
      );
    });
