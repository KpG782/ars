# ARS Application - Clean Architecture Documentation

## Overview

This Flutter application follows **Feature-First Clean Architecture** principles, organizing code by user type (customer, mechanic) with each feature containing its own data/domain/presentation layers.

## Architecture Structure

```
lib/
├── core/                           # Shared services and utilities
│   ├── auth/
│   │   └── auth_service.dart      # Firebase authentication wrapper
│   ├── constants/                  # App-wide constants
│   ├── theme/                      # Material Design 3 theme
│   ├── widgets/                    # Reusable UI components
│   ├── network/                    # API clients
│   ├── storage/                    # Local storage utilities
│   ├── location/                   # Location services
│   ├── utils/                      # Helper functions
│   └── errors/                     # Error handling
│
├── features/
│   ├── customer/                   # Customer-facing features
│   │   ├── auth/                   # Customer authentication
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── user_login_screen.dart
│   │   │           ├── user_signup_screen.dart
│   │   │           └── user_email_verification_screen.dart
│   │   │
│   │   ├── booking/                # Service booking & management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── booking.dart
│   │   │       │   ├── location_selection.dart
│   │   │       │   ├── payment/
│   │   │       │   │   ├── payment_screen.dart
│   │   │       │   │   └── payment_success_screen.dart
│   │   │       │   └── chat/
│   │   │       │       └── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── booking_bottom_panels.dart
│   │   │           ├── booking_drawer.dart
│   │   │           ├── booking_status_panels.dart
│   │   │           ├── service_selection.dart
│   │   │           ├── sub_service_dialogs.dart
│   │   │           └── booking_enums.dart
│   │   │
│   │   ├── vehicles/               # Vehicle management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── my_vehicles_screen.dart
│   │   │
│   │   └── dashboard/              # Customer home/profile
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           └── screens/
│   │               └── user_dashboard.dart
│   │
│   ├── mechanic/                   # Mechanic-facing features
│   │   ├── auth/                   # Mechanic onboarding
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── mechanic_splash_screen.dart
│   │   │           ├── mechanic_auth_screen.dart
│   │   │           ├── mechanic_mobile_number_screen.dart
│   │   │           ├── mechanic_basic_info_screen.dart
│   │   │           ├── mechanic_professional_details_screen.dart
│   │   │           └── mechanic_verification_status_screen.dart
│   │   │
│   │   ├── services/               # Service requests & history
│   │   │   ├── data/
│   │   │   │   └── models/
│   │   │   │       └── service_request.dart
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── booking_request_screen.dart
│   │   │           └── service_history_screen.dart
│   │   │
│   │   ├── earnings/               # Earnings tracking
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── earnings_screen.dart
│   │   │
│   │   └── dashboard/              # Mechanic home & map
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── screens/
│   │           │   ├── mechanic_dashboard.dart
│   │           │   └── profile_settings_screen.dart
│   │           └── widgets/
│   │               ├── mechanic_bottom_panels.dart
│   │               ├── mechanic_drawer.dart
│   │               ├── mechanic_enums.dart
│   │               └── service_request_card.dart
│   │
│   └── onboarding/                 # App-wide onboarding
│       └── presentation/
│           └── screens/
│               ├── splash_screen.dart
│               └── onboarding_screen.dart
│
└── main.dart                       # App entry point
```

## Key Principles

### 1. **Feature-First Organization**

- Features are organized by user type (customer, mechanic)
- Each feature is self-contained with its own layers
- Shared code lives in `core/`

### 2. **Clean Architecture Layers**

Each feature follows the clean architecture pattern:

- **Data Layer**: Models, repositories, data sources
- **Domain Layer**: Entities, repository interfaces, use cases
- **Presentation Layer**: Screens, widgets, state management (BLoC)

### 3. **Separation of Concerns**

- Customer and mechanic features are completely isolated
- Authentication logic is shared via `core/auth/auth_service.dart`
- UI components specific to user types are contained within their features

### 4. **Naming Conventions**

- Customer screens: `user_*_screen.dart`
- Mechanic screens: `mechanic_*_screen.dart`
- This makes it easy to identify which user type a screen serves

## Feature Breakdown

### Customer Features

1. **Auth** (features/customer/auth)

   - Login, signup, email verification
   - Password recovery

2. **Booking** (features/customer/booking)

   - Service request creation
   - Location selection
   - Payment processing
   - Real-time chat with mechanic
   - Booking status tracking

3. **Vehicles** (features/customer/vehicles)

   - Add/edit/delete vehicles
   - Vehicle details management

4. **Dashboard** (features/customer/dashboard)
   - User profile
   - Booking history
   - Settings

### Mechanic Features

1. **Auth** (features/mechanic/auth)

   - Complete 6-screen onboarding flow
   - Mobile number verification
   - Basic information collection
   - Professional details & documents
   - Verification status tracking

2. **Services** (features/mechanic/services)

   - View incoming service requests
   - Accept/decline requests
   - Service history

3. **Earnings** (features/mechanic/earnings)

   - Track earnings
   - Payment history
   - Analytics

4. **Dashboard** (features/mechanic/dashboard)
   - Real-time map with customer locations
   - Active service tracking
   - Status management (offline, available, en route, working)
   - Profile settings

### Onboarding

- Shared app-wide onboarding
- User type selection (customer vs mechanic)
- Initial splash screen

## State Management

- **BLoC Pattern** (proposed for all features)
- Current implementation uses StatefulWidget
- Centralized auth state via AuthService

## Backend Integration

- **Firebase Authentication**: User/mechanic authentication
- **Cloud Firestore**: Real-time data storage
- **Firebase Storage**: Document and image uploads
- **Google Maps**: Location services

## Navigation

- Pure Flutter Navigator
- No Kotlin-based routing
- Route names defined per feature

## Migration Notes

- ✅ All screens renamed with proper prefixes
- ✅ New architecture structure created
- ✅ All files copied to new locations
- ✅ Imports updated across codebase
- ✅ Old folders cleaned up
- ✅ Compilation verified (no errors)

## Next Steps

1. Consider implementing BLoC for better state management
2. Add unit tests for each feature
3. Add integration tests for critical flows
4. Create README files for each feature explaining its responsibilities
5. Add API documentation for backend interactions
