/// Domain Layer: Auth Repository Interface
///
/// Defines contract for authentication operations
library;

import '../models/user.dart';

/// Repository for managing user authentication
abstract class AuthRepository {
  /// Get current authenticated user
  User? get currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  });

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Check if email is verified
  Future<bool> checkEmailVerified();

  /// Update email verification status
  Future<void> updateEmailVerificationStatus(String uid);

  /// Get user data by UID
  Future<User?> getUserData(String uid);

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
  });

  /// Sign out
  Future<void> signOut();

  /// Reset password
  Future<void> resetPassword(String email);
}

/// Auth-specific exceptions
class AuthException implements Exception {
  final String message;
  final AuthErrorCode code;

  AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException: $message (${code.name})';
}

/// Error codes for auth operations
enum AuthErrorCode {
  weakPassword,
  emailAlreadyInUse,
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  operationNotAllowed,
  invalidCredential,
  networkError,
  emailNotVerified,
  unknown,
}
