/// Notification model for structured notification data
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.data,
    this.isRead = false,
    this.imageUrl,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Types of notifications in the app
enum NotificationType {
  // Customer notifications
  serviceAccepted,
  mechanicOnWay,
  mechanicArrived,
  serviceStarted,
  serviceCompleted,
  paymentConfirmed,
  emergencyUpdate,

  // Mechanic notifications
  newServiceRequest,
  emergencyRequest,
  newMessage,
  paymentEarned,
  newRating,
  serviceCancelled,

  // General
  general,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.serviceAccepted:
        return 'Service Accepted';
      case NotificationType.mechanicOnWay:
        return 'Mechanic On The Way';
      case NotificationType.mechanicArrived:
        return 'Mechanic Arrived';
      case NotificationType.serviceStarted:
        return 'Service Started';
      case NotificationType.serviceCompleted:
        return 'Service Completed';
      case NotificationType.paymentConfirmed:
        return 'Payment Confirmed';
      case NotificationType.emergencyUpdate:
        return 'Emergency Update';
      case NotificationType.newServiceRequest:
        return 'New Service Request';
      case NotificationType.emergencyRequest:
        return 'Emergency Request';
      case NotificationType.newMessage:
        return 'New Message';
      case NotificationType.paymentEarned:
        return 'Payment Earned';
      case NotificationType.newRating:
        return 'New Rating';
      case NotificationType.serviceCancelled:
        return 'Service Cancelled';
      case NotificationType.general:
        return 'Notification';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.serviceAccepted:
        return '✅';
      case NotificationType.mechanicOnWay:
        return '🚗';
      case NotificationType.mechanicArrived:
        return '📍';
      case NotificationType.serviceStarted:
        return '🔧';
      case NotificationType.serviceCompleted:
        return '✅';
      case NotificationType.paymentConfirmed:
        return '💰';
      case NotificationType.emergencyUpdate:
        return '🚨';
      case NotificationType.newServiceRequest:
        return '🔔';
      case NotificationType.emergencyRequest:
        return '🚨';
      case NotificationType.newMessage:
        return '💬';
      case NotificationType.paymentEarned:
        return '💰';
      case NotificationType.newRating:
        return '⭐';
      case NotificationType.serviceCancelled:
        return '❌';
      case NotificationType.general:
        return '🔔';
    }
  }

  bool get isHighPriority {
    return this == NotificationType.emergencyRequest ||
        this == NotificationType.emergencyUpdate ||
        this == NotificationType.mechanicArrived;
  }
}
