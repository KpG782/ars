/// Earnings Module Barrel Export
///
/// Provides clean imports for the earnings feature following Clean Architecture.
/// Usage example:
///   import 'package:arsapplication/features/mechanic/earnings/earnings.dart';
library;

// Domain Layer Exports
export 'domain/models/earnings.dart';
export 'domain/repositories/earnings_repository.dart';

// Data Layer Exports
export 'data/repositories/firebase_earnings_repository.dart';

// Presentation Layer Exports
export 'presentation/screens/earnings_screen.dart';
