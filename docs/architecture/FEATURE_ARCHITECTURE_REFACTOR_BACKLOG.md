# ARS Feature Architecture Refactor Backlog

**Date:** 2026-06-02  
**Source:** [`FEATURE_ARCHITECTURE_AUDIT.md`](./FEATURE_ARCHITECTURE_AUDIT.md)

This backlog converts the audit findings into concrete implementation slices. Priorities are based on runtime risk, testability, and whether the issue blocks modular feature ownership.

## P0

### P0-1: Keep data/domain independent from presentation

**Status:** Fixed in this pass.

**Files changed**

- `lib/features/mechanic/dashboard/data/models/service_request.dart`
- `test/architecture/feature_dependency_direction_test.dart`

**Work completed**

- Replaced the data-layer import of `presentation/widgets/mechanic_enums.dart` with a direct domain import for `RequestStatus`.
- Added a regression test that fails if any `lib/features/**/data/**` or `lib/features/**/domain/**` file imports presentation code.

**Expected tests**

- `flutter test test/architecture/feature_dependency_direction_test.dart`
- `flutter analyze`

**Risk**

- Low. This is an import-only boundary fix.

## P1

### P1-1: Move customer booking repository providers out of `core_providers.dart`

**Files**

- `lib/core/providers/core_providers.dart`
- `lib/features/customer/booking/presentation/controllers/booking_controller.dart`
- New: `lib/features/customer/booking/presentation/providers/booking_providers.dart`

**Problem**

`core_providers.dart` owns `mechanicRepositoryProvider`, `serviceRequestRepositoryProvider`, and `shopRepositoryProvider`, but these are customer booking feature dependencies.

**Expected fix**

- Keep Firebase, SharedPreferences, notification, OSRM, and auth state providers in core.
- Move booking repositories into a booking-owned provider file.
- Update `BookingController` imports to read the new feature provider file.

**Expected tests**

- `flutter test test/design_system/no_raw_design_values_test.dart`
- `flutter test test/architecture/feature_dependency_direction_test.dart`
- `flutter analyze`

**Risk**

- Medium. Provider import paths change, but runtime behavior should not.

### P1-2: Route to the modular mechanic dashboard

**Files**

- `lib/core/routing/app_router.dart`
- `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard_screen.dart`
- `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart`

**Problem**

`/mechanic/dashboard` points to legacy `MechanicDashboard`, while a Riverpod `MechanicDashboardScreen` and controller already exist.

**Expected fix**

- Add a smoke test for `MechanicDashboardScreen` with fake providers.
- Switch the route to `MechanicDashboardScreen` after parity is verified.
- Keep the legacy screen temporarily only if direct callers remain.

**Expected tests**

- New mechanic dashboard smoke test.
- `flutter test`
- `flutter analyze`

**Risk**

- High. This affects mechanic home navigation and map/live-request behavior.

### P1-3: Remove direct legacy customer booking screen navigation

**Files**

- `lib/features/mechanic/auth/presentation/screens/mechanic_mobile_number_screen.dart`
- `lib/features/customer/booking/presentation/screens/payment/payment_success_screen.dart`
- `lib/features/customer/booking/booking.dart`
- `lib/features/customer/booking/presentation/screens/booking.dart`
- `lib/features/customer/booking/presentation/screens/booking_screen.dart`

**Problem**

Several direct `MaterialPageRoute` flows import `booking.dart`, the legacy 1600+ line booking screen, while app routing uses modular `booking_screen.dart`.

**Expected fix**

- Replace direct pushes with `context.go(AppRoutes.customerBooking)` where possible.
- If push replacement is required, import modular `booking_screen.dart`.
- Stop exporting legacy `booking.dart` from the feature barrel once all direct callers move.

**Expected tests**

- Customer booking shell smoke test.
- `flutter analyze`
- `flutter test`

**Risk**

- Medium-high. Navigation behavior changes after auth/payment flows.

### P1-4: Convert presentation-owned Firebase repositories to providers

**Files**

- `lib/features/customer/auth/presentation/screens/user_login_screen.dart`
- `lib/features/customer/auth/presentation/screens/user_signup_screen.dart`
- `lib/features/customer/auth/presentation/screens/user_email_verification_screen.dart`
- `lib/features/customer/dashboard/presentation/screens/user_dashboard.dart`
- `lib/features/mechanic/earnings/presentation/screens/earnings_screen.dart`
- `lib/features/mechanic/services/presentation/screens/service_history_screen.dart`
- `lib/features/mechanic/services/presentation/screens/booking_request.dart`
- `lib/features/mechanic/chat/presentation/screens/mechanic_chat_screen.dart`
- `lib/features/customer/booking/presentation/screens/chat/chat_screen.dart`

**Problem**

Screens instantiate concrete data repositories directly, which makes them hard to test and violates the intended dependency inversion.

**Expected fix**

- Add feature provider files beside each controller/screen group.
- Expose domain interfaces through providers.
- Update screens to read providers or receive dependencies through constructors.

**Expected tests**

- One smoke test per updated screen family with fake repositories.
- `flutter analyze`

**Risk**

- Medium. Mostly dependency construction changes, but auth/chat flows need careful fake setup.

### P1-5: Remove Firebase types from domain models

**Files**

- `lib/features/customer/booking/domain/models/service_request.dart`
- `lib/features/mechanic/chat/domain/models/chat_message.dart`
- `lib/features/mechanic/auth/domain/models/mechanic_user.dart`
- Matching data repository mapper files.

**Problem**

Domain models import Firestore timestamp types. That keeps domain tests tied to Firebase packages and weakens the `domain` layer.

**Expected fix**

- Move Firestore timestamp conversion into data repositories or mapper classes.
- Keep domain models on Dart primitives (`DateTime`, `String`, `num`, lists/maps where needed).

**Expected tests**

- New pure Dart model mapping tests.
- `flutter analyze`
- `flutter test`

**Risk**

- Medium. Serialization/deserialization can regress if mapper coverage is weak.

## P2

### P2-1: Finish service semantic centralization

**Files**

- `lib/core/theme/service_semantics.dart`
- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`
- `lib/features/customer/booking/presentation/widgets/panels/service_selection_panel.dart`
- `lib/features/customer/booking/presentation/widgets/panels/sub_service_selection_panel.dart`
- `lib/features/mechanic/dashboard/presentation/widgets/nearby_requests_panel.dart`
- `lib/features/mechanic/dashboard/presentation/widgets/service_request_card.dart`

**Problem**

Mechanic request cards now use `ServiceSemanticTheme`, but customer booking still has embedded service icon/color/sub-service maps.

**Expected fix**

- Move service family metadata into a booking/domain-safe helper or `core/theme/service_semantics.dart` if it remains visual-only.
- Keep copy and sub-service choices feature-owned; keep visual semantics shared.

**Expected tests**

- Extend `service_semantics_test.dart`.
- Customer service selection widget smoke test.

**Risk**

- Low-medium. Visual mapping changes are visible but easy to verify.

### P2-2: Split customer booking panels

**Files**

- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`
- Existing `lib/features/customer/booking/presentation/widgets/panels/*.dart`

**Problem**

`booking_bottom_panels.dart` is 1800+ lines and duplicates files already started under `widgets/panels`.

**Expected fix**

- Move one panel at a time into `widgets/panels`.
- Keep a compatibility wrapper until all call sites are moved.
- Run widget smoke tests after each panel extraction.

**Expected tests**

- Customer booking panel smoke tests.
- `flutter test`

**Risk**

- Medium. UI regressions are likely if done as one large rewrite.

### P2-3: Split mechanic dashboard panels

**Files**

- `lib/features/mechanic/dashboard/presentation/widgets/mechanic_bottom_panels.dart`
- New per-panel files under `widgets/panels/`

**Problem**

`mechanic_bottom_panels.dart` is 1200+ lines with multiple state-specific panels.

**Expected fix**

- Extract offline, available, en-route, working, and completed panels.
- Keep panel state transitions in the screen/controller.

**Expected tests**

- Mechanic dashboard smoke tests.
- Focused widget tests for each panel.

**Risk**

- Medium. State-specific callbacks need careful wiring.

### P2-4: Split mechanic mobile auth flow

**Files**

- `lib/features/mechanic/auth/presentation/screens/mechanic_mobile_number_screen.dart`
- New screen/widget files under `mechanic/auth/presentation/screens/`

**Problem**

One 900+ line file contains unrelated flow screens (`PhotoTranslateScreen`, `WelcomeScreen`, `HomeScreen`) and direct navigation to customer booking.

**Expected fix**

- Move each screen class into its own file.
- Replace direct booking pushes with router calls.
- Keep auth flow state explicit through route params or a feature controller.

**Expected tests**

- Mechanic auth smoke tests.
- `flutter analyze`

**Risk**

- Medium. Navigation and onboarding state can regress.

### P2-5: Extract Firestore mapper helpers

**Files**

- Firebase repository files across customer booking/dashboard and mechanic dashboard/services/earnings/chat/auth.
- New: `lib/core/services/firestore_mapper.dart` or feature-specific mapper files.

**Problem**

Timestamp and document parsing logic is repeated across repositories.

**Expected fix**

- Prefer feature-specific mappers first; only move to core if shared behavior is truly generic.
- Add mapper tests for null timestamps, server timestamps, and missing numeric fields.

**Expected tests**

- Mapper unit tests.
- Existing repository tests once fakes are available.

**Risk**

- Medium. Data parsing regressions are subtle.

## P3

### P3-1: Gradually replace layout primitives with spacing/radius/motion tokens

**Files**

- Feature presentation files touched during regular work.
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radii.dart`
- `lib/core/theme/app_motion.dart`

**Problem**

The raw-design guard intentionally allows `EdgeInsets`, `BorderRadius`, and `Duration`, but widespread raw use makes consistency drift possible.

**Expected fix**

- Replace primitives opportunistically when a screen is already being edited.
- Do not do a blind app-wide rewrite without screenshots/widget tests.

**Expected tests**

- Design-system guard.
- Screen/widget tests for touched UI.

**Risk**

- Low if incremental; medium if mass-rewritten.

### P3-2: Review `Colors.white` / `Colors.black` usage

**Files**

- Feature presentation files.
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`

**Problem**

White and black are allowed primitives, but some usages are semantic (`onPrimary`, `onEmergency`, shadow) and should eventually be tokenized.

**Expected fix**

- Keep true black/white for shadows and platform primitives.
- Use `colorScheme.onPrimary`, `AppTheme.onActionColor`, or ARS tokens where the color has meaning.

**Expected tests**

- Design-system guard.
- Contrast tests if token pairs are changed.

**Risk**

- Low.

### P3-3: Replace compatibility barrels after migration

**Files**

- `lib/features/customer/booking/booking.dart`
- `lib/features/mechanic/auth/presentation/widgets/mechanic_enums.dart`

**Problem**

Compatibility exports keep old names alive and hide which implementation is canonical.

**Expected fix**

- Remove compatibility exports only after all call sites are moved and tests prove the route flow.

**Expected tests**

- `rg` confirms no legacy imports.
- `flutter analyze`
- Feature smoke tests.

**Risk**

- Low if done after P1/P2 work.
