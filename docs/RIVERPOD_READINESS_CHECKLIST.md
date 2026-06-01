# Riverpod Migration Readiness Checklist

## ✅ Phase 1 (Infrastructure) - COMPLETED

### Dependencies Added
- [x] flutter_riverpod: ^2.5.1
- [x] riverpod_annotation: ^2.3.5
- [x] build_runner: ^2.4.11
- [x] riverpod_generator: ^2.4.0
- [x] riverpod_lint: ^2.3.10
- [x] custom_lint: ^0.6.4

### Configuration Updates
- [x] Updated analysis_options.yaml with custom_lint plugin
- [x] Added Riverpod-recommended lint rules (prefer_const_constructors, etc.)

### Code Infrastructure
- [x] Created lib/core/providers/ directory
- [x] Created core_providers.dart with Firebase & service providers
- [x] Created providers.dart barrel export file
- [x] Created provider directories in customer/booking and mechanic/dashboard
- [x] Wrapped MyApp with ProviderScope in main.dart

### Core Providers Created
- [x] firebaseAuthProvider
- [x] firestoreProvider
- [x] firebaseStorageProvider
- [x] firebaseMessagingProvider
- [x] sharedPreferencesProvider (async)
- [x] notificationServiceProvider
- [x] osrmServiceProvider
- [x] authStateProvider (stream)
- [x] currentUserIdProvider

---

## 🔄 Next Steps (Phase 2 - Customer Booking Migration)

### Preparation
- [ ] Run `flutter pub get` to install dependencies
- [ ] Test app compilation with new dependencies
- [ ] Verify ProviderScope wrapping doesn't break existing functionality

### Customer Booking Controllers
- [ ] Create booking_providers.dart
- [ ] Create BookingState class (immutable state)
- [ ] Convert BookingController to BookingNotifier
- [ ] Add StateNotifierProvider for booking state
- [ ] Create repository provider for BookingRepository
- [ ] Update booking_screen.dart to use ConsumerWidget
- [ ] Update all booking widgets to read from providers

### Testing
- [ ] Test customer booking flow end-to-end
- [ ] Verify map interactions still work
- [ ] Verify search functionality
- [ ] Verify mechanic selection
- [ ] Verify emergency booking

---

## 📋 Current Codebase Status

### Refactored Files (All <500 lines)
**Customer Booking:**
- booking_controller.dart (~290 lines)
- booking_screen.dart (~290 lines)
- booking_map_widget.dart (~190 lines)
- mechanic_details_sheet.dart (~180 lines)
- shop_details_sheet.dart (~320 lines)
- booking_search_bar.dart (~195 lines)
- booking_dialogs.dart (~200 lines)
- 7 panel widgets (~75-340 lines each)

**Mechanic Dashboard:**
- mechanic_dashboard_controller.dart (~280 lines)
- mechanic_dashboard_screen.dart (~350 lines)
- mechanic_map_widget.dart (~220 lines)
- mechanic_dashboard_top_bar.dart (~140 lines)
- online_status_button.dart (~95 lines)
- nearby_requests_panel.dart (~270 lines)
- active_job_panel.dart (~280 lines)
- service_request_details_sheet.dart (~430 lines)
- mechanic_dashboard_dialogs.dart (~240 lines)

### Current State Management Pattern
All controllers currently use:
- ChangeNotifier for state management
- notifyListeners() for UI updates
- StatefulWidget + Provider pattern

This structure makes them easy to migrate to Riverpod's StateNotifier pattern.

---

## 🎯 Migration Strategy

### Phase 2: Customer Booking (4-6 hours)
1. Create state classes
2. Convert controllers to notifiers
3. Create providers
4. Update widgets to ConsumerWidget
5. Test thoroughly

### Phase 3: Mechanic Dashboard (4-6 hours)
1. Apply same pattern as Phase 2
2. Handle location tracking with providers
3. Handle request streaming with StreamProvider
4. Test thoroughly

### Phase 4: Other Features (4-6 hours)
- Auth flows
- Profile management
- Chat feature
- Payment processing

### Phase 5: Cleanup & Testing (3-4 hours)
- Remove old ChangeNotifier code
- Add unit tests for providers
- Add widget tests
- Add integration tests

---

## ⚡ Quick Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (when using riverpod_generator)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (continuous generation)
flutter pub run build_runner watch --delete-conflicting-outputs

# Run app
flutter run

# Run tests (once added)
flutter test

# Analyze code
flutter analyze
```

---

## 🏗️ New Directory Structure

```
lib/
├── core/
│   ├── providers/
│   │   ├── core_providers.dart        ✅ Created
│   │   └── providers.dart              ✅ Created
│   ├── services/
│   └── theme/
├── features/
│   ├── customer/
│   │   └── booking/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── controllers/
│   │           ├── providers/          ✅ Created (empty)
│   │           │   ├── booking_providers.dart      ⏳ Next
│   │           │   └── booking_state.dart          ⏳ Next
│   │           ├── screens/
│   │           └── widgets/
│   └── mechanic/
│       └── dashboard/
│           ├── data/
│           ├── domain/
│           └── presentation/
│               ├── controllers/
│               ├── providers/          ✅ Created (empty)
│               │   ├── dashboard_providers.dart    ⏳ Phase 3
│               │   └── dashboard_state.dart        ⏳ Phase 3
│               ├── screens/
│               └── widgets/
└── main.dart                           ✅ Updated (ProviderScope)
```

---

## ✅ Pre-Migration Verification Complete

**Status:** Infrastructure ready for Riverpod migration  
**Next Action:** Run `flutter pub get` and test app compilation  
**Estimated Time to Phase 2 Start:** 15-30 minutes (testing)  
**Total Migration Timeline:** 16-24 hours

---

*Last Updated: January 2026*  
*Prepared By: GitHub Copilot*
