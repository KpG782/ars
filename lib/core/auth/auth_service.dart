import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      if (result.user != null) {
        await _updateLastLogin(result.user!.uid);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create Firebase Auth account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(fullName);

      // Create user document in Firestore
      await _createUserDocument(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Send email verification
      await result.user?.sendEmailVerification();

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to create account. Please try again.';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create the users collection and document
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
      throw 'Failed to save user information. Please try again.';
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw error here as it's not critical
    }
  }

  // Update email verification status
  Future<void> updateEmailVerificationStatus(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isEmailVerified': true,
        'emailVerifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Error updating email verification status
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
