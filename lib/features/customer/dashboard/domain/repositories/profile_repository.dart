/// Domain Layer: Profile Repository Interface
///
/// Defines operations for managing user profile data
library;

import '../models/user_profile.dart';

abstract class ProfileRepository {
  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile();

  /// Update user display name
  Future<void> updateDisplayName(String displayName);

  /// Update user phone number (if supported by auth provider)
  Future<void> updatePhoneNumber(String phoneNumber);

  /// Update user photo URL
  Future<void> updatePhotoUrl(String photoUrl);

  /// Reload user data from server
  Future<void> reloadUserData();

  /// Sign out the current user
  Future<void> signOut();
}

/// Profile-specific exceptions
class ProfileException implements Exception {
  final String message;
  final ProfileErrorCode code;

  ProfileException(this.message, this.code);

  @override
  String toString() => 'ProfileException: $message (${code.name})';
}

enum ProfileErrorCode {
  notAuthenticated,
  updateFailed,
  reloadFailed,
  signOutFailed,
  unknown,
}
