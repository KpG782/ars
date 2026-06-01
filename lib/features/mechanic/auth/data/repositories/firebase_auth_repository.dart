import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/mechanic_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase Implementation of AuthRepository
///
/// Implements the auth repository interface using Firebase Authentication.
/// Follows Dependency Inversion Principle - depends on abstractions, not concretions.
/// This implementation can be easily swapped with another auth provider.
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required BasicInfo basicInfo,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          message: 'Failed to create user account',
          code: AuthErrorCode.unknown,
        );
      }

      // Update display name
      await user.updateDisplayName(basicInfo.fullName);

      // Send email verification
      await user.sendEmailVerification();

      // Create mechanic user object with minimal info
      final mechanicUser = MechanicUser(
        uid: user.uid,
        basicInfo: basicInfo,
        professionalInfo: const ProfessionalInfo(
          businessName: '',
          licenseNumber: '',
          specializations: [],
          address: '',
        ),
        documentUrls: const DocumentUrls(),
        verificationStatus: const VerificationStatus(
          state: VerificationState.pending,
        ),
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('mechanics')
          .doc(user.uid)
          .set(mechanicUser.toMap());

      return user.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw AuthException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<MechanicUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          message: 'Sign in failed',
          code: AuthErrorCode.unknown,
        );
      }

      // Fetch mechanic data from Firestore
      final mechanicDoc = await _firestore
          .collection('mechanics')
          .doc(user.uid)
          .get();

      if (!mechanicDoc.exists) {
        throw const AuthException(
          message: 'Mechanic profile not found',
          code: AuthErrorCode.userNotFound,
        );
      }

      return MechanicUser.fromMap(mechanicDoc.data()!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Failed to sign out: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<MechanicUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final mechanicDoc = await _firestore
          .collection('mechanics')
          .doc(user.uid)
          .get();

      if (!mechanicDoc.exists) return null;

      return MechanicUser.fromMap(mechanicDoc.data()!);
    } catch (e) {
      throw AuthException(
        message: 'Failed to get current user: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to send password reset email: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  // Helper method for sending email verification (not part of interface)
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'No user signed in',
          code: AuthErrorCode.userNotFound,
        );
      }
      await user.sendEmailVerification();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to send verification email: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  // Helper method to check if email is verified (not part of interface)
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }

  // Helper method to update display name (not part of interface)
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'No user signed in',
          code: AuthErrorCode.userNotFound,
        );
      }
      await user.updateDisplayName(displayName);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to update display name: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'No user signed in',
          code: AuthErrorCode.userNotFound,
        );
      }

      // Delete Firestore data first
      await _firestore.collection('mechanics').doc(user.uid).delete();

      // Then delete auth account
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: _mapErrorCode(e.code),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to delete account: ${e.toString()}',
        code: AuthErrorCode.unknown,
      );
    }
  }

  /// Maps Firebase auth error codes to app error codes
  AuthErrorCode _mapErrorCode(String firebaseCode) {
    switch (firebaseCode) {
      case 'email-already-in-use':
        return AuthErrorCode.emailAlreadyInUse;
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'network-request-failed':
        return AuthErrorCode.networkError;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      case 'user-disabled':
        return AuthErrorCode.userDisabled;
      case 'operation-not-allowed':
        return AuthErrorCode.operationNotAllowed;
      default:
        return AuthErrorCode.unknown;
    }
  }

  /// Gets user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
