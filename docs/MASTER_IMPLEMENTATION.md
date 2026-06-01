# ARS Application — Master Implementation Task
# Run this with: claude (paste entire contents as your first message in a new session)

---

## PROJECT CONTEXT

This is a Flutter 3.9+ / Dart 3.9+ auto repair service app (Philippines market).
- Firebase project ID: `ars-application-be8f1`
- Two user types: Customer + Mechanic
- Platform: Windows 11, bash shell, Android target device
- Current branch: `feat/clean`
- Working directory: `c:\Users\kpg78\Downloads\ARS\ARSAPPLICATION`

The app currently works with **mock data** for its core features (mechanic search, booking).
This task implements everything needed to make it production-ready with real Firebase backend.

**Do every step in order. Do not skip steps. Do not ask for confirmation between steps.
When done with all steps, run `flutter build apk --release` then `flutter install`.**

---

## STEP 1 — Add Required Dependencies to pubspec.yaml

Open `pubspec.yaml`. Add these packages under `dependencies:` (after existing entries):

```yaml
  # Routing
  go_router: ^14.3.0

  # Logging
  logger: ^2.4.0

  # Geo queries
  geoflutterfire_plus: ^0.0.30

  # Firebase Crashlytics
  firebase_crashlytics: ^4.1.0
```

Then run: `flutter pub get`

---

## STEP 2 — Create Firestore Security Rules

Create file `firestore.rules` at the project root:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: only the owner can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Mechanics: any authenticated user can read (for search), only owner can write
    match /mechanics/{mechanicId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && request.auth.uid == mechanicId;
      allow delete: if false;
    }

    // Service requests: customer creates, both parties can read/update
    match /service_requests/{requestId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && (
        request.auth.uid == resource.data.customerId ||
        request.auth.uid == resource.data.mechanicId
      );
      allow update: if request.auth != null && (
        request.auth.uid == resource.data.customerId ||
        request.auth.uid == resource.data.mechanicId
      );
      allow delete: if false;
    }

    // Chat rooms: only participants
    match /chat_rooms/{roomId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participants;

      match /messages/{messageId} {
        allow create: if request.auth != null &&
          request.auth.uid in get(/databases/$(database)/documents/chat_rooms/$(roomId)).data.participants;
        allow read: if request.auth != null &&
          request.auth.uid in get(/databases/$(database)/documents/chat_rooms/$(roomId)).data.participants;
        allow update, delete: if false;
      }
    }

    // Notifications: only the recipient
    match /notifications/{notifId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.recipientId;
    }
  }
}
```

---

## STEP 3 — Create Firestore Indexes

Create file `firestore.indexes.json` at the project root:

```json
{
  "indexes": [
    {
      "collectionGroup": "mechanics",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isOnline", "order": "ASCENDING" },
        { "fieldPath": "isVerified", "order": "ASCENDING" },
        { "fieldPath": "geohash", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "service_requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "customerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "service_requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "mechanicId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "service_requests",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## STEP 4 — Create App Logger Utility

Create file `lib/core/utils/app_logger.dart`:

```dart
import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug,
);
```

---

## STEP 5 — Create ServiceRequest Domain Model

Create file `lib/features/customer/booking/domain/models/service_request.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum ServiceRequestStatus {
  pending,
  accepted,
  enRoute,
  inProgress,
  completed,
  cancelled,
  expired;

  String get value => name;

  static ServiceRequestStatus fromString(String value) {
    return ServiceRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServiceRequestStatus.pending,
    );
  }

  bool get isActive => this == accepted || this == enRoute || this == inProgress;
  bool get isTerminal => this == completed || this == cancelled || this == expired;
}

class ServiceRequest {
  final String id;
  final String customerId;
  final String? mechanicId;
  final ServiceRequestStatus status;
  final String serviceType;
  final String? subServiceType;
  final bool isEmergency;
  final LatLng customerLocation;
  final String? customerAddress;
  final String? description;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.mechanicId,
    required this.status,
    required this.serviceType,
    this.subServiceType,
    this.isEmergency = false,
    required this.customerLocation,
    this.customerAddress,
    this.description,
    this.estimatedPrice,
    this.finalPrice,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locMap = data['customerLocation'] as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      customerId: data['customerId'] as String,
      mechanicId: data['mechanicId'] as String?,
      status: ServiceRequestStatus.fromString(data['status'] as String),
      serviceType: data['serviceType'] as String,
      subServiceType: data['subServiceType'] as String?,
      isEmergency: data['isEmergency'] as bool? ?? false,
      customerLocation: LatLng(
        (locMap['lat'] as num).toDouble(),
        (locMap['lng'] as num).toDouble(),
      ),
      customerAddress: data['customerAddress'] as String?,
      description: data['description'] as String?,
      estimatedPrice: (data['estimatedPrice'] as num?)?.toDouble(),
      finalPrice: (data['finalPrice'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'mechanicId': mechanicId,
      'status': status.value,
      'serviceType': serviceType,
      'subServiceType': subServiceType,
      'isEmergency': isEmergency,
      'customerLocation': {
        'lat': customerLocation.latitude,
        'lng': customerLocation.longitude,
      },
      'customerAddress': customerAddress,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? mechanicId,
    ServiceRequestStatus? status,
    String? serviceType,
    String? subServiceType,
    bool? isEmergency,
    LatLng? customerLocation,
    String? customerAddress,
    String? description,
    double? estimatedPrice,
    double? finalPrice,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      mechanicId: mechanicId ?? this.mechanicId,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      subServiceType: subServiceType ?? this.subServiceType,
      isEmergency: isEmergency ?? this.isEmergency,
      customerLocation: customerLocation ?? this.customerLocation,
      customerAddress: customerAddress ?? this.customerAddress,
      description: description ?? this.description,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
```

---

## STEP 6 — Create ServiceRequest Repository Interface

Create file `lib/features/customer/booking/domain/repositories/service_request_repository.dart`:

```dart
import '../models/service_request.dart';

abstract class ServiceRequestRepository {
  Future<ServiceRequest> createServiceRequest(ServiceRequest request);
  Future<ServiceRequest?> getServiceRequest(String requestId);
  Stream<ServiceRequest> watchServiceRequest(String requestId);
  Future<List<ServiceRequest>> getCustomerHistory(String customerId);
  Future<void> cancelServiceRequest(String requestId);
  Stream<List<ServiceRequest>> watchPendingRequestsNearLocation({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  });
  Future<void> acceptServiceRequest({
    required String requestId,
    required String mechanicId,
  });
  Future<void> updateStatus({
    required String requestId,
    required ServiceRequestStatus status,
  });
}
```

---

## STEP 7 — Update Mechanic Domain Model for Firestore

Open `lib/features/customer/booking/domain/models/mechanic.dart`.
Add a `fromFirestore` factory and `toFirestore` method at the bottom of the class (before the closing brace):

```dart
  factory Mechanic.fromFirestore(Map<String, dynamic> data, String docId) {
    final locMap = data['location'] as Map<String, dynamic>? ?? {};
    return Mechanic(
      id: docId,
      name: data['fullName'] as String? ?? data['name'] as String? ?? 'Unknown',
      location: LatLng(
        (locMap['lat'] as num?)?.toDouble() ?? 14.5995,
        (locMap['lng'] as num?)?.toDouble() ?? 120.9842,
      ),
      etaMinutes: data['etaMinutes'] as int? ?? 0,
      phoneNumber: data['phoneNumber'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      photoUrl: data['profilePhotoUrl'] as String?,
      isAvailable: data['isOnline'] as bool? ?? false,
      specializations: List<String>.from(data['specializations'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'isOnline': isAvailable,
      'rating': rating,
      'specializations': specializations,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': photoUrl,
    };
  }
```

---

## STEP 8 — Replace Mock MechanicRepository with Real Firestore

Completely replace the contents of
`lib/features/customer/booking/data/repositories/osrm_mechanic_repository.dart`
with the following:

```dart
/// Data Layer: Firestore + OSRM Implementation of MechanicRepository
///
/// Queries real online mechanics from Firestore, calculates ETA via OSRM.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../domain/models/mechanic.dart';
import '../../domain/repositories/mechanic_repository.dart';
import '../../../../../core/services/osrm_service.dart';
import '../../../../../core/utils/app_logger.dart';

class FirestoreMechanicRepository implements MechanicRepository {
  final FirebaseFirestore _firestore;
  final OSRMService _osrmService;

  FirestoreMechanicRepository({
    FirebaseFirestore? firestore,
    OSRMService? osrmService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _osrmService = osrmService ?? OSRMService();

  @override
  Future<List<Mechanic>> searchNearbyMechanics({
    required LatLng location,
    double radiusKm = 10.0,
    String? serviceType,
  }) async {
    try {
      // Query all verified online mechanics
      Query query = _firestore
          .collection('mechanics')
          .where('isOnline', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      if (serviceType != null && serviceType.isNotEmpty) {
        query = query.where('specializations', arrayContains: serviceType);
      }

      final snapshot = await query.limit(50).get();

      final mechanics = snapshot.docs
          .map((doc) => Mechanic.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      // Filter by radius using Haversine distance
      final nearby = mechanics.where((m) {
        final distKm = _haversineKm(
          location.latitude,
          location.longitude,
          m.location.latitude,
          m.location.longitude,
        );
        return distKm <= radiusKm;
      }).toList();

      if (nearby.isEmpty) {
        appLogger.w('No online mechanics found within ${radiusKm}km');
        return [];
      }

      // Calculate real ETA via OSRM for nearby mechanics
      final withETA = await _enrichWithETA(nearby, location);
      withETA.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
      return withETA;
    } catch (e, st) {
      appLogger.e('searchNearbyMechanics failed', error: e, stackTrace: st);
      throw MechanicException(
        'Failed to search mechanics: $e',
        MechanicErrorCode.searchFailed,
      );
    }
  }

  @override
  Future<Mechanic?> getMechanicById(String mechanicId) async {
    try {
      final doc =
          await _firestore.collection('mechanics').doc(mechanicId).get();
      if (!doc.exists) return null;
      return Mechanic.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e, st) {
      appLogger.e('getMechanicById failed', error: e, stackTrace: st);
      throw MechanicException(
        'Mechanic not found: $e',
        MechanicErrorCode.notFound,
      );
    }
  }

  @override
  Future<int> calculateETA({
    required LatLng mechanicLocation,
    required LatLng customerLocation,
  }) async {
    try {
      final result = await _osrmService.calculateETA(
        origin: mechanicLocation,
        destination: customerLocation,
      );
      return result.durationInMinutes;
    } catch (e) {
      // Fallback: rough estimate at 30km/h average urban speed
      final distKm = _haversineKm(
        mechanicLocation.latitude,
        mechanicLocation.longitude,
        customerLocation.latitude,
        customerLocation.longitude,
      );
      return (distKm / 30.0 * 60).ceil().clamp(2, 120);
    }
  }

  @override
  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final result =
          await _osrmService.getRoute(origin: origin, destination: destination);
      return result?.coordinates ?? [];
    } catch (e, st) {
      appLogger.e('getRoute failed', error: e, stackTrace: st);
      throw MechanicException(
        'Failed to get route: $e',
        MechanicErrorCode.routeCalculationFailed,
      );
    }
  }

  @override
  Future<void> updateMechanicAvailability({
    required String mechanicId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore.collection('mechanics').doc(mechanicId).update({
        'isOnline': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      appLogger.e('updateMechanicAvailability failed', error: e, stackTrace: st);
      throw MechanicException(
        'Failed to update availability: $e',
        MechanicErrorCode.unknown,
      );
    }
  }

  // --- Private helpers ---

  Future<List<Mechanic>> _enrichWithETA(
      List<Mechanic> mechanics, LatLng destination) async {
    final results = <Mechanic>[];
    for (final m in mechanics) {
      try {
        final eta = await _osrmService.calculateETA(
          origin: m.location,
          destination: destination,
        );
        results.add(m.copyWith(etaMinutes: eta.durationInMinutes));
      } catch (_) {
        results.add(m);
      }
    }
    return results;
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
```

---

## STEP 9 — Create Firestore ServiceRequest Repository

Create file
`lib/features/customer/booking/data/repositories/firestore_service_request_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../domain/models/service_request.dart';
import '../../domain/repositories/service_request_repository.dart';
import '../../../../../core/utils/app_logger.dart';

class FirestoreServiceRequestRepository implements ServiceRequestRepository {
  final FirebaseFirestore _firestore;

  FirestoreServiceRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ServiceRequest> createServiceRequest(ServiceRequest request) async {
    try {
      final docRef = _firestore.collection('service_requests').doc();
      final newRequest = request.copyWith(id: docRef.id);
      await docRef.set(newRequest.toFirestore());
      appLogger.i('Service request created: ${docRef.id}');
      return newRequest;
    } catch (e, st) {
      appLogger.e('createServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<ServiceRequest?> getServiceRequest(String requestId) async {
    try {
      final doc = await _firestore
          .collection('service_requests')
          .doc(requestId)
          .get();
      if (!doc.exists) return null;
      return ServiceRequest.fromFirestore(doc);
    } catch (e, st) {
      appLogger.e('getServiceRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<ServiceRequest> watchServiceRequest(String requestId) {
    return _firestore
        .collection('service_requests')
        .doc(requestId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => ServiceRequest.fromFirestore(doc));
  }

  @override
  Future<List<ServiceRequest>> getCustomerHistory(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('service_requests')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => ServiceRequest.fromFirestore(doc))
          .toList();
    } catch (e, st) {
      appLogger.e('getCustomerHistory failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> cancelServiceRequest(String requestId) async {
    await _firestore.collection('service_requests').doc(requestId).update({
      'status': ServiceRequestStatus.cancelled.value,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ServiceRequest>> watchPendingRequestsNearLocation({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  }) {
    return _firestore
        .collection('service_requests')
        .where('status', isEqualTo: ServiceRequestStatus.pending.value)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => ServiceRequest.fromFirestore(doc))
          .toList();
      return all.where((req) {
        final d = _haversineKm(
          lat,
          lng,
          req.customerLocation.latitude,
          req.customerLocation.longitude,
        );
        return d <= radiusKm;
      }).toList();
    });
  }

  @override
  Future<void> acceptServiceRequest({
    required String requestId,
    required String mechanicId,
  }) async {
    await _firestore.collection('service_requests').doc(requestId).update({
      'mechanicId': mechanicId,
      'status': ServiceRequestStatus.accepted.value,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required ServiceRequestStatus status,
  }) async {
    final Map<String, dynamic> updates = {
      'status': status.value,
    };
    if (status == ServiceRequestStatus.completed) {
      updates['completedAt'] = FieldValue.serverTimestamp();
    } else if (status == ServiceRequestStatus.cancelled) {
      updates['cancelledAt'] = FieldValue.serverTimestamp();
    }
    await _firestore
        .collection('service_requests')
        .doc(requestId)
        .update(updates);
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
```

---

## STEP 10 — Create Use Cases

Create file `lib/features/customer/booking/domain/usecases/search_nearby_mechanics_usecase.dart`:

```dart
import 'package:latlong2/latlong.dart';
import '../models/mechanic.dart';
import '../repositories/mechanic_repository.dart';

class SearchNearbyMechanicsUseCase {
  final MechanicRepository _repository;
  SearchNearbyMechanicsUseCase(this._repository);

  Future<List<Mechanic>> call({
    required LatLng location,
    double radiusKm = 10.0,
    String? serviceType,
  }) {
    return _repository.searchNearbyMechanics(
      location: location,
      radiusKm: radiusKm,
      serviceType: serviceType,
    );
  }
}
```

Create file `lib/features/customer/booking/domain/usecases/create_booking_usecase.dart`:

```dart
import 'package:latlong2/latlong.dart';
import '../models/service_request.dart';
import '../repositories/service_request_repository.dart';

class CreateBookingUseCase {
  final ServiceRequestRepository _repository;
  CreateBookingUseCase(this._repository);

  Future<ServiceRequest> call({
    required String customerId,
    required String serviceType,
    String? subServiceType,
    required LatLng customerLocation,
    String? customerAddress,
    bool isEmergency = false,
    String? description,
  }) {
    final request = ServiceRequest(
      id: '',
      customerId: customerId,
      status: ServiceRequestStatus.pending,
      serviceType: serviceType,
      subServiceType: subServiceType,
      isEmergency: isEmergency,
      customerLocation: customerLocation,
      customerAddress: customerAddress,
      description: description,
      createdAt: DateTime.now(),
    );
    return _repository.createServiceRequest(request);
  }
}
```

Create file `lib/features/mechanic/dashboard/domain/usecases/accept_service_request_usecase.dart`:

```dart
import '../../../../customer/booking/domain/repositories/service_request_repository.dart';

class AcceptServiceRequestUseCase {
  final ServiceRequestRepository _repository;
  AcceptServiceRequestUseCase(this._repository);

  Future<void> call({
    required String requestId,
    required String mechanicId,
  }) {
    return _repository.acceptServiceRequest(
      requestId: requestId,
      mechanicId: mechanicId,
    );
  }
}
```

Create file `lib/features/mechanic/dashboard/domain/usecases/update_mechanic_status_usecase.dart`:

```dart
import '../../../../customer/booking/domain/repositories/mechanic_repository.dart';

class UpdateMechanicStatusUseCase {
  final MechanicRepository _repository;
  UpdateMechanicStatusUseCase(this._repository);

  Future<void> call({
    required String mechanicId,
    required bool isOnline,
  }) {
    return _repository.updateMechanicAvailability(
      mechanicId: mechanicId,
      isAvailable: isOnline,
    );
  }
}
```

---

## STEP 11 — Update Core Providers for Riverpod

Open `lib/core/providers/core_providers.dart`.
Add the following providers at the bottom of the file (after existing providers):

```dart
// Repository providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/customer/booking/data/repositories/osrm_mechanic_repository.dart';
import '../../features/customer/booking/data/repositories/firestore_service_request_repository.dart';
import '../../features/customer/booking/domain/repositories/mechanic_repository.dart';
import '../../features/customer/booking/domain/repositories/service_request_repository.dart';

final mechanicRepositoryProvider = Provider<MechanicRepository>((ref) {
  final osrm = ref.watch(osrmServiceProvider);
  return FirestoreMechanicRepository(osrmService: osrm);
});

final serviceRequestRepositoryProvider =
    Provider<ServiceRequestRepository>((ref) {
  return FirestoreServiceRequestRepository();
});
```

Note: Make sure all necessary imports are at the top of core_providers.dart.
If imports for FirestoreMechanicRepository and FirestoreServiceRequestRepository conflict,
add them inline as shown above, merging with existing imports at the file top.

---

## STEP 12 — Migrate BookingController to Riverpod StateNotifier

Open `lib/features/customer/booking/presentation/controllers/booking_controller.dart`.

Replace the class declaration line:
```dart
class BookingController extends ChangeNotifier {
```
with:
```dart
class BookingController extends StateNotifier<BookingState> {
```

Replace the state field and getter:
```dart
  BookingState _state = const BookingState();
  BookingState get state => _state;
```
with:
```dart
  // state is provided by StateNotifier
```

Replace every `_state = _state.copyWith(` with `state = state.copyWith(`
Replace every `_state.` reference with `state.`
Remove all `notifyListeners();` calls — StateNotifier notifies automatically when `state =` is set.
Remove `import 'package:flutter/material.dart';` if ChangeNotifier was the only Flutter dependency.
Add `import 'package:flutter_riverpod/flutter_riverpod.dart';`

Change the constructor to:
```dart
  BookingController({
    required this.mechanicRepository,
    required this.shopRepository,
    OSRMService? osrmService,
  }) : osrmService = osrmService ?? OSRMService(),
       super(const BookingState());
```

At the bottom of the file, add the Riverpod provider:

```dart
final bookingControllerProvider =
    StateNotifierProvider.autoDispose<BookingController, BookingState>((ref) {
  final mechanicRepo = ref.watch(mechanicRepositoryProvider);
  final serviceRequestRepo = ref.watch(serviceRequestRepositoryProvider);
  // ShopRepository: keep existing mock or create Firestore impl
  // For now re-use existing mock shop repository
  return BookingController(
    mechanicRepository: mechanicRepo,
    shopRepository: MockShopRepository(), // Replace when shop Firestore is ready
    osrmService: ref.watch(osrmServiceProvider),
  );
});
```

Add import for core_providers at top of booking_controller.dart:
```dart
import '../../../../../core/providers/core_providers.dart';
import '../../data/repositories/mock_shop_repository.dart';
```

---

## STEP 13 — Update booking_screen.dart to use Riverpod

Open `lib/features/customer/booking/presentation/screens/booking_screen.dart`.

Find the widget class declaration. Change it from `StatelessWidget` or `StatefulWidget` to `ConsumerWidget` (or `ConsumerStatefulWidget` if it was stateful).

Add import:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/booking_controller.dart';
```

Replace `ChangeNotifierProvider<BookingController>` usage with:
```dart
final bookingState = ref.watch(bookingControllerProvider);
final bookingController = ref.read(bookingControllerProvider.notifier);
```

Remove any `ChangeNotifierProvider(create: ...)` and `Consumer<BookingController>` widgets.
Replace all `controller.state` with `bookingState`.
Replace all `controller.someMethod()` with `bookingController.someMethod()`.

---

## STEP 14 — Migrate MechanicDashboardController to StateNotifier

Open `lib/features/mechanic/dashboard/presentation/controllers/mechanic_dashboard_controller.dart`.

Apply the same migration as Step 12:
1. Change `extends ChangeNotifier` → `extends StateNotifier<MechanicDashboardState>`
2. Remove `_state` field + getter, use `state` directly
3. Replace `_state = _state.copyWith(` → `state = state.copyWith(`
4. Replace `_state.` → `state.`
5. Remove all `notifyListeners();`
6. Change constructor to call `super(const MechanicDashboardState())`
7. Add Riverpod provider at bottom:

```dart
import '../../../../../core/providers/core_providers.dart';
import '../../../../customer/booking/data/repositories/osrm_mechanic_repository.dart';
import '../../../../customer/booking/data/repositories/firestore_service_request_repository.dart';

final mechanicDashboardControllerProvider = StateNotifierProvider.autoDispose<
    MechanicDashboardController, MechanicDashboardState>((ref) {
  return MechanicDashboardController(
    osrmService: ref.watch(osrmServiceProvider),
    serviceRequestRepository: FirestoreServiceRequestRepository(),
    mechanicRepository: FirestoreMechanicRepository(
      osrmService: ref.watch(osrmServiceProvider),
    ),
  );
});
```

Update the controller constructor to accept `serviceRequestRepository` and
`mechanicRepository` parameters. Update `loadNearbyRequests()` to stream from
`serviceRequestRepository.watchPendingRequestsNearLocation(...)` instead of
generating mock data.

---

## STEP 15 — Update mechanic_dashboard_screen.dart to use Riverpod

Open `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard_screen.dart`.

Apply same migration as Step 13:
1. Change to `ConsumerWidget` or `ConsumerStatefulWidget`
2. Replace `ChangeNotifierProvider` with `ref.watch(mechanicDashboardControllerProvider)`
3. Replace all `controller.state` with the watched state variable
4. Replace all `controller.method()` with `ref.read(...notifier).method()`

---

## STEP 16 — Add GoRouter

Create file `lib/core/routing/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/customer/auth/presentation/screens/user_login_screen.dart';
import '../../features/customer/auth/presentation/screens/user_signup_screen.dart';
import '../../features/customer/auth/presentation/screens/user_email_verification_screen.dart';
import '../../features/customer/booking/presentation/screens/booking_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_splash_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_auth_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_basic_info_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_verification_status_screen.dart';
import '../../features/mechanic/dashboard/presentation/screens/mechanic_dashboard_screen.dart';

// Route path constants
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const customerBooking = '/customer/booking';
  static const mechanicSplash = '/mechanic/splash';
  static const mechanicAuth = '/mechanic/auth';
  static const mechanicBasicInfo = '/mechanic/onboarding/basic-info';
  static const mechanicProfessional = '/mechanic/onboarding/professional';
  static const mechanicVerification = '/mechanic/verification';
  static const mechanicDashboard = '/mechanic/dashboard';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.onboarding;

      if (!isLoggedIn && !isAuthRoute &&
          state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const UserSignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const UserEmailVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerBooking,
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicSplash,
        builder: (context, state) => const MechanicSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicAuth,
        builder: (context, state) => const MechanicAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicBasicInfo,
        builder: (context, state) => const MechanicBasicInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicProfessional,
        builder: (context, state) => const MechanicProfessionalDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicVerification,
        builder: (context, state) => const MechanicVerificationStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicDashboard,
        builder: (context, state) => const MechanicDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
```

---

## STEP 17 — Update main.dart to use GoRouter

Open `lib/main.dart`.

Replace the `MaterialApp(...)` widget with `MaterialApp.router(...)` and wire GoRouter:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await NotificationService().initialize();
  runApp(const ProviderScope(child: ArsApp()));
}

class ArsApp extends ConsumerWidget {
  const ArsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ARS',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## STEP 18 — Update All Navigator.push Calls to GoRouter

Search the entire codebase for `Navigator.push` and `Navigator.pushReplacement` calls.
Replace each one with the appropriate GoRouter equivalent:

- `Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen()))` →
  `context.go(AppRoutes.customerBooking)`

- `Navigator.push(context, MaterialPageRoute(builder: (_) => UserLoginScreen()))` →
  `context.go(AppRoutes.login)`

- `Navigator.push(context, MaterialPageRoute(builder: (_) => MechanicDashboardScreen()))` →
  `context.go(AppRoutes.mechanicDashboard)`

- `Navigator.pushReplacement(...)` → `context.go(...)` (go replaces, push adds to stack)

- `Navigator.push(...)` where user can go back → `context.push(...)`

Add import to any file using GoRouter navigation:
```dart
import 'package:go_router/go_router.dart';
import '../../../../../core/routing/app_router.dart';
```

Also update SplashScreen navigation logic to use GoRouter:
Replace manual navigation in splash_screen.dart with `context.go(AppRoutes.customerBooking)`
or `context.go(AppRoutes.mechanicDashboard)` depending on user type.

---

## STEP 19 — Replace print() with appLogger

Search the entire codebase for `print(` calls.
Replace each one with the appropriate logger call:
- Debugging info → `appLogger.d('message')`
- Normal info → `appLogger.i('message')`
- Warnings → `appLogger.w('message')`
- Errors → `appLogger.e('message', error: e, stackTrace: st)`

Add import to each file that uses appLogger:
```dart
import '../../../../../core/utils/app_logger.dart';
// (adjust relative path depth as needed per file location)
```

---

## STEP 20 — Write Mechanic Location to Firestore on Status Change

Open the mechanic dashboard controller.
In the `goOnline()` method (or wherever mechanic goes online), add location write to Firestore:

```dart
Future<void> goOnline() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  // Write current location + online status to Firestore
  if (state.currentPosition != null) {
    await FirebaseFirestore.instance.collection('mechanics').doc(uid).set({
      'isOnline': true,
      'isVerified': true, // will be set by admin/cloud function in real flow
      'location': {
        'lat': state.currentPosition!.latitude,
        'lng': state.currentPosition!.longitude,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  state = state.copyWith(isOnline: true);
}

Future<void> goOffline() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    await FirebaseFirestore.instance.collection('mechanics').doc(uid).update({
      'isOnline': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  state = state.copyWith(isOnline: false);
}
```

Add imports as needed: `package:firebase_auth/firebase_auth.dart`, `package:cloud_firestore/cloud_firestore.dart`.

---

## STEP 21 — Wire CreateBookingUseCase into BookingController

Open `lib/features/customer/booking/presentation/controllers/booking_controller.dart`.

In the `searchMechanics()` method, after finding mechanics and before setting confirmed state,
create a real service request in Firestore:

```dart
// After sorting mechanicsWithETA, create Firestore booking document
final uid = FirebaseAuth.instance.currentUser?.uid;
if (uid != null && state.selectedService != null) {
  try {
    final createBooking = CreateBookingUseCase(
        ref.read(serviceRequestRepositoryProvider));
    final createdRequest = await createBooking(
      customerId: uid,
      serviceType: state.selectedService!,
      subServiceType: state.selectedSubService,
      customerLocation: userLoc,
      isEmergency: state.bookingStatus == BookingStatus.emergency,
    );
    appLogger.i('Booking created: ${createdRequest.id}');
  } catch (e) {
    appLogger.e('Failed to create booking doc', error: e);
  }
}
```

Add the necessary imports at the top of booking_controller.dart:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../../../../core/providers/core_providers.dart';
```

Note: To use `ref` inside StateNotifier, inject `Ref` via constructor or use `ref.read` in the provider factory.
The cleanest approach: pass `serviceRequestRepository` as a constructor parameter
and inject it via the Riverpod provider in Step 12.

---

## STEP 22 — Delete Backup/Dead Files

Delete these files:
- `lib/features/mechanic/auth/presentation/screens/mechanic_splash_screen_backup.dart`

Also delete `booking_bottom_panels.dart` if it is no longer imported anywhere
(the refactored version `booking_bottom_panels_refactored.dart` should be used instead).
Verify by running: `grep -r "booking_bottom_panels.dart" lib/` before deleting.

---

## STEP 23 — Split service_request_card.dart

Read `lib/features/mechanic/dashboard/presentation/widgets/service_request_card.dart` (928 lines).
Split it into these files in the same directory:

1. `service_request_card.dart` — main card widget only (assembles sub-widgets, ~150 lines)
2. `service_request_card_header.dart` — customer name, vehicle, service type section
3. `service_request_card_details.dart` — location, distance, description section
4. `service_request_card_actions.dart` — accept/decline button row
5. `service_request_status_badge.dart` — status chip/badge widget

Each file should have a single exported widget class.
The main `service_request_card.dart` imports and composes the others.

---

## STEP 24 — Add Firebase Crashlytics

In `pubspec.yaml`, `firebase_crashlytics: ^4.1.0` was added in Step 1.

In `lib/main.dart`, the Crashlytics setup was added in Step 17.

Also add to `android/app/build.gradle` (check if already present, add if not):
```groovy
apply plugin: 'com.google.firebase.crashlytics'
```

And in `android/build.gradle` dependencies (check if already present):
```groovy
classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
```

---

## STEP 25 — Fix API Key Exposure

Open `lib/firebase_options.dart`.

The web API key is exposed in source control. While moving it to env vars requires
build pipeline changes, immediately:

1. Do NOT commit firebase_options.dart with keys to public repos.
2. Add `lib/firebase_options.dart` to `.gitignore` if not already there.
3. Open `.gitignore` at project root and add:
   ```
   lib/firebase_options.dart
   ```

Note: For CI/CD, firebase_options.dart should be generated at build time from
secure environment variables using `flutterfire configure`. This is outside scope
of this implementation task but document it in a TODO comment at the top of
firebase_options.dart:
```dart
// TODO: This file should be generated via `flutterfire configure` in CI/CD.
// Do not commit this file with real credentials to public repositories.
```

---

## STEP 26 — Run Flutter Pub Get + Analyze

Run these commands in sequence:

```bash
flutter pub get
flutter analyze
```

Fix any analysis errors before proceeding.
Common errors to expect and fix:
- Import path mismatches after file renames
- Missing `ref` parameter in StateNotifier constructors
- `ConsumerWidget` requires `WidgetRef ref` parameter in `build()`
- `StateNotifier` does not have `notifyListeners()` — remove any remaining calls
- `GoRouter` requires `go_router` import in files that use `context.go()`

Run `flutter analyze` again after each fix until zero errors.

---

## STEP 27 — Build APK

Run:
```bash
flutter build apk --release
```

If build fails:
- Read the error output carefully
- Fix import errors, missing overrides, or type mismatches
- Re-run `flutter build apk --release`

---

## STEP 28 — Install to Connected Device

Ensure an Android device is connected (or emulator is running).

Run:
```bash
flutter devices
flutter install
```

If multiple devices: `flutter install -d <device-id>`

After install, launch the app and verify:
1. Splash screen loads
2. Login screen appears for unauthenticated users
3. After login, customer booking screen shows map
4. Mechanic search attempts real Firestore query (may return empty if no mechanics online — that is correct, NOT a bug)
5. Mechanic dashboard goes online and writes to Firestore

---

## IMPLEMENTATION NOTES

### Firestore Data Seeding (Manual — do after install)

After the app is installed, go to Firebase Console → Firestore.
Create a test mechanic document manually to verify the search works:

**Collection:** `mechanics`
**Document ID:** `test_mechanic_001`
```json
{
  "fullName": "Test Mechanic",
  "phoneNumber": "+63 917 000 0000",
  "email": "test@ars.com",
  "isOnline": true,
  "isVerified": true,
  "rating": 4.8,
  "specializations": ["Engine Repair", "Oil Change"],
  "location": {
    "lat": 14.5995,
    "lng": 120.9842
  },
  "profilePhotoUrl": null,
  "createdAt": "<server timestamp>"
}
```

Then test the customer booking search from the app.

### Cloud Functions (Next Phase — not in this task)

After this task is complete, the next step is adding Firebase Cloud Functions:
- `functions/src/index.ts` — TypeScript Cloud Functions
- Mechanic matching trigger on `service_requests` create
- FCM notification triggers on status changes
- Earnings calculation on booking completion
- Stale request cleanup (scheduled function)

These require: `firebase init functions` → TypeScript → `firebase deploy --only functions`

---

## DONE CRITERIA

This task is complete when:
- [ ] `flutter analyze` returns 0 errors
- [ ] `flutter build apk --release` succeeds
- [ ] `flutter install` succeeds
- [ ] App boots without crash
- [ ] No `print()` statements remain (use appLogger)
- [ ] No ChangeNotifier usage remains in booking or dashboard controllers
- [ ] No Navigator.push calls remain (all use GoRouter)
- [ ] No mock mechanic generation in any repository
- [ ] `service_request_card.dart` is under 200 lines
- [ ] `firestore.rules` exists at project root
- [ ] Mechanic going online writes to Firestore
- [ ] Booking creates a real Firestore document
