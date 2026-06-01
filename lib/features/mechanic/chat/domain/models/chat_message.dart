/// Domain Models for Chat Feature
///
/// Following Domain-Driven Design principles
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Message Type Enum
enum MessageType { text, image, document, location }

/// Chat Message Entity
///
/// Represents a single message in a chat conversation
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final bool isFromMechanic;
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;
  final String? thumbnailUrl;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.isFromMechanic,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.thumbnailUrl,
  });

  /// Factory constructor from Firestore data
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      chatRoomId: map['chatRoomId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      isFromMechanic: map['isFromMechanic'] as bool,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      mediaUrl: map['mediaUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'isFromMechanic': isFromMechanic,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  /// Create copy with updated fields
  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    bool? isFromMechanic,
    DateTime? timestamp,
    MessageStatus? status,
    String? mediaUrl,
    String? thumbnailUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      isFromMechanic: isFromMechanic ?? this.isFromMechanic,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

/// Message Status Enum
enum MessageStatus { sending, sent, delivered, read, failed }

/// Chat Room Value Object
///
/// Represents a chat conversation between mechanic and customer
class ChatRoom {
  final String id;
  final String serviceRequestId;
  final String mechanicId;
  final String mechanicName;
  final String customerId;
  final String customerName;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatRoom({
    required this.id,
    required this.serviceRequestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.customerId,
    required this.customerName,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String,
      serviceRequestId: map['serviceRequestId'] as String,
      mechanicId: map['mechanicId'] as String,
      mechanicName: map['mechanicName'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      lastMessage: map['lastMessage'] != null
          ? ChatMessage.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: map['unreadCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'customerId': customerId,
      'customerName': customerName,
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? serviceRequestId,
    String? mechanicId,
    String? mechanicName,
    String? customerId,
    String? customerName,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      mechanicId: mechanicId ?? this.mechanicId,
      mechanicName: mechanicName ?? this.mechanicName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
