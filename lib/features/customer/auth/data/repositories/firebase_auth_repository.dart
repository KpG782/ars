/// Data Layer: Firebase Implementation of AuthRepository
///
/// Provides Firebase implementation for authentication operations
library;

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Return basic user info (for full data, call getUserData)
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Get full user data from Firestore
      final userData = await getUserData(firebaseUser.uid);
      return userData;
    });
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw AuthException('Sign in failed', AuthErrorCode.unknown);
      }

      // Update last login time
      await _updateLastLogin(result.user!.uid);

      // Get user data from Firestore
      final user = await getUserData(result.user!.uid);
      if (user == null) {
        throw AuthException('User data not found', AuthErrorCode.userNotFound);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred',
        AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create Firebase Auth account
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw AuthException('Sign up failed', AuthErrorCode.unknown);
      }

      // Update display name
      await result.user!.updateDisplayName(fullName);

      // Create user document in Firestore
      await _createUserDocument(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Send email verification
      await result.user!.sendEmailVerification();

      // Get created user data
      final user = await getUserData(result.user!.uid);
      if (user == null) {
        throw AuthException(
          'Failed to retrieve user data',
          AuthErrorCode.unknown,
        );
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to create account', AuthErrorCode.unknown);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in', AuthErrorCode.userNotFound);
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException(
        'Failed to send verification email',
        AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      final refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateEmailVerificationStatus(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isEmailVerified': true,
        'emailVerifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AuthException(
        'Failed to update verification status',
        AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return _mapDocToUser(doc);
    } catch (e) {
      throw AuthException('Failed to fetch user data', AuthErrorCode.unknown);
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    String? address,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['fullName'] = fullName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (address != null) updates['address'] = address;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      throw AuthException('Failed to update profile', AuthErrorCode.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out', AuthErrorCode.unknown);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException(
        'Failed to send password reset email',
        AuthErrorCode.unknown,
      );
    }
  }

  // Helper: Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'userType': 'user',
        'isEmailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null,
        'address': null,
        'isActive': true,
      });
    } catch (e) {
      throw AuthException(
        'Failed to save user information',
        AuthErrorCode.unknown,
      );
    }
  }

  // Helper: Update last login time
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw error here as it's not critical
    }
  }

  // Helper: Map Firestore doc to User
  User _mapDocToUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: _parseUserType(data['userType']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt:
          (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      accountStatus: _parseAccountStatus(data['isActive']),
      emailVerifiedAt: (data['emailVerifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Helper: Parse user type string to enum
  UserType _parseUserType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mechanic':
        return UserType.mechanic;
      case 'user':
      case 'customer':
      default:
        return UserType.customer;
    }
  }

  // Helper: Parse account status
  AccountStatus _parseAccountStatus(bool? isActive) {
    if (isActive == null || isActive == true) {
      return AccountStatus.active;
    }
    return AccountStatus.inactive;
  }

  // Helper: Handle Firebase Auth exceptions
  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AuthException(
          'The password provided is too weak',
          AuthErrorCode.weakPassword,
        );
      case 'email-already-in-use':
        return AuthException(
          'The account already exists for that email',
          AuthErrorCode.emailAlreadyInUse,
        );
      case 'user-not-found':
        return AuthException(
          'No user found for that email',
          AuthErrorCode.userNotFound,
        );
      case 'wrong-password':
        return AuthException(
          'Wrong password provided',
          AuthErrorCode.wrongPassword,
        );
      case 'invalid-email':
        return AuthException(
          'The email address is not valid',
          AuthErrorCode.invalidEmail,
        );
      case 'user-disabled':
        return AuthException(
          'This user account has been disabled',
          AuthErrorCode.userDisabled,
        );
      case 'too-many-requests':
        return AuthException(
          'Too many requests. Try again later',
          AuthErrorCode.tooManyRequests,
        );
      case 'operation-not-allowed':
        return AuthException(
          'Signing in with Email and Password is not enabled',
          AuthErrorCode.operationNotAllowed,
        );
      case 'invalid-credential':
        return AuthException(
          'The email or password is incorrect',
          AuthErrorCode.invalidCredential,
        );
      default:
        return AuthException(
          e.message ?? 'An authentication error occurred',
          AuthErrorCode.unknown,
        );
    }
  }
}
