/// Customer Dashboard Module
///
/// Barrel export for clean imports
///
/// Example usage:
/// ```dart
/// import 'package:arsapplication/features/customer/dashboard/dashboard.dart';
/// ```
library;

// Domain Layer
export 'domain/models/user_profile.dart';
export 'domain/repositories/profile_repository.dart';

// Data Layer
export 'data/repositories/firebase_profile_repository.dart';

// Presentation Layer
export 'presentation/screens/user_dashboard.dart';
