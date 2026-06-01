# ARS Application - Memory

## Project Summary
- Flutter app for auto repair service booking (Philippines market)
- Customer + Mechanic dual-user app
- Firebase backend (Auth, Firestore, Storage, FCM)
- OSRM routing (Philippines server)
- Feature-first Clean Architecture
- State: ChangeNotifier (core booking/dashboard) + Riverpod infrastructure ready

## Key File Paths
- Entry: lib/main.dart
- Core providers: lib/core/providers/core_providers.dart
- Booking controller: lib/features/customer/booking/presentation/controllers/booking_controller.dart
- Mechanic dashboard controller: lib/features/mechanic/dashboard/presentation/controllers/mechanic_dashboard_controller.dart
- Auth service: lib/core/auth/auth_service.dart
- OSRM service: lib/core/services/osrm_service.dart
- Firebase options: lib/firebase_options.dart (contains exposed API keys)
- App theme: lib/core/theme/app_theme.dart
- Mechanic user model: lib/features/mechanic/auth/domain/models/mechanic_user.dart

## Critical Issues (as of March 2026)
1. Booking + Mechanic dashboard use MOCK DATA - not connected to Firestore
2. Riverpod migration incomplete (Phase 1 done, Phases 2-5 pending)
3. Zero tests
4. Firebase API keys exposed in firebase_options.dart
5. No use case layer (domain layer skips use cases)
6. No GoRouter - pure Navigator (no deep links)
7. Chat has hardcoded mechanic IDs (TODO)

## User Preferences
- User is actively improving the system
- Wants to add a real backend (replace mocks with Firebase)
- Prefers clear, actionable improvement lists

## Architecture
- Feature-first: lib/features/customer/ + lib/features/mechanic/
- Each feature: data/ domain/ presentation/
- Clean architecture but missing Use Cases layer
- State management: ChangeNotifier in controllers, Riverpod ProviderScope in main
