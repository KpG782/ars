import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/osrm_service.dart';
import '../../features/customer/booking/data/repositories/firestore_service_request_repository.dart';
import '../../features/customer/booking/data/repositories/firestore_shop_repository.dart';
import '../../features/customer/booking/data/repositories/osrm_mechanic_repository.dart';
import '../../features/customer/booking/domain/repositories/mechanic_repository.dart';
import '../../features/customer/booking/domain/repositories/service_request_repository.dart';
import '../../features/customer/booking/domain/repositories/shop_repository.dart';
import '../../features/mechanic/earnings/data/repositories/firebase_earnings_repository.dart';
import '../../features/mechanic/earnings/domain/repositories/earnings_repository.dart';

// ============================================================================
// CORE INFRASTRUCTURE PROVIDERS
// These providers expose Firebase services and core app services to the rest
// of the application. They are the foundation for all feature-level providers.
// ============================================================================

/// Provides the Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the Firebase Storage instance
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Provides the Firebase Messaging instance
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// Provides the SharedPreferences instance
/// This is an async provider since SharedPreferences requires initialization
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Provides the NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provides the OSRM routing service
final osrmServiceProvider = Provider<OSRMService>((ref) {
  return OSRMService();
});

/// Provides the currently authenticated user stream
/// Returns null if no user is signed in
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provides the current user's UID
/// Returns null if not authenticated
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.uid).value;
});

final mechanicRepositoryProvider = Provider<MechanicRepository>((ref) {
  final osrm = ref.watch(osrmServiceProvider);
  return FirestoreMechanicRepository(osrmService: osrm);
});

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((
  ref,
) {
  return FirestoreServiceRequestRepository();
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return FirestoreShopRepository();
});

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return FirebaseEarningsRepository();
});
