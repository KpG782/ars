import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/mechanic_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase Implementation of MechanicDataRepository
///
/// Handles Firestore operations for mechanic data.
/// Separates auth concerns from data concerns (SRP).
class FirebaseMechanicDataRepository implements MechanicDataRepository {
  final FirebaseFirestore _firestore;
  static const String _mechanicsCollection = 'mechanics';

  FirebaseMechanicDataRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveProfessionalDetails({
    required String uid,
    required ProfessionalInfo professionalInfo,
  }) async {
    try {
      await _firestore.collection(_mechanicsCollection).doc(uid).set({
        'professionalInfo': professionalInfo.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to save professional details: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<MechanicUser?> getMechanicByUid(String uid) async {
    try {
      final doc = await _firestore
          .collection(_mechanicsCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return MechanicUser.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to fetch mechanic data: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> updateVerificationStatus({
    required String uid,
    required VerificationStatus status,
  }) async {
    try {
      await _firestore.collection(_mechanicsCollection).doc(uid).set({
        'verificationStatus': status.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update verification status: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(_mechanicsCollection)
          .where('basicInfo.username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to check username availability: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> updateBasicInfo({
    required String uid,
    required BasicInfo basicInfo,
  }) async {
    try {
      await _firestore.collection(_mechanicsCollection).doc(uid).set({
        'basicInfo': basicInfo.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update basic info: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> updateProfessionalInfo({
    required String uid,
    required ProfessionalInfo professionalInfo,
  }) async {
    try {
      await _firestore.collection(_mechanicsCollection).doc(uid).set({
        'professionalInfo': professionalInfo.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update professional info: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<List<MechanicUser>> getAllMechanics() async {
    try {
      final snapshot = await _firestore
          .collection(_mechanicsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MechanicUser.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to get all mechanics: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  @override
  Future<List<MechanicUser>> getMechanicsByVerificationState(
    VerificationState state,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_mechanicsCollection)
          .where(
            'verificationStatus.state',
            isEqualTo: state.toString().split('.').last,
          )
          .get();

      return snapshot.docs
          .map((doc) => MechanicUser.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to get mechanics by verification state: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  // Helper method for updating profile (not part of interface, remove @override)
  Future<void> updateMechanicProfile({
    required String uid,
    BasicInfo? basicInfo,
    ProfessionalInfo? professionalInfo,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (basicInfo != null) {
        updates['basicInfo'] = basicInfo.toMap();
      }

      if (professionalInfo != null) {
        updates['professionalInfo'] = professionalInfo.toMap();
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_mechanicsCollection)
          .doc(uid)
          .set(updates, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to update profile: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  // Helper method that returns Stream (not part of interface, remove @override)
  Stream<List<MechanicUser>> getAllMechanicsStream() {
    try {
      return _firestore
          .collection(_mechanicsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MechanicUser.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      throw DataException(
        message: 'Failed to get mechanics: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  // Helper method for searching mechanics (not part of interface, remove @override)
  Future<List<MechanicUser>> searchMechanics({
    String? specialization,
    VerificationState? verificationState,
  }) async {
    try {
      Query query = _firestore.collection(_mechanicsCollection);

      if (specialization != null) {
        query = query.where(
          'professionalInfo.specializations',
          arrayContains: specialization,
        );
      }

      if (verificationState != null) {
        query = query.where(
          'verificationStatus.state',
          isEqualTo: verificationState.toString().split('.').last,
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => MechanicUser.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to search mechanics: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  /// Saves complete mechanic data (used during initial signup)
  Future<void> saveCompleteMechanicData(MechanicUser mechanicUser) async {
    try {
      await _firestore
          .collection(_mechanicsCollection)
          .doc(mechanicUser.uid)
          .set(mechanicUser.toMap());
    } on FirebaseException catch (e) {
      throw DataException(
        message: 'Failed to save mechanic data: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw DataException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: DataErrorCode.unknown,
      );
    }
  }

  /// Maps Firestore error codes to app error codes
  DataErrorCode _mapFirestoreError(String code) {
    switch (code) {
      case 'not-found':
        return DataErrorCode.notFound;
      case 'permission-denied':
        return DataErrorCode.permissionDenied;
      case 'already-exists':
        return DataErrorCode.alreadyExists;
      case 'unavailable':
        return DataErrorCode.networkError;
      default:
        return DataErrorCode.unknown;
    }
  }
}
