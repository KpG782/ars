import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../domain/repositories/chat_repository.dart';

/// Firebase Implementation of ChatMediaRepository
///
/// Handles Firebase Storage operations for chat media files
class FirebaseChatMediaRepository implements ChatMediaRepository {
  final FirebaseStorage _storage;
  static const int _maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int _maxDocumentSize = 20 * 1024 * 1024; // 20MB

  FirebaseChatMediaRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<MediaUploadResult> uploadImage({
    required String filePath,
    required String chatRoomId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);

      // Validate file exists
      if (!await file.exists()) {
        throw const ChatException(
          message: 'File does not exist',
          code: ChatErrorCode.invalidFile,
        );
      }

      // Validate file size
      final fileSize = await file.length();
      if (fileSize > _maxImageSize) {
        throw const ChatException(
          message: 'Image size exceeds 10MB limit',
          code: ChatErrorCode.fileTooLarge,
        );
      }

      // Validate file extension
      final extension = path.extension(filePath).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
        throw const ChatException(
          message: 'Unsupported image format. Use JPG, PNG, GIF, or WebP',
          code: ChatErrorCode.unsupportedFormat,
        );
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.basename(filePath)}';
      final storagePath = 'chat_media/$chatRoomId/images/$fileName';
      final ref = _storage.ref().child(storagePath);

      // Upload file
      final uploadTask = ref.putFile(file);

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return MediaUploadResult(
        url: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Upload failed: ${e.message}',
        code: ChatErrorCode.uploadFailed,
      );
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<MediaUploadResult> uploadDocument({
    required String filePath,
    required String chatRoomId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw const ChatException(
          message: 'File does not exist',
          code: ChatErrorCode.invalidFile,
        );
      }

      final fileSize = await file.length();
      if (fileSize > _maxDocumentSize) {
        throw const ChatException(
          message: 'Document size exceeds 20MB limit',
          code: ChatErrorCode.fileTooLarge,
        );
      }

      final extension = path.extension(filePath).toLowerCase();
      if (![
        '.pdf',
        '.doc',
        '.docx',
        '.txt',
        '.xls',
        '.xlsx',
      ].contains(extension)) {
        throw const ChatException(
          message: 'Unsupported document format',
          code: ChatErrorCode.unsupportedFormat,
        );
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.basename(filePath)}';
      final storagePath = 'chat_media/$chatRoomId/documents/$fileName';
      final ref = _storage.ref().child(storagePath);

      final uploadTask = ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return MediaUploadResult(
        url: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Upload failed: ${e.message}',
        code: ChatErrorCode.uploadFailed,
      );
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> deleteMedia(String mediaUrl) async {
    try {
      final ref = _storage.refFromURL(mediaUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to delete media: ${e.message}',
        code: ChatErrorCode.unknown,
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }
}
