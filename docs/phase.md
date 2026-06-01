# 📋 Clean Architecture Migration Plan

## Current Structure Analysis

**Problems Identified:**

1. ❌ Mixed concerns at root level (splash_screen, loading_screen, onboarding_screen)
2. ❌ No clear separation between layers (presentation, domain, data)
3. ❌ Shared components scattered (widgets at root, models separate)
4. ❌ Feature boundaries unclear (auth, mechanic, user mixed with shared code)
5. ❌ Cross-feature dependencies not managed
6. ❌ Kotlin navigation files in lib/ folder (should be in android/)
7. ❌ Hard to test due to tight coupling
8. ❌ Difficult to scale and add new features

---

## 🎯 Proposed Clean Architecture Structure

```
lib/
├── core/                           # Shared/Common code
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   ├── api_constants.dart      # API endpoints
│   │   └── route_constants.dart    # Route names
│   ├── theme/
│   │   └── app_theme.dart          # Current theme
│   ├── utils/
│   │   ├── validators.dart         # Form validators
│   │   ├── formatters.dart         # Text formatters
│   │   └── helpers.dart            # Helper functions
│   ├── widgets/                    # Shared UI components
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_indicator.dart
│   ├── errors/
│   │   ├── failures.dart           # Error handling
│   │   └── exceptions.dart
│   └── services/                   # Core services
│       └── navigation_service.dart
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   ├── email_verification_screen.dart
│   │   │   │   ├── mechanic_auth_screen.dart
│   │   │   │   └── verification_status_screen.dart
│   │   │   └── widgets/
│   │   │       └── (auth-specific widgets if any)
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart (abstract)
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── signup_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── data/
│   │       ├── models/
│   │       │   ├── user_model.dart
│   │       │   └── mechanic_model.dart
│   │       ├── datasources/
│   │       │   ├── auth_remote_datasource.dart
│   │       │   └── auth_local_datasource.dart
│   │       └── repositories/
│   │           └── auth_repository_impl.dart
│   │
│   ├── onboarding/                 # Onboarding feature
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── loading_screen.dart
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           └── onboarding_page.dart
│   │
│   ├── mechanic/                   # Mechanic feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── mechanic_dashboard.dart
│   │   │   │   ├── basic_info_screen.dart
│   │   │   │   ├── mobile_number_screen.dart
│   │   │   │   ├── splash.dart
│   │   │   │   ├── earnings_screen.dart
│   │   │   │   ├── profile_settings_screen.dart
│   │   │   │   └── service_history_screen.dart
│   │   │   └── widgets/
│   │   │       ├── mechanic_bottom_panels.dart
│   │   │       ├── mechanic_drawer.dart
│   │   │       └── service_request_card.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── mechanic_profile_entity.dart
│   │   │   │   └── service_request_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── mechanic_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_service_requests_usecase.dart
│   │   │       ├── accept_request_usecase.dart
│   │   │       └── update_profile_usecase.dart
│   │   └── data/
│   │       ├── models/
│   │       │   ├── mechanic_profile_model.dart
│   │       │   └── service_request_model.dart
│   │       ├── datasources/
│   │       │   └── mechanic_remote_datasource.dart
│   │       └── repositories/
│   │           └── mechanic_repository_impl.dart
│   │
│   ├── user/                       # User feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── user_dashboard.dart
│   │   │   │   ├── booking_screen.dart
│   │   │   │   ├── location_selection_screen.dart
│   │   │   │   ├── my_vehicles_screen.dart
│   │   │   │   ├── chat_screen.dart
│   │   │   │   ├── payment_screen.dart
│   │   │   │   └── payment_success_screen.dart
│   │   │   └── widgets/
│   │   │       ├── booking_bottom_panels.dart
│   │   │       ├── booking_drawer.dart
│   │   │       ├── booking_status_panels.dart
│   │   │       ├── service_selection.dart
│   │   │       └── sub_service_dialogs.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── mechanic_entity.dart
│   │   │   ├── repositories/
│   │   │   │   ├── booking_repository.dart
│   │   │   │   └── vehicle_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_booking_usecase.dart
│   │   │       ├── get_nearby_mechanics_usecase.dart
│   │   │       └── make_payment_usecase.dart
│   │   └── data/
│   │       ├── models/
│   │       │   └── mechanic_model.dart
│   │       ├── datasources/
│   │       │   ├── booking_remote_datasource.dart
│   │       │   └── payment_remote_datasource.dart
│   │       └── repositories/
│   │           ├── booking_repository_impl.dart
│   │           └── vehicle_repository_impl.dart
│   │
│   └── professional_onboarding/    # Mechanic professional details
│       └── presentation/
│           └── screens/
│               └── professional_details_screen.dart
│
├── firebase_options.dart           # Firebase config (stays at root)
└── main.dart                       # App entry point (stays at root)
```

---

## 🔄 Migration Steps

### **Phase 1: Setup Core Structure**

1. Create `core/` folder with subfolders
2. Move `theme/app_theme.dart` → `core/theme/`
3. Move `widgets/` → `core/widgets/`
4. Create `core/constants/`, `core/utils/`, `core/errors/`

### **Phase 2: Feature - Onboarding**

5. Create `features/onboarding/presentation/screens/`
6. Move:
   - `splash_screen.dart` → `features/onboarding/presentation/screens/`
   - `loading_screen.dart` → `features/onboarding/presentation/screens/`
   - `onboarding_screen.dart` → `features/onboarding/presentation/screens/`

### **Phase 3: Feature - Auth**

7. Create `features/auth/` with 3 layers (presentation, domain, data)
8. Move all `auth/*.dart` files → `features/auth/presentation/screens/`
9. Extract `auth_service.dart` logic:
   - Abstract interface → `features/auth/domain/repositories/`
   - Implementation → `features/auth/data/repositories/`
10. Move models:
    - `models/user_model.dart` → `features/auth/data/models/`
    - `models/mechanic_model.dart` → `features/auth/data/models/`

### **Phase 4: Feature - Mechanic**

11. Create `features/mechanic/` with 3 layers
12. Move all `mechanic/*.dart` screens → `features/mechanic/presentation/screens/`
13. Move `mechanic/components/` → `features/mechanic/presentation/widgets/`
14. Move `mechanic/models/` → `features/mechanic/data/models/`
15. Move `mechanic/services/mechanic_service.dart`:
    - Abstract → `features/mechanic/domain/repositories/`
    - Implementation → `features/mechanic/data/repositories/`
16. Move `mechanic/screens/` content → `features/mechanic/presentation/screens/`

### **Phase 5: Feature - User**

17. Create `features/user/` with 3 layers
18. Move all `user/*.dart` screens → `features/user/presentation/screens/`
19. Move `user/components/` → `features/user/presentation/widgets/`
20. Move `user/models/` → `features/user/data/models/`
21. Move `user/chat/` → `features/user/presentation/screens/`
22. Move `user/payment/` → `features/user/presentation/screens/`

### **Phase 6: Professional Onboarding**

23. Create `features/professional_onboarding/presentation/screens/`
24. Move `auth/professional_details_screen.dart` → new location

### **Phase 7: Update Imports**

25. Update all import statements across the app
26. Fix broken references

### **Phase 8: Cleanup**

27. Delete old empty folders
28. Move `navigation/*.kt` files to kotlin
29. Run `flutter analyze` and fix issues
30. Test all features

---

## 📊 Benefits of New Structure

| Aspect                    | Before    | After                                    |
| ------------------------- | --------- | ---------------------------------------- |
| **Feature Isolation**     | Mixed     | ✅ Each feature self-contained           |
| **Testability**           | Hard      | ✅ Easy to test layers independently     |
| **Code Reusability**      | Scattered | ✅ Centralized in `core/`                |
| **Scalability**           | Difficult | ✅ Add features without affecting others |
| **Team Collaboration**    | Conflicts | ✅ Teams work on separate features       |
| **Dependency Management** | Unclear   | ✅ Clear dependency direction            |
| **Navigation**            | Tangled   | ✅ Clear feature boundaries              |
| **Onboarding New Devs**   | Confusing | ✅ Easy to understand structure          |

---

## ⚠️ Important Notes

1. **Backup your code** - Use Git to commit current state
2. **Update in phases** - Don't try to migrate everything at once
3. **Test after each phase** - Ensure app still works
4. **Domain layer** - Initially can be simple, add use cases as needed
5. **Dependencies** - Domain layer should NOT depend on data/presentation
6. **Shared models** - If a model is used by multiple features, keep in respective data layer or create a shared feature

---

## 🎯 Next Steps

**Should I proceed with this migration?**

Please review this plan and let me know:

1. ✅ **Approve and start migration** - I'll begin with Phase 1
2. 🔄 **Request modifications** - Tell me what you'd like changed
3. ❓ **Ask questions** - I'll clarify any part of the plan

**Estimated Time:**

- Manual migration: 2-3 hours
- With my assistance: 20-30 minutes (automated with careful validation)

**What would you like me to do?**
