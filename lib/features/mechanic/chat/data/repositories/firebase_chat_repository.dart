import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Firebase Implementation of ChatRepository
///
/// Handles Firestore operations for chat messages
class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  static const String _chatRoomsCollection = 'chat_rooms';
  static const String _messagesSubcollection = 'messages';
  final _uuid = const Uuid();

  FirebaseChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    required bool isFromMechanic,
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = ChatMessage(
        id: messageId,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: MessageType.text,
        isFromMechanic: isFromMechanic,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Save message to subcollection
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesSubcollection)
          .doc(messageId)
          .set(message.toMap());

      // Update chat room's last message
      await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
        'lastMessage': message.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return message;
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to send message: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<ChatMessage> sendMediaMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String filePath,
    required MessageType type,
    required bool isFromMechanic,
    String? caption,
  }) async {
    try {
      final messageId = _uuid.v4();

      // Note: Actual media upload would be handled by ChatMediaRepository
      // This just creates the message record
      final message = ChatMessage(
        id: messageId,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        content: caption ?? '',
        type: type,
        isFromMechanic: isFromMechanic,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        mediaUrl:
            filePath, // Placeholder - should be replaced with uploaded URL
      );

      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesSubcollection)
          .doc(messageId)
          .set(message.toMap());

      await _firestore.collection(_chatRoomsCollection).doc(chatRoomId).update({
        'lastMessage': message.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return message;
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to send media message: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    try {
      return _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesSubcollection)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatMessage.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      throw ChatException(
        message: 'Failed to get messages: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> markAsRead({
    required String chatRoomId,
    required List<String> messageIds,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final docRef = _firestore
            .collection(_chatRoomsCollection)
            .doc(chatRoomId)
            .collection(_messagesSubcollection)
            .doc(messageId);

        batch.update(docRef, {
          'status': MessageStatus.read.toString().split('.').last,
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to mark messages as read: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesSubcollection)
          .doc(messageId)
          .delete();
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to delete message: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<ChatRoom> getOrCreateChatRoom({
    required String serviceRequestId,
    required String mechanicId,
    required String mechanicName,
    required String customerId,
    required String customerName,
  }) async {
    try {
      // Check if chat room already exists for this service request
      final querySnapshot = await _firestore
          .collection(_chatRoomsCollection)
          .where('serviceRequestId', isEqualTo: serviceRequestId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ChatRoom.fromMap(querySnapshot.docs.first.data());
      }

      // Create new chat room
      final chatRoomId = _uuid.v4();
      final chatRoom = ChatRoom(
        id: chatRoomId,
        serviceRequestId: serviceRequestId,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
        customerId: customerId,
        customerName: customerName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .set(chatRoom.toMap());

      return chatRoom;
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to get or create chat room: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      final doc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .get();

      if (!doc.exists) return null;

      return ChatRoom.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw ChatException(
        message: 'Failed to get chat room: ${e.message}',
        code: _mapFirestoreError(e.code),
      );
    } catch (e) {
      throw ChatException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  @override
  Stream<List<ChatRoom>> getChatRooms(String userId) {
    try {
      return _firestore
          .collection(_chatRoomsCollection)
          .where('mechanicId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ChatRoom.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      throw ChatException(
        message: 'Failed to get chat rooms: ${e.toString()}',
        code: ChatErrorCode.unknown,
      );
    }
  }

  /// Maps Firestore error codes to app error codes
  ChatErrorCode _mapFirestoreError(String code) {
    switch (code) {
      case 'not-found':
        return ChatErrorCode.notFound;
      case 'permission-denied':
        return ChatErrorCode.permissionDenied;
      case 'unavailable':
        return ChatErrorCode.networkError;
      default:
        return ChatErrorCode.unknown;
    }
  }
}
