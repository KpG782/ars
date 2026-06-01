/// Services Module Barrel Export
///
/// Provides clean imports for the services feature following Clean Architecture.
/// Usage example:
///   import 'package:arsapplication/features/mechanic/services/services.dart';
library;

// Domain Layer Exports
export 'domain/repositories/booking_repository.dart';
export 'domain/repositories/service_history_repository.dart';

// Data Layer Exports
export 'data/repositories/openroute_booking_repository.dart';
export 'data/repositories/firebase_service_history_repository.dart';

// Presentation Layer Exports
export 'presentation/screens/booking_request.dart';
export 'presentation/screens/payment_confirmation_screen.dart';
export 'presentation/screens/service_history_screen.dart';
