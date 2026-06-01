/// Customer Auth Module Barrel Export
///
/// Provides clean imports for customer authentication following Clean Architecture.
/// Usage example:
///   import 'package:arsapplication/features/customer/auth/auth.dart';
library;

// Domain Layer Exports
export 'domain/models/user.dart';
export 'domain/repositories/auth_repository.dart';

// Data Layer Exports
export 'data/repositories/firebase_auth_repository.dart';

// Presentation Layer Exports
export 'presentation/screens/user_login_screen.dart';
export 'presentation/screens/user_signup_screen.dart';
export 'presentation/screens/user_email_verification_screen.dart';
