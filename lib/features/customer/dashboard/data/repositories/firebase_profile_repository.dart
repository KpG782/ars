/// Data Layer: Firebase Implementation of ProfileRepository
///
/// Handles user profile operations using Firebase Auth
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseProfileRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return _mapUserToProfile(user);
    } catch (e) {
      throw ProfileException(
        'Failed to get user profile: $e',
        ProfileErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ProfileException(
          'No user is currently signed in',
          ProfileErrorCode.notAuthenticated,
        );
      }

      await user.updateDisplayName(displayName);
      await user.reload();
    } catch (e) {
      throw ProfileException(
        'Failed to update display name: $e',
        ProfileErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ProfileException(
          'No user is currently signed in',
          ProfileErrorCode.notAuthenticated,
        );
      }

      // Note: Firebase Auth phone number update requires additional verification
      // For now, this is a placeholder - you may need to implement phone auth flow
      // or store phone number in Firestore instead

      throw ProfileException(
        'Phone number update not yet implemented - requires verification flow',
        ProfileErrorCode.updateFailed,
      );
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException(
        'Failed to update phone number: $e',
        ProfileErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ProfileException(
          'No user is currently signed in',
          ProfileErrorCode.notAuthenticated,
        );
      }

      await user.updatePhotoURL(photoUrl);
      await user.reload();
    } catch (e) {
      throw ProfileException(
        'Failed to update photo URL: $e',
        ProfileErrorCode.updateFailed,
      );
    }
  }

  @override
  Future<void> reloadUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ProfileException(
          'No user is currently signed in',
          ProfileErrorCode.notAuthenticated,
        );
      }

      await user.reload();
    } catch (e) {
      throw ProfileException(
        'Failed to reload user data: $e',
        ProfileErrorCode.reloadFailed,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ProfileException(
        'Failed to sign out: $e',
        ProfileErrorCode.signOutFailed,
      );
    }
  }

  /// Helper: Map Firebase User to UserProfile
  UserProfile _mapUserToProfile(User user) {
    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }
}
