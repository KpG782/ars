
## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [Target Architecture](#target-architecture)
4. [Migration Strategy](#migration-strategy)
5. [Implementation Phases](#implementation-phases)
6. [File Structure Changes](#file-structure-changes)
7. [Testing Strategy](#testing-strategy)
8. [Checklist](#checklist)

---

## 🔧 Prerequisites

### 1. Dependencies to Add
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1      # Core Riverpod for Flutter
  riverpod_annotation: ^2.3.5   # For code generation (optional but recommended)

dev_dependencies:
  riverpod_generator: ^2.4.0    # Code generation for providers
  build_runner: ^2.4.8          # Required for code generation
  riverpod_lint: ^2.3.10        # Linting rules for Riverpod
```

### 2. Knowledge Requirements
- [ ] Understand `Provider` types (Provider, StateProvider, StateNotifierProvider, ChangeNotifierProvider, FutureProvider, StreamProvider)
- [ ] Understand `ref.watch()` vs `ref.read()` vs `ref.listen()`
- [ ] Understand `ConsumerWidget` vs `ConsumerStatefulWidget`
- [ ] Understand provider scoping and overrides

### 3. Tools Setup
- [ ] VS Code extension: "Flutter Riverpod Snippets"
- [ ] Enable Riverpod lint rules in `analysis_options.yaml`

---

## 📊 Current Architecture Analysis

### Existing Controllers (ChangeNotifier-based)
| Controller | Location | Lines | State Complexity |
|------------|----------|-------|------------------|
| `BookingController` | `lib/features/customer/booking/presentation/controllers/` | ~290 | High (map, search, booking flow) |
| `MechanicDashboardController` | `lib/features/mechanic/dashboard/presentation/controllers/` | ~280 | High (location, requests, status) |

### Current State Management Pattern
```
┌─────────────────────────────────────────────────────────┐
│  Screen (StatefulWidget)                                │
│    └── Creates Controller in initState()                │
│         └── Calls controller.addListener(_update)       │
│              └── setState(() {}) on changes             │
└─────────────────────────────────────────────────────────┘
```

### Problems with Current Approach
1. **Manual lifecycle management** - Must remember to dispose controllers
2. **No dependency injection** - Hard to test and mock
3. **State not shared** - Each screen creates its own instance
4. **No caching** - Data re-fetched on every screen visit

---

## 🎯 Target Architecture

### Riverpod Architecture Pattern
```
┌─────────────────────────────────────────────────────────┐
│  ProviderScope (main.dart)                              │
│    └── App                                              │
│         └── ConsumerWidget/ConsumerStatefulWidget       │
│              └── ref.watch(provider) - Auto rebuilds    │
│              └── ref.read(provider) - One-time read     │
└─────────────────────────────────────────────────────────┘
```

### Provider Hierarchy Design
```
┌─────────────────────────────────────────────────────────┐
│                    CORE PROVIDERS                        │
├─────────────────────────────────────────────────────────┤
│  firebaseAuthProvider         → Firebase Auth instance   │
│  firestoreProvider            → Firestore instance       │
│  osrmServiceProvider          → OSRM routing service     │
│  currentUserProvider          → Current logged-in user   │
│  locationServiceProvider      → Geolocator service       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  REPOSITORY PROVIDERS                    │
├─────────────────────────────────────────────────────────┤
│  mechanicRepositoryProvider   → Mechanic data ops        │
│  shopRepositoryProvider       → Shop data ops            │
│  bookingRepositoryProvider    → Booking data ops         │
│  serviceRequestRepoProvider   → Service request ops      │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  FEATURE PROVIDERS                       │
├─────────────────────────────────────────────────────────┤
│  CUSTOMER BOOKING                                        │
│  ├── bookingStateProvider     → BookingState notifier    │
│  ├── nearbyMechanicsProvider  → FutureProvider<List>     │
│  ├── nearbyShopsProvider      → FutureProvider<List>     │
│  ├── selectedMechanicProvider → StateProvider<Mechanic?> │
│  ├── selectedShopProvider     → StateProvider<Shop?>     │
│  └── routeProvider            → FutureProvider<Route>    │
├─────────────────────────────────────────────────────────┤
│  MECHANIC DASHBOARD                                      │
│  ├── mechanicStateProvider    → MechanicState notifier   │
│  ├── onlineStatusProvider     → StateProvider<bool>      │
│  ├── nearbyRequestsProvider   → StreamProvider<List>     │
│  ├── acceptedRequestProvider  → StateProvider<Request?>  │
│  └── mechanicLocationProvider → StreamProvider<LatLng>   │
└─────────────────────────────────────────────────────────┘
```

### State Class Design (Immutable)
```dart
// BEFORE: Mutable state in ChangeNotifier
class BookingController extends ChangeNotifier {
  bool isLoading = false;
  List<Mechanic> mechanics = [];
  // Mutating state directly
}

// AFTER: Immutable state with Riverpod
@freezed
class BookingState with _$BookingState {
  const factory BookingState({
    @Default(false) bool isLoading,
    @Default([]) List<Mechanic> mechanics,
    Mechanic? selectedMechanic,
    BookingStatus? status,
    String? errorMessage,
  }) = _BookingState;
}
```

---

## 🔄 Migration Strategy

### Approach: Gradual Migration (Recommended)
Instead of rewriting everything, migrate incrementally:

1. **Phase 1**: Setup infrastructure (ProviderScope, core providers)
2. **Phase 2**: Migrate one feature completely (Customer Booking)
3. **Phase 3**: Migrate second feature (Mechanic Dashboard)
4. **Phase 4**: Migrate remaining features
5. **Phase 5**: Remove old ChangeNotifier code

### Compatibility Layer
Your existing `ChangeNotifier` controllers can be wrapped immediately:
```dart
// Wrap existing controller - works immediately!
final bookingControllerProvider = ChangeNotifierProvider((ref) {
  return BookingController();
});
```

---

## 📁 Implementation Phases

### Phase 1: Infrastructure Setup (Day 1)
**Goal**: Set up Riverpod without breaking existing code

| Task | File | Description |
|------|------|-------------|
| 1.1 | `pubspec.yaml` | Add Riverpod dependencies |
| 1.2 | `analysis_options.yaml` | Add Riverpod lint rules |
| 1.3 | `lib/main.dart` | Wrap app with ProviderScope |
| 1.4 | `lib/core/providers/` | Create core providers directory |
| 1.5 | `lib/core/providers/core_providers.dart` | Firebase, services providers |

**Estimated Time**: 1-2 hours

### Phase 2: Customer Booking Migration (Day 2-3)
**Goal**: Fully migrate booking feature to Riverpod

| Task | File | Description |
|------|------|-------------|
| 2.1 | `booking/domain/states/booking_state.dart` | Create immutable state class |
| 2.2 | `booking/presentation/providers/booking_providers.dart` | Create all booking providers |
| 2.3 | `booking/presentation/providers/booking_notifier.dart` | Create StateNotifier |
| 2.4 | `booking/presentation/screens/booking_screen.dart` | Convert to ConsumerWidget |
| 2.5 | `booking/presentation/widgets/*.dart` | Update widgets to use ref |

**Estimated Time**: 4-6 hours

### Phase 3: Mechanic Dashboard Migration (Day 4-5)
**Goal**: Fully migrate mechanic dashboard to Riverpod

| Task | File | Description |
|------|------|-------------|
| 3.1 | `dashboard/domain/states/mechanic_state.dart` | Create immutable state class |
| 3.2 | `dashboard/presentation/providers/mechanic_providers.dart` | Create all providers |
| 3.3 | `dashboard/presentation/providers/mechanic_notifier.dart` | Create StateNotifier |
| 3.4 | `dashboard/presentation/screens/mechanic_dashboard_screen.dart` | Convert to ConsumerWidget |
| 3.5 | `dashboard/presentation/widgets/*.dart` | Update widgets to use ref |

**Estimated Time**: 4-6 hours

### Phase 4: Remaining Features (Day 6-7)
**Goal**: Migrate auth, profile, chat, payments

| Feature | Priority | Complexity |
|---------|----------|------------|
| Authentication | High | Medium |
| User Profile | Medium | Low |
| Chat | Medium | Medium |
| Payments | Low | Low |

**Estimated Time**: 4-6 hours

### Phase 5: Cleanup & Testing (Day 8)
**Goal**: Remove old code, add tests

| Task | Description |
|------|-------------|
| 5.1 | Remove old ChangeNotifier controllers |
| 5.2 | Update barrel exports |
| 5.3 | Write unit tests for providers |
| 5.4 | Write widget tests |

**Estimated Time**: 3-4 hours

---

## 📂 File Structure Changes

### New Directory Structure
```
lib/
├── core/
│   ├── providers/                    # NEW: Core providers
│   │   ├── core_providers.dart       # Firebase, services
│   │   ├── auth_providers.dart       # Auth state
│   │   └── providers.dart            # Barrel export
│   ├── services/
│   └── theme/
│
├── features/
│   ├── customer/
│   │   └── booking/
│   │       ├── data/
│   │       ├── domain/
│   │       │   ├── models/
│   │       │   ├── repositories/
│   │       │   └── states/           # NEW: Immutable states
│   │       │       └── booking_state.dart
│   │       └── presentation/
│   │           ├── controllers/      # DEPRECATED: Will remove
│   │           ├── providers/        # NEW: Riverpod providers
│   │           │   ├── booking_providers.dart
│   │           │   └── booking_notifier.dart
│   │           ├── screens/
│   │           └── widgets/
│   │
│   └── mechanic/
│       └── dashboard/
│           ├── data/
│           ├── domain/
│           │   ├── models/
│           │   ├── repositories/
│           │   └── states/           # NEW: Immutable states
│           │       └── mechanic_state.dart
│           └── presentation/
│               ├── controllers/      # DEPRECATED: Will remove
│               ├── providers/        # NEW: Riverpod providers
│               │   ├── mechanic_providers.dart
│               │   └── mechanic_notifier.dart
│               ├── screens/
│               └── widgets/
```

---

## 🧪 Testing Strategy

### Unit Tests for Providers
```dart
// Example test structure
void main() {
  group('BookingNotifier', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      final state = container.read(bookingStateProvider);
      expect(state.isLoading, false);
      expect(state.mechanics, isEmpty);
    });

    test('searchMechanics updates state', () async {
      final container = ProviderContainer(
        overrides: [
          mechanicRepositoryProvider.overrideWithValue(MockMechanicRepo()),
        ],
      );
      
      await container.read(bookingStateProvider.notifier).searchMechanics();
      
      final state = container.read(bookingStateProvider);
      expect(state.mechanics, isNotEmpty);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('BookingScreen displays loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookingStateProvider.overrideWith((ref) => BookingNotifier()..setLoading(true)),
        ],
        child: MaterialApp(home: BookingScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## ✅ Checklist

### Pre-Implementation
- [ ] Read Riverpod documentation (https://riverpod.dev)
- [ ] Understand current codebase state management
- [ ] Backup current code / create new branch
- [ ] Install VS Code Riverpod extension

### Phase 1: Infrastructure
- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Add lint rules to analysis_options.yaml
- [ ] Wrap main.dart with ProviderScope
- [ ] Create core_providers.dart
- [ ] Test app still runs

### Phase 2: Customer Booking
- [ ] Create BookingState class
- [ ] Create BookingNotifier
- [ ] Create booking_providers.dart
- [ ] Convert BookingScreen to ConsumerWidget
- [ ] Update all booking widgets
- [ ] Test booking flow works

### Phase 3: Mechanic Dashboard
- [ ] Create MechanicState class
- [ ] Create MechanicNotifier
- [ ] Create mechanic_providers.dart
- [ ] Convert MechanicDashboardScreen to ConsumerWidget
- [ ] Update all dashboard widgets
- [ ] Test dashboard flow works

### Phase 4: Other Features
- [ ] Migrate authentication
- [ ] Migrate profile
- [ ] Migrate chat
- [ ] Migrate payments

### Phase 5: Cleanup
- [ ] Remove old ChangeNotifier controllers
- [ ] Update all barrel exports
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Update documentation

---

## 📚 Resources

- [Riverpod Official Docs](https://riverpod.dev)
- [Riverpod GitHub](https://github.com/rrousselGit/riverpod)
- [Code With Andrea - Riverpod Guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Riverpod 2.0 Migration Guide](https://riverpod.dev/docs/migration/from_change_notifier)

---

## ⏱️ Time Estimate Summary

| Phase | Estimated Time |
|-------|----------------|
| Phase 1: Infrastructure | 1-2 hours |
| Phase 2: Customer Booking | 4-6 hours |
| Phase 3: Mechanic Dashboard | 4-6 hours |
| Phase 4: Other Features | 4-6 hours |
| Phase 5: Cleanup & Testing | 3-4 hours |
| **Total** | **16-24 hours** |

---

*Created: January 2026*
*Status: Planning Phase*
