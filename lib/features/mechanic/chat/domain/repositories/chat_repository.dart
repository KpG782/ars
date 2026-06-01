/// Chat Repository Interfaces
///
/// Following Dependency Inversion Principle (SOLID)
library;

import '../models/chat_message.dart';

/// Chat Repository Interface
///
/// Defines contract for chat operations
abstract class ChatRepository {
  /// Send a text message
  /// Throws [ChatException] on failure
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    required bool isFromMechanic,
  });

  /// Send a message with media (image/document)
  /// Throws [ChatException] on failure
  Future<ChatMessage> sendMediaMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String filePath,
    required MessageType type,
    required bool isFromMechanic,
    String? caption,
  });

  /// Get messages for a chat room as stream
  /// Returns stream of messages ordered by timestamp
  Stream<List<ChatMessage>> getMessages(String chatRoomId);

  /// Mark messages as read
  /// Throws [ChatException] on failure
  Future<void> markAsRead({
    required String chatRoomId,
    required List<String> messageIds,
  });

  /// Delete a message
  /// Throws [ChatException] on failure
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  });

  /// Get or create chat room for a service request
  /// Throws [ChatException] on failure
  Future<ChatRoom> getOrCreateChatRoom({
    required String serviceRequestId,
    required String mechanicId,
    required String mechanicName,
    required String customerId,
    required String customerName,
  });

  /// Get chat room by ID
  /// Returns null if not found
  Future<ChatRoom?> getChatRoom(String chatRoomId);

  /// Get all chat rooms for a user
  Stream<List<ChatRoom>> getChatRooms(String userId);
}

/// Media Upload Repository Interface
///
/// Defines contract for uploading chat media
abstract class ChatMediaRepository {
  /// Upload image and return URL
  /// [onProgress] callback receives upload progress (0.0 to 1.0)
  /// Throws [ChatException] on failure
  Future<MediaUploadResult> uploadImage({
    required String filePath,
    required String chatRoomId,
    void Function(double progress)? onProgress,
  });

  /// Upload document and return URL
  /// Throws [ChatException] on failure
  Future<MediaUploadResult> uploadDocument({
    required String filePath,
    required String chatRoomId,
    void Function(double progress)? onProgress,
  });

  /// Delete media file
  /// Throws [ChatException] on failure
  Future<void> deleteMedia(String mediaUrl);
}

/// Media Upload Result Value Object
class MediaUploadResult {
  final String url;
  final String? thumbnailUrl;
  final String fileName;
  final int fileSize;

  const MediaUploadResult({
    required this.url,
    this.thumbnailUrl,
    required this.fileName,
    required this.fileSize,
  });
}

// =============================================================================
// Custom Exceptions
// =============================================================================

/// Chat Exception
///
/// Thrown when chat operations fail
class ChatException implements Exception {
  final String message;
  final ChatErrorCode code;

  const ChatException({required this.message, required this.code});

  @override
  String toString() => 'ChatException: $message (code: $code)';
}

/// Chat Error Codes
enum ChatErrorCode {
  notFound,
  permissionDenied,
  networkError,
  uploadFailed,
  invalidFile,
  fileTooLarge,
  unsupportedFormat,
  unknown,
}
