/// Mechanic Dashboard Controller - State Management
///
/// Manages mechanic dashboard state, service requests, and location tracking.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Riverpod 3: StateNotifier/StateNotifierProvider live in the legacy module.
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/services/osrm_service.dart';
import '../../../../customer/booking/data/repositories/firestore_service_request_repository.dart';
import '../../../../customer/booking/data/repositories/osrm_mechanic_repository.dart';
import '../../../../customer/booking/domain/models/service_request.dart'
    as booking_request;
import '../../../../customer/booking/domain/repositories/mechanic_repository.dart';
import '../../../../customer/booking/domain/repositories/service_request_repository.dart';
import '../../domain/models/mechanic_status.dart';
import '../../domain/models/service_request.dart';

class MechanicDashboardState {
  final bool isInitialLoading;
  final bool isLoadingLocation;
  final bool isLoadingRequests;
  final bool isLoadingRoute;
  final bool isMapReady;
  final bool isOnline;
  final LatLng currentPosition;
  final MechanicStatus mechanicStatus;
  final List<ServiceRequest> nearbyRequests;
  final ServiceRequest? acceptedRequest;
  final List<LatLng> routePoints;
  final String etaText;
  final String distanceText;

  const MechanicDashboardState({
    this.isInitialLoading = true,
    this.isLoadingLocation = false,
    this.isLoadingRequests = false,
    this.isLoadingRoute = false,
    this.isMapReady = false,
    this.isOnline = false,
    this.currentPosition = const LatLng(14.5995, 120.9842),
    this.mechanicStatus = MechanicStatus.offline,
    this.nearbyRequests = const [],
    this.acceptedRequest,
    this.routePoints = const [],
    this.etaText = '15 minutes',
    this.distanceText = '0 km',
  });

  MechanicDashboardState copyWith({
    bool? isInitialLoading,
    bool? isLoadingLocation,
    bool? isLoadingRequests,
    bool? isLoadingRoute,
    bool? isMapReady,
    bool? isOnline,
    LatLng? currentPosition,
    MechanicStatus? mechanicStatus,
    List<ServiceRequest>? nearbyRequests,
    ServiceRequest? acceptedRequest,
    List<LatLng>? routePoints,
    String? etaText,
    String? distanceText,
    bool clearRequest = false,
  }) {
    return MechanicDashboardState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingRequests: isLoadingRequests ?? this.isLoadingRequests,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      isMapReady: isMapReady ?? this.isMapReady,
      isOnline: isOnline ?? this.isOnline,
      currentPosition: currentPosition ?? this.currentPosition,
      mechanicStatus: mechanicStatus ?? this.mechanicStatus,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
      acceptedRequest: clearRequest
          ? null
          : (acceptedRequest ?? this.acceptedRequest),
      routePoints: routePoints ?? this.routePoints,
      etaText: etaText ?? this.etaText,
      distanceText: distanceText ?? this.distanceText,
    );
  }
}

class MechanicDashboardController
    extends StateNotifier<MechanicDashboardState> {
  final OSRMService osrmService;
  final ServiceRequestRepository serviceRequestRepository;
  final MechanicRepository mechanicRepository;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<booking_request.ServiceRequest>>?
  _pendingRequestsSubscription;
  bool _locationRequested = false;

  MechanicDashboardController({
    OSRMService? osrmService,
    required this.serviceRequestRepository,
    required this.mechanicRepository,
  }) : osrmService = osrmService ?? OSRMService(),
       super(const MechanicDashboardState());

  Future<void> initialize() async {
    state = state.copyWith(isInitialLoading: true);

    try {
      await Future.wait([
        getCurrentLocation(),
        loadNearbyRequests(),
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void setMapReady(bool ready) {
    state = state.copyWith(isMapReady: ready);
  }

  Future<void> getCurrentLocation() async {
    if (_locationRequested) {
      return;
    }
    _locationRequested = true;

    state = state.copyWith(isLoadingLocation: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
      );
    } finally {
      state = state.copyWith(isLoadingLocation: false);
      _locationRequested = false;
    }
  }

  Future<void> loadNearbyRequests() async {
    state = state.copyWith(isLoadingRequests: true);

    await _pendingRequestsSubscription?.cancel();
    _pendingRequestsSubscription = serviceRequestRepository
        .watchPendingRequestsNearLocation(
          lat: state.currentPosition.latitude,
          lng: state.currentPosition.longitude,
          radiusKm: 10.0,
        )
        .listen(
          (requests) async {
            final mapped = await Future.wait<ServiceRequest>(
              requests.map(_mapBookingRequest),
            );
            mapped.sort((a, b) {
              if (a.isEmergency && !b.isEmergency) {
                return -1;
              }
              if (!a.isEmergency && b.isEmergency) {
                return 1;
              }
              return b.requestTime.compareTo(a.requestTime);
            });

            state = state.copyWith(
              nearbyRequests: mapped,
              isLoadingRequests: false,
            );
          },
          onError: (_) {
            state = state.copyWith(isLoadingRequests: false);
          },
        );
  }

  bool canToggleOffline() {
    return state.mechanicStatus != MechanicStatus.working &&
        state.mechanicStatus != MechanicStatus.enRoute;
  }

  Future<void> toggleOnlineStatus() async {
    if (state.isOnline) {
      await goOffline();
      return;
    }
    await goOnline();
  }

  Future<void> goOnline() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('mechanics').doc(uid).set({
      'isOnline': true,
      'isVerified': true,
      'location': {
        'lat': state.currentPosition.latitude,
        'lng': state.currentPosition.longitude,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    state = state.copyWith(
      isOnline: true,
      mechanicStatus: MechanicStatus.available,
    );

    await loadNearbyRequests();
  }

  Future<void> goOffline() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('mechanics').doc(uid).update({
        'isOnline': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    state = state.copyWith(
      isOnline: false,
      mechanicStatus: MechanicStatus.offline,
      nearbyRequests: const [],
    );
  }

  void updateStatus(MechanicStatus status) {
    if (status == MechanicStatus.available) {
      state = state.copyWith(
        mechanicStatus: status,
        clearRequest: true,
        routePoints: const [],
        etaText: '15 minutes',
        distanceText: '0 km',
      );
      _positionSubscription?.cancel();
      _positionSubscription = null;
    } else {
      state = state.copyWith(mechanicStatus: status);
    }
  }

  Future<void> acceptRequest(ServiceRequest request) async {
    final mechanicId = FirebaseAuth.instance.currentUser?.uid;
    if (mechanicId != null) {
      await serviceRequestRepository.acceptServiceRequest(
        requestId: request.id,
        mechanicId: mechanicId,
      );
    }

    state = state.copyWith(
      acceptedRequest: request,
      mechanicStatus: MechanicStatus.enRoute,
      isLoadingRoute: true,
      routePoints: [state.currentPosition, request.location],
      etaText: 'Calculating...',
      distanceText: 'Calculating...',
    );

    _startLocationTracking();
    await updateRouteAndETA();

    state = state.copyWith(isLoadingRoute: false);
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (state.mechanicStatus != MechanicStatus.enRoute) {
            return;
          }

          final newPosition = LatLng(position.latitude, position.longitude);
          final distance = Geolocator.distanceBetween(
            state.currentPosition.latitude,
            state.currentPosition.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );

          if (distance > 15) {
            state = state.copyWith(currentPosition: newPosition);
            updateRouteAndETA();
          }
        });
  }

  Future<void> updateRouteAndETA() async {
    if (state.acceptedRequest == null) {
      return;
    }

    try {
      final routeResult = await osrmService.getRoute(
        origin: state.currentPosition,
        destination: state.acceptedRequest!.location,
      );

      if (routeResult != null) {
        final minutes = (routeResult.duration / 60).ceil();
        final distanceKm = routeResult.distance / 1000;

        state = state.copyWith(
          routePoints: routeResult.coordinates,
          etaText: minutes <= 1 ? '< 1 minute' : '$minutes minutes',
          distanceText: distanceKm < 1
              ? '${routeResult.distance.toStringAsFixed(0)} m'
              : '${distanceKm.toStringAsFixed(1)} km',
        );
      }
    } catch (_) {
      state = state.copyWith(etaText: '~15 minutes', distanceText: '~5 km');
    }
  }

  Future<ServiceRequest> _mapBookingRequest(
    booking_request.ServiceRequest request,
  ) async {
    String customerName = 'Customer';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(request.customerId)
          .get();
      final data = userDoc.data();
      if (data != null) {
        customerName = (data['fullName'] as String?)?.trim().isNotEmpty == true
            ? data['fullName'] as String
            : (data['email'] as String?)?.split('@').first ?? 'Customer';
      }
    } catch (_) {}

    return ServiceRequest(
      id: request.id,
      customerName: customerName,
      location: request.customerLocation,
      serviceType: request.serviceType,
      description: request.description ?? 'No description provided',
      estimatedPrice: request.estimatedPrice ?? 0,
      requestTime: request.createdAt,
      isEmergency: request.isEmergency,
      status: RequestStatus.pending,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _pendingRequestsSubscription?.cancel();
    super.dispose();
  }
}

final mechanicDashboardControllerProvider =
    StateNotifierProvider.autoDispose<
      MechanicDashboardController,
      MechanicDashboardState
    >((ref) {
      return MechanicDashboardController(
        osrmService: ref.watch(osrmServiceProvider),
        serviceRequestRepository: FirestoreServiceRequestRepository(),
        mechanicRepository: FirestoreMechanicRepository(
          osrmService: ref.watch(osrmServiceProvider),
        ),
      );
    });
