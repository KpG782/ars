import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

/// Example integration for Mechanic-side notifications
/// Add these calls at appropriate places in your mechanic flow
class MechanicNotificationIntegration {
  final NotificationService _notificationService = NotificationService();

  // ============================================================================
  // EXAMPLE 1: When new service request is available
  // ============================================================================
  /// Place this in mechanic dashboard when new request appears
  Future<void> onNewServiceRequest({
    required String serviceType,
    required String location,
    required double distance,
  }) async {
    await _notificationService.notifyNewServiceRequest(
      serviceType: serviceType,
      location: location,
      distance: distance,
    );

    // Example: In mechanic_dashboard.dart, listen to nearby requests:
    // FirebaseFirestore.instance
    //   .collection('serviceRequests')
    //   .where('status', isEqualTo: 'pending')
    //   .snapshots()
    //   .listen((snapshot) {
    //     for (var change in snapshot.docChanges) {
    //       if (change.type == DocumentChangeType.added) {
    //         final data = change.doc.data();
    //         final distance = calculateDistance(
    //           mechanicLocation,
    //           GeoPoint(data['latitude'], data['longitude']),
    //         );
    //
    //         if (distance < 10) { // Within 10km
    //           NotificationService().notifyNewServiceRequest(
    //             serviceType: data['serviceType'],
    //             location: data['address'],
    //             distance: distance,
    //           );
    //         }
    //       }
    //     }
    //   });
  }

  // ============================================================================
  // EXAMPLE 2: When emergency request is received
  // ============================================================================
  /// Place this for high-priority emergency requests
  Future<void> onEmergencyRequest({
    required String serviceType,
    required String location,
    required double distance,
  }) async {
    await _notificationService.notifyEmergencyRequest(
      serviceType: serviceType,
      location: location,
      distance: distance,
    );

    // Example: Check for emergency flag
    // if (data['isEmergency'] == true) {
    //   await NotificationService().notifyEmergencyRequest(
    //     serviceType: data['serviceType'],
    //     location: data['address'],
    //     distance: distance,
    //   );
    // }
  }

  // ============================================================================
  // EXAMPLE 3: When customer sends a message
  // ============================================================================
  /// Place this in chat screen when new message arrives
  Future<void> onNewMessage({
    required String customerName,
    required String message,
  }) async {
    await _notificationService.notifyNewMessage(
      customerName: customerName,
      message: message,
    );

    // Example: In mechanic_chat_screen.dart
    // StreamBuilder<QuerySnapshot>(
    //   stream: FirebaseFirestore.instance
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .orderBy('timestamp', descending: true)
    //     .snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final docs = snapshot.data!.docs;
    //       if (docs.isNotEmpty) {
    //         final latestMessage = docs.first.data() as Map<String, dynamic>;
    //         if (latestMessage['senderId'] != currentUserId) {
    //           NotificationService().notifyNewMessage(
    //             customerName: customerName,
    //             message: latestMessage['text'],
    //           );
    //         }
    //       }
    //     }
    //     return ListView(...);
    //   },
    // )
  }

  // ============================================================================
  // EXAMPLE 4: When payment is received
  // ============================================================================
  /// Place this after customer completes payment
  Future<void> onPaymentReceived({
    required double amount,
    required String serviceType,
  }) async {
    await _notificationService.notifyPaymentEarned(
      amount: amount,
      serviceType: serviceType,
    );

    // Example: In payment_confirmation_screen.dart
    // onPressed: () async {
    //   await processPayment();
    //   await NotificationService().notifyPaymentEarned(
    //     amount: totalEarnings,
    //     serviceType: service.serviceType,
    //   );
    //   Navigator.pushReplacementNamed(context, '/mechanic-dashboard');
    // }
  }

  // ============================================================================
  // EXAMPLE 5: When customer rates the service
  // ============================================================================
  /// Place this when rating is submitted
  Future<void> onRatingReceived({
    required String customerName,
    required double rating,
    String? review,
  }) async {
    await _notificationService.notifyNewRating(
      customerName: customerName,
      rating: rating,
      review: review,
    );

    // Example: Listen to service document updates
    // FirebaseFirestore.instance
    //   .collection('completedServices')
    //   .doc(serviceId)
    //   .snapshots()
    //   .listen((snapshot) {
    //     final data = snapshot.data();
    //     if (data?['rating'] != null && data?['rating'] > 0) {
    //       NotificationService().notifyNewRating(
    //         customerName: data?['customerName'] ?? 'Customer',
    //         rating: (data?['rating'] as num).toDouble(),
    //         review: data?['review'],
    //       );
    //     }
    //   });
  }

  // ============================================================================
  // EXAMPLE 6: When customer cancels service
  // ============================================================================
  /// Place this when cancellation is received
  Future<void> onServiceCancelled({
    required String customerName,
    required String reason,
  }) async {
    await _notificationService.notifyServiceCancelled(
      customerName: customerName,
      reason: reason,
    );

    // Example: Listen to service status changes
    // if (newStatus == 'cancelled') {
    //   await NotificationService().notifyServiceCancelled(
    //     customerName: serviceData['customerName'],
    //     reason: serviceData['cancellationReason'] ?? 'No reason provided',
    //   );
    // }
  }
}

/// Example: Initialize in mechanic dashboard
class ExampleMechanicDashboard extends StatefulWidget {
  const ExampleMechanicDashboard({super.key});

  @override
  State<ExampleMechanicDashboard> createState() =>
      _ExampleMechanicDashboardState();
}

class _ExampleMechanicDashboardState extends State<ExampleMechanicDashboard> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Subscribe to mechanic topic for broadcast notifications
    await _notificationService.subscribeToTopic('mechanics');

    // Subscribe to location-based topic (e.g., 'mechanics_manila')
    // await _notificationService.subscribeToTopic('mechanics_${userLocation}');

    _setupServiceRequestListener();
  }

  void _setupServiceRequestListener() {
    // Example: Listen to service requests in real-time
    // final mechanicLocation = getCurrentLocation();
    //
    // FirebaseFirestore.instance
    //   .collection('serviceRequests')
    //   .where('status', isEqualTo: 'pending')
    //   .snapshots()
    //   .listen((snapshot) {
    //     for (var change in snapshot.docChanges) {
    //       final data = change.doc.data();
    //
    //       if (change.type == DocumentChangeType.added) {
    //         final distance = calculateDistance(
    //           mechanicLocation,
    //           GeoPoint(data['latitude'], data['longitude']),
    //         );
    //
    //         if (distance < 10) {
    //           if (data['isEmergency'] == true) {
    //             _notificationService.notifyEmergencyRequest(
    //               serviceType: data['serviceType'],
    //               location: data['address'],
    //               distance: distance,
    //             );
    //           } else {
    //             _notificationService.notifyNewServiceRequest(
    //               serviceType: data['serviceType'],
    //               location: data['address'],
    //               distance: distance,
    //             );
    //           }
    //         }
    //       }
    //     }
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Mechanic Dashboard')));
  }
}

/// Example: Add to service_request_card.dart
class ExampleServiceRequestCardIntegration {
  void handleAcceptRequest() async {
    // When mechanic accepts a request
    // await updateRequestStatus('accepted');

    // Optionally show local confirmation
    // _notificationService.notifyServiceAccepted(...); // This goes to customer
  }

  void handleDeclineRequest() async {
    // When mechanic declines
    // await updateRequestStatus('declined');
  }
}

/// Example: Add to mechanic_chat_screen.dart
class ExampleChatIntegration {
  void listenToNewMessages({
    required String chatId,
    required String currentUserId,
    required String customerName,
  }) {
    // Listen for new messages
    // FirebaseFirestore.instance
    //   .collection('chats')
    //   .doc(chatId)
    //   .collection('messages')
    //   .orderBy('timestamp', descending: true)
    //   .limit(1)
    //   .snapshots()
    //   .listen((snapshot) {
    //     if (snapshot.docs.isNotEmpty) {
    //       final message = snapshot.docs.first.data();
    //       if (message['senderId'] != currentUserId) {
    //         _notificationService.notifyNewMessage(
    //           customerName: customerName,
    //           message: message['text'],
    //         );
    //       }
    //     }
    //   });
  }
}

/// Example: Add to payment_confirmation_screen.dart
class ExamplePaymentIntegration {
  final NotificationService _notificationService = NotificationService();

  Future<void> handlePaymentConfirmation({
    required double amount,
    required String serviceType,
  }) async {
    // Process payment
    // await processPayment();

    // Notify mechanic
    await _notificationService.notifyPaymentEarned(
      amount: amount,
      serviceType: serviceType,
    );

    // Show success message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Payment of ₱${amount.toStringAsFixed(2)} confirmed')),
    // );
  }
}
