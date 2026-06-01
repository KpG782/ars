/// Auth Module Exports
///
/// Centralized exports for the auth module following Clean Architecture.
/// Import this file instead of individual files for cleaner code.
library;

// Domain Layer
export 'domain/models/mechanic_user.dart';
export 'domain/repositories/auth_repository.dart';

// Data Layer
export 'data/repositories/firebase_auth_repository.dart';
export 'data/repositories/firebase_mechanic_data_repository.dart';
export 'data/repositories/firebase_storage_repository.dart';

// Presentation Layer
export 'presentation/utils/form_validators.dart';
export 'presentation/widgets/auth_widgets.dart';

/// Usage Example:
/// ```dart
/// import 'package:arsapplication/features/mechanic/auth/auth.dart';
///
/// // Now you have access to:
/// // - MechanicUser, BasicInfo, ProfessionalInfo
/// // - AuthRepository, MechanicDataRepository, FileStorageRepository
/// // - FirebaseAuthRepository, FirebaseMechanicDataRepository
/// // - FormValidators
/// // - CustomTextField, PrimaryButton, etc.
/// ```
