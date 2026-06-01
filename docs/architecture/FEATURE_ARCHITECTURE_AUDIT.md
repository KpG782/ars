# ARS Feature Architecture Audit

**Date:** 2026-06-02  
**Branch:** `local/feat-clean-with-updates`  
**Scope:** `lib/core`, `lib/features`, `test/design_system`, `test/architecture`

This audit checks the current feature-first setup after the ARS design-system pass and analyzer cleanup. It is intentionally factual: the refactor sequence is in [`FEATURE_ARCHITECTURE_REFACTOR_BACKLOG.md`](./FEATURE_ARCHITECTURE_REFACTOR_BACKLOG.md).

## Current Verification Snapshot

| Check | Result |
|---|---|
| `flutter test` | Passes: 10 tests |
| `flutter analyze` | Passes: `No issues found!` |
| `dart analyze --format machine` | Passes: no `ERROR` diagnostics |
| `flutter test test/design_system/no_raw_design_values_test.dart` | Passes |
| `flutter test test/design_system/service_semantics_test.dart` | Passes |
| `flutter test test/architecture/feature_dependency_direction_test.dart` | Passes |

## Feature Inventory

| Feature | Folders Present | Main Entry Points | State / Providers | Repositories | Known Risks | Audit Status |
|---|---|---|---|---|---|---|
| `onboarding` | `presentation` | `SplashScreen`, `OnboardingScreen`, `LoadingScreen` | Stateful widgets only | None | `SplashScreen` reaches Firebase Auth and SharedPreferences directly. | Needs auth bootstrap extraction. |
| `customer/auth` | `data`, `domain`, `presentation` | `UserLoginScreen`, `UserSignUpScreen`, `UserEmailVerificationScreen` | Local screen state | `AuthRepository` -> `FirebaseAuthRepository` | Presentation imports concrete Firebase repository. | Boundary cleanup needed. |
| `customer/booking` | `data`, `domain`, `presentation` | Modular `booking_screen.dart`, legacy `booking.dart`, chat/payment/map widgets | `BookingController` + `bookingControllerProvider`; legacy screen has local state | `MechanicRepository`, `ServiceRequestRepository`, `ShopRepository` -> Firestore/OSRM implementations | Two `BookingScreen` implementations exist. Legacy screen and some flows still import concrete data repositories. Largest files are in this feature. | Highest-priority customer feature cleanup. |
| `customer/dashboard` | `data`, `domain`, `presentation` | `UserDashboard` | Local screen state | `ProfileRepository` -> `FirebaseProfileRepository` | Presentation imports concrete repository; screen is just over 500 lines. | Boundary cleanup needed. |
| `customer/payment` | `presentation` | `PaymentMethodsScreen` | Local screen state | None | Currently UI-only. Add domain/data only when payment methods persist. | Acceptable for now. |
| `customer/history` | `presentation` | `BookingHistoryScreen` | Local static/mock list | None | UI-only history. Needs repository before real history data. | Acceptable prototype boundary. |
| `customer/support` | `presentation` | `SupportScreen` | Local screen/dialog state | None | UI-only support flow. | Acceptable prototype boundary. |
| `customer/saved_places` | `presentation` | `SavedPlacesScreen` | Local static list | None | UI-only saved places. Needs domain/data before persistence. | Acceptable prototype boundary. |
| `customer/vehicles` | `presentation` | `MyVehiclesScreen` | Local static list and form state | None | 704-line screen with embedded add/edit form. | Split when persistence is added. |
| `customer/feedback` | `presentation` | `FeedbackScreen` | Local screen state | None | UI-only feedback. | Acceptable prototype boundary. |
| `mechanic/auth` | `data`, `domain`, `presentation` | `MechanicSplashScreen`, `MechanicAuthScreen`, `MechanicBasicInfoScreen`, `MechanicProfessionalDetailsScreen`, `MechanicVerificationStatusScreen`, `MechanicMobileNumberScreen` | Local screen state | `AuthRepository`, `MechanicDataRepository`, `FileStorageRepository` -> Firebase implementations | Many presentation screens use Firebase directly; mobile-number file contains multiple unrelated screens. | High-priority modularization. |
| `mechanic/dashboard` | `data`, `domain`, `presentation` | Legacy `MechanicDashboard`, modular `MechanicDashboardScreen`, `MechanicDashboardController`, panel/card widgets | `mechanicDashboardControllerProvider`; legacy dashboard has local state | `ServiceRequestRepository`, `MechanicRepository` -> Firebase implementations | Legacy and Riverpod dashboard paths coexist; controller imports customer booking data repositories; large dashboard files. | Highest-priority mechanic feature cleanup. |
| `mechanic/chat` | `data`, `domain`, `presentation` | `MechanicChatScreen`, chat widgets | Local screen state | `ChatRepository`, `ChatMediaRepository` -> Firebase implementations | Presentation imports concrete Firebase chat repositories; domain model imports Firestore timestamp types. | Boundary cleanup needed. |
| `mechanic/earnings` | `data`, `domain`, `presentation` | `EarningsScreen` | Local screen state | `EarningsRepository` -> `FirebaseEarningsRepository` | Presentation imports concrete repository and Firebase Auth. | Boundary cleanup needed. |
| `mechanic/services` | `data`, `domain`, `presentation` | `BookingRequestMapScreen`, `ServiceHistoryScreen`, payment confirmation | Local screen state | `BookingRepository`, `ServiceHistoryRepository` -> OpenRoute/Firebase implementations | Presentation imports concrete data repositories and Firebase Auth. | Boundary cleanup needed. |
| `core` | `auth`, `constants`, `models`, `providers`, `routing`, `services`, `theme`, `utils`, `widgets` | `routerProvider`, `core_providers`, theme tokens, shared services/widgets | Riverpod core providers | Provides Firebase, OSRM, notification, and customer booking repositories | `core_providers.dart` includes customer-booking providers; those should move closer to the booking feature. | Core is usable, but provider ownership needs tightening. |

## Dependency Direction Findings

The intended direction is `presentation -> domain -> data`, with `core` as shared infrastructure. After cleanup, the strict guard `test/architecture/feature_dependency_direction_test.dart` now proves that no `data` or `domain` file imports `presentation`.

Remaining boundary issues are presentation-to-data or presentation-to-platform coupling:

- `customer/auth`: `user_login_screen.dart`, `user_signup_screen.dart`, and `user_email_verification_screen.dart` import `data/repositories/firebase_auth_repository.dart` directly.
- `customer/booking`: legacy `booking.dart` imports `FirebaseAuthRepository` and `FirestoreShopRepository` directly. `booking_screen.dart` uses Riverpod providers and is the cleaner target.
- `customer/dashboard`: `user_dashboard.dart` imports `FirebaseProfileRepository` directly.
- `mechanic/services`: `booking_request.dart` imports `OpenRouteServiceBookingRepository`; `service_history_screen.dart` imports `FirebaseServiceHistoryRepository` and Firebase Auth.
- `mechanic/earnings`: `earnings_screen.dart` imports `FirebaseEarningsRepository` and Firebase Auth.
- `mechanic/chat`: customer and mechanic chat screens import `FirebaseChatRepository` / `FirebaseChatMediaRepository` directly.
- `mechanic/dashboard`: `mechanic_dashboard_controller.dart` imports customer booking concrete data repositories. This is the largest cross-feature data coupling.
- `mechanic/auth`: several screens talk to Firebase Auth, Firestore, or Storage directly instead of using the existing domain repositories.
- Domain purity is mixed: `customer/booking/domain/models/service_request.dart`, `mechanic/chat/domain/models/chat_message.dart`, and `mechanic/auth/domain/models/mechanic_user.dart` import Firestore timestamp types.

Fixed in this pass:

- `lib/features/mechanic/dashboard/data/models/service_request.dart` now imports `RequestStatus` from the domain model instead of the presentation compatibility shim.
- `test/architecture/feature_dependency_direction_test.dart` prevents that `data -> presentation` regression from returning.

## Design-System Usage Findings

The design-system guard passes:

```bash
flutter test test/design_system/no_raw_design_values_test.dart
```

The guard currently bans raw hex colors, raw semantic Material colors like `Colors.red`, and raw numeric `fontSize` values outside `lib/core/theme`.

Classified bypasses still visible in feature code:

| Bypass | Classification | Notes |
|---|---|---|
| `Colors.white` / `Colors.black` | Acceptable Flutter primitive for now | Commonly used for on-accent text/icons and shadows; should gradually move to `Theme.of(context).colorScheme` or ARS color tokens where semantic. |
| `EdgeInsets.*` | Should become spacing token over time | Broadly used for layout. Do not mass-rewrite blindly; replace when touching a screen. |
| `BorderRadius.*` | Should become radius token over time | Broadly used for cards/sheets/buttons. Replace with `AppRadii` when extracting widgets. |
| `Duration(...)` | Should become motion token over time | Animations should use `AppMotion` as screens are split. |
| Service icon/color maps | Should become feature semantic helper | Started in this pass with `ServiceSemanticTheme` and `service_semantics_test.dart`; mechanic request cards now use the helper. |
| Lucide/Material icons in buttons | Acceptable platform/icon primitive | Current direction is Lucide for app-specific UI and Material icons where framework-native widgets already use them. |

## Routing And Provider Findings

Routes in `lib/core/routing/app_router.dart`:

| Route | Screen |
|---|---|
| `/` | `SplashScreen` |
| `/user-type` | `UserTypeSelectionScreen` from `main.dart` |
| `/onboarding` | `OnboardingScreen` |
| `/login` | `UserLoginScreen` |
| `/signup` | `UserSignUpScreen` |
| `/verify-email` | `UserEmailVerificationScreen` |
| `/customer/booking` | modular `BookingScreen` from `booking_screen.dart` |
| `/mechanic/splash` | `MechanicSplashScreen` |
| `/mechanic/auth` | `MechanicAuthScreen` |
| `/mechanic/onboarding/basic-info` | `MechanicBasicInfoScreen(phoneNumber: '')` |
| `/mechanic/onboarding/professional` | `MechanicProfessionalDetailsScreen(...)` with empty constructor values |
| `/mechanic/verification` | `MechanicVerificationStatusScreen` |
| `/mechanic/dashboard` | legacy `MechanicDashboard` |

Provider ownership:

| Provider | Current Location | Classification | Finding |
|---|---|---|---|
| `firebaseAuthProvider`, `firestoreProvider`, `firebaseStorageProvider`, `firebaseMessagingProvider` | `core_providers.dart` | App-wide | Correct in core. |
| `sharedPreferencesProvider` | `core_providers.dart` | App-wide | Correct in core. |
| `notificationServiceProvider`, `osrmServiceProvider` | `core_providers.dart` | App-wide service | Correct in core. |
| `authStateProvider`, `currentUserIdProvider` | `core_providers.dart` | Auth-wide | Correct in core or `core/auth`. |
| `mechanicRepositoryProvider`, `serviceRequestRepositoryProvider`, `shopRepositoryProvider` | `core_providers.dart` | Customer booking-specific | Should move to `customer/booking/presentation/controllers` or a booking provider file. |
| `bookingControllerProvider` | booking controller | Feature-owned | Good. |
| `mechanicDashboardControllerProvider` | mechanic dashboard controller | Feature-owned | Good location, but dependencies are cross-feature concrete repos. |

Routing risks:

- Some mechanic auth screens still navigate with `MaterialPageRoute` to the legacy customer `booking.dart` screen, bypassing `GoRouter`.
- Mechanic onboarding routes construct screens with empty strings. They need route params or provider-backed draft state before deep links are safe.
- `/mechanic/dashboard` points to legacy `MechanicDashboard`; the Riverpod `MechanicDashboardScreen` is present but not routed.

## Data And Service Boundary Findings

Repository interfaces and implementations:

| Domain Interface | Concrete Implementation(s) |
|---|---|
| `customer/auth/AuthRepository` | `FirebaseAuthRepository` |
| `customer/booking/MechanicRepository` | `FirestoreMechanicRepository`, `OSRMMechanicRepository` |
| `customer/booking/ServiceRequestRepository` | `FirestoreServiceRequestRepository` |
| `customer/booking/ShopRepository` | `FirestoreShopRepository`, `MockShopRepository` |
| `customer/dashboard/ProfileRepository` | `FirebaseProfileRepository` |
| `mechanic/auth/AuthRepository` | `FirebaseAuthRepository` |
| `mechanic/auth/MechanicDataRepository` | `FirebaseMechanicDataRepository` |
| `mechanic/auth/FileStorageRepository` | `FirebaseStorageRepository` |
| `mechanic/chat/ChatRepository` | `FirebaseChatRepository` |
| `mechanic/chat/ChatMediaRepository` | `FirebaseChatMediaRepository` |
| `mechanic/dashboard/ServiceRequestRepository` | `FirebaseServiceRequestRepository` |
| `mechanic/dashboard/MechanicRepository` | `FirebaseMechanicRepository` |
| `mechanic/earnings/EarningsRepository` | `FirebaseEarningsRepository` |
| `mechanic/services/BookingRepository` | `OpenRouteServiceBookingRepository` |
| `mechanic/services/ServiceHistoryRepository` | `FirebaseServiceHistoryRepository` |

Boundary observations:

- Concrete repositories generally have matching interfaces. The issue is that screens often instantiate concrete repositories instead of depending on providers/interfaces.
- Firebase/Firestore access patterns are duplicated across auth, dashboard, earnings, services, chat, and profile repositories. A small Firestore mapper/helper layer may reduce repeated timestamp/document parsing later.
- `core/services/location_sharing_service.dart`, `notification_service.dart`, and `osrm_service.dart` are app-wide enough to stay in core.
- `core/providers/core_providers.dart` currently mixes app-wide providers with customer booking feature providers.

## Large File Findings

Files over 500 lines:

| File | Lines | Classification | Split Recommendation |
|---|---:|---|---|
| `customer/booking/presentation/widgets/booking_bottom_panels.dart` | 1848 | Should split widgets | Finish migrating to existing `presentation/widgets/panels/*`, move service/sub-service data into helper/constants. |
| `customer/booking/presentation/screens/booking.dart` | 1668 | Legacy coordinator | Remove route usage and replace direct callers with modular `booking_screen.dart`; then delete or quarantine. |
| `mechanic/dashboard/presentation/screens/mechanic_dashboard.dart` | 1299 | Legacy coordinator | Route to `MechanicDashboardScreen`, then retire legacy screen after parity tests. |
| `mechanic/dashboard/presentation/widgets/mechanic_bottom_panels.dart` | 1253 | Should split widgets | Split offline/available/en-route/working/completed panels into separate files. |
| `mechanic/auth/presentation/screens/mechanic_mobile_number_screen.dart` | 972 | Should split flow screens | It contains phone, photo translate, welcome, and home screens. Keep one screen per file. |
| `mechanic/dashboard/presentation/screens/payment_confirmation_screen.dart` | 852 | Should split widgets/controller logic | Extract pricing rows, notes form, and completion action handling. |
| `customer/booking/presentation/screens/payment/payment_details_screen.dart` | 789 | Should split widgets | Extract summary/tip/payment widgets. |
| `customer/booking/presentation/screens/ai_chat_screen.dart` | 781 | Should split controller/services | Move chat message and AI request orchestration out of screen. |
| `customer/vehicles/presentation/screens/my_vehicles_screen.dart` | 704 | Should split widgets/data | Extract vehicle form, list, and fake data; add repository before persistence. |
| `mechanic/earnings/presentation/screens/earnings_screen.dart` | 657 | Should split data loading | Move Firebase loading behind provider/repository interface. |
| `customer/booking/presentation/screens/chat/chat_screen.dart` | 625 | Should split controller/repository injection | Use chat domain interface/provider; extract bubbles/input already mirrored in mechanic chat widgets. |
| `mechanic/dashboard/presentation/screens/profile_settings_screen.dart` | 619 | Should split widgets/data | Extract profile form sections and move Firestore/Auth writes to repository. |
| `mechanic/services/presentation/screens/payment_confirmation_screen.dart` | 567 | Should split widgets | Similar to dashboard payment confirmation; consider shared payment confirmation widgets. |
| `mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart` | 566 | Should split data/upload logic | Use mechanic auth repositories and extract document upload widgets. |
| `mechanic/dashboard/presentation/widgets/service_request_details_sheet.dart` | 563 | Should split widgets | Extract header, timeline, customer, and action sections. |
| `lib/core/theme/app_theme.dart` | 544 | Acceptable temporary compatibility layer | Keep during migration, but new code should prefer token files. |
| `mechanic/services/presentation/screens/service_history_screen.dart` | 542 | Should split repository loading | Move Firebase loading behind provider and extract cards/filters. |
| `mechanic/auth/presentation/screens/mechanic_auth_screen.dart` | 528 | Should split auth form sections | Use auth repository/provider. |
| `customer/booking/presentation/screens/payment/payment_screen.dart` | 522 | Should split widgets | Extract payment method tile and summary. |
| `mechanic/auth/presentation/widgets/auth_widgets.dart` | 509 | Acceptable shared widget bundle, but nearing split point | Split only if auth widgets continue to grow. |
| `customer/dashboard/presentation/screens/user_dashboard.dart` | 505 | Should split data/profile form | Move repository behind provider and extract profile sections. |

## Feature Smoke Test Plan

| Flow | Proposed Smoke Test | Required Fakes / Setup |
|---|---|---|
| Onboarding shell | Pump `OnboardingScreen` and verify first page renders with ARS theme. | None. |
| Splash auth branch | Pump `SplashScreen` with fake auth bootstrap service once extracted. | Fake auth state and prefs. |
| Customer login/signup shell | Pump login/signup screens and verify forms, buttons, and tokenized theme. | Fake `AuthRepository`. |
| Customer booking shell | Pump modular `BookingScreen` under `ProviderScope`; verify map shell and initial panel. | Fake `MechanicRepository`, `ServiceRequestRepository`, `ShopRepository`, fake current user id. |
| Customer payment shell | Pump `PaymentScreen` and `PaymentDetailsScreen`; verify summary/CTA. | Fake booking/payment data object. |
| Mechanic auth shell | Pump mechanic auth/basic/professional screens; verify forms. | Fake mechanic auth/data/storage repositories. |
| Mechanic dashboard shell | Pump `MechanicDashboardScreen`; verify top bar, map shell, online/offline panel. | Fake dashboard repositories and location provider. |
| Mechanic chat shell | Pump `MechanicChatScreen`; verify app bar, message list, input. | Fake `ChatRepository`, fake current user id. |

## Architecture Verdict

The app now has a cleaner baseline: analyzer is clean, raw design values are guarded, service semantic tokens have a tested helper, and `data/domain -> presentation` is blocked by a test.

The main architecture debt is not syntax; it is ownership:

- Presentation still directly constructs Firebase/OpenRoute repositories in several features.
- Core providers own some booking-specific repositories.
- Legacy and modular screens coexist for booking and mechanic dashboard.
- Several domain models still depend on Firestore timestamp types.
- Large screens/panels need controlled extraction, not a broad rewrite.

The next phase should start by routing only to modular screens and moving concrete repository creation into feature providers. That gives the biggest modularity gain without changing the product flow.
