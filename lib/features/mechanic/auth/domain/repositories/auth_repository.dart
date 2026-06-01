// Repository Interfaces (Contracts)
//
// Following Dependency Inversion Principle (SOLID)
// Data layer will implement these interfaces

import '../models/mechanic_user.dart';

/// Authentication Repository Interface
///
/// Defines contract for authentication operations.
/// Implementation in data layer (e.g., FirebaseAuthRepository)
abstract class AuthRepository {
  /// Sign up a new mechanic with email and password
  /// Returns the user ID on success
  /// Throws [AuthException] on failure
  Future<String> signUp({
    required String email,
    required String password,
    required BasicInfo basicInfo,
  });

  /// Sign in an existing mechanic
  /// Returns [MechanicUser] on success
  /// Throws [AuthException] on failure
  Future<MechanicUser> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  /// Throws [AuthException] on failure
  Future<void> signOut();

  /// Get current authenticated user
  /// Returns null if no user is signed in
  Future<MechanicUser?> getCurrentUser();

  /// Send password reset email
  /// Throws [AuthException] on failure
  Future<void> sendPasswordResetEmail(String email);

  /// Delete current user account
  /// Throws [AuthException] on failure
  Future<void> deleteAccount();
}

/// Mechanic Data Repository Interface
///
/// Defines contract for mechanic data operations.
/// Implementation in data layer (e.g., FirebaseMechanicDataRepository)
abstract class MechanicDataRepository {
  /// Save professional details for a mechanic
  /// Throws [DataException] on failure
  Future<void> saveProfessionalDetails({
    required String uid,
    required ProfessionalInfo professionalInfo,
  });

  /// Get mechanic data by UID
  /// Returns null if mechanic not found
  /// Throws [DataException] on failure
  Future<MechanicUser?> getMechanicByUid(String uid);

  /// Update verification status
  /// Throws [DataException] on failure
  Future<void> updateVerificationStatus({
    required String uid,
    required VerificationStatus status,
  });

  /// Check if username is available
  /// Throws [DataException] on failure
  Future<bool> isUsernameAvailable(String username);

  /// Update basic info
  /// Throws [DataException] on failure
  Future<void> updateBasicInfo({
    required String uid,
    required BasicInfo basicInfo,
  });

  /// Update professional info
  /// Throws [DataException] on failure
  Future<void> updateProfessionalInfo({
    required String uid,
    required ProfessionalInfo professionalInfo,
  });

  /// Get all mechanics (admin function)
  /// Throws [DataException] on failure
  Future<List<MechanicUser>> getAllMechanics();

  /// Get mechanics by verification state
  /// Throws [DataException] on failure
  Future<List<MechanicUser>> getMechanicsByVerificationState(
    VerificationState state,
  );
}

/// File Storage Repository Interface
///
/// Defines contract for file storage operations.
/// Implementation in data layer (e.g., FirebaseStorageRepository)
abstract class FileStorageRepository {
  /// Upload a file and return its download URL
  /// [onProgress] callback receives upload progress (0.0 to 1.0)
  /// Throws [StorageException] on failure
  Future<String> uploadFile({
    required String filePath,
    required String storagePath,
    void Function(double progress)? onProgress,
  });

  /// Download a file from storage
  /// Returns the local file path
  /// Throws [StorageException] on failure
  Future<String> downloadFile({
    required String storagePath,
    required String localPath,
  });

  /// Delete a file from storage
  /// Throws [StorageException] on failure
  Future<void> deleteFile(String storagePath);

  /// Get download URL for a file
  /// Throws [StorageException] on failure
  Future<String> getDownloadUrl(String storagePath);
}

// =============================================================================
// Custom Exceptions
// =============================================================================

/// Authentication Exception
///
/// Thrown when authentication operations fail
class AuthException implements Exception {
  final String message;
  final AuthErrorCode code;

  const AuthException({required this.message, required this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Authentication Error Codes
enum AuthErrorCode {
  emailAlreadyInUse,
  invalidEmail,
  operationNotAllowed,
  weakPassword,
  userDisabled,
  userNotFound,
  wrongPassword,
  networkError,
  tooManyRequests,
  unknown,
}

/// Data Exception
///
/// Thrown when data operations fail
class DataException implements Exception {
  final String message;
  final DataErrorCode code;

  const DataException({required this.message, required this.code});

  @override
  String toString() => 'DataException: $message (code: $code)';
}

/// Data Error Codes
enum DataErrorCode {
  notFound,
  alreadyExists,
  permissionDenied,
  networkError,
  unknown,
}

/// Storage Exception
///
/// Thrown when storage operations fail
class StorageException implements Exception {
  final String message;
  final StorageErrorCode code;

  const StorageException({required this.message, required this.code});

  @override
  String toString() => 'StorageException: $message (code: $code)';
}

/// Storage Error Codes
enum StorageErrorCode {
  objectNotFound,
  bucketNotFound,
  unauthorized,
  canceled,
  unknown,
  invalidFile,
  fileNotFound,
  quotaExceeded,
}
