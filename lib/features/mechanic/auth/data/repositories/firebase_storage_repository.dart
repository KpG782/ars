import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase Implementation of FileStorageRepository
///
/// Handles file upload/download operations using Firebase Storage.
class FirebaseStorageRepository implements FileStorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile({
    required String filePath,
    required String storagePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw const StorageException(
          message: 'File does not exist',
          code: StorageErrorCode.invalidFile,
        );
      }

      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get and return download URL
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Upload failed: ${e.message}',
        code: _mapStorageError(e.code),
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: StorageErrorCode.unknown,
      );
    }
  }

  @override
  Future<String> downloadFile({
    required String storagePath,
    required String localPath,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final file = File(localPath);

      await ref.writeToFile(file);

      return localPath;
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Download failed: ${e.message}',
        code: _mapStorageError(e.code),
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: StorageErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Delete failed: ${e.message}',
        code: _mapStorageError(e.code),
      );
    } catch (e) {
      throw StorageException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: StorageErrorCode.unknown,
      );
    }
  }

  @override
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
        message: 'Failed to get download URL: ${e.message}',
        code: _mapStorageError(e.code),
      );
    } catch (e) {
      throw StorageException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: StorageErrorCode.unknown,
      );
    }
  }

  /// Maps Firebase Storage error codes to app error codes
  StorageErrorCode _mapStorageError(String? code) {
    switch (code) {
      case 'object-not-found':
        return StorageErrorCode.objectNotFound;
      case 'unauthorized':
        return StorageErrorCode.unauthorized;
      case 'quota-exceeded':
        return StorageErrorCode.quotaExceeded;
      case 'unauthenticated':
        return StorageErrorCode.unauthorized;
      case 'bucket-not-found':
        return StorageErrorCode.bucketNotFound;
      case 'canceled':
        return StorageErrorCode.canceled;
      default:
        return StorageErrorCode.unknown;
    }
  }
}
