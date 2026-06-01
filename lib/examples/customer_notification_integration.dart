import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

/// Example integration for Customer-side notifications
/// Add these calls at appropriate places in your customer flow
class CustomerNotificationIntegration {
  final NotificationService _notificationService = NotificationService();

  // ============================================================================
  // EXAMPLE 1: When mechanic accepts service request
  // ============================================================================
  /// Place this in your booking screen when you receive mechanic acceptance
  Future<void> onMechanicAccepted({
    required String mechanicName,
    required String serviceType,
  }) async {
    // Show notification to customer
    await _notificationService.notifyServiceAccepted(
      mechanicName: mechanicName,
      serviceType: serviceType,
    );

    // Example: In your booking.dart, add after mechanic acceptance:
    // if (response.status == 'accepted') {
    //   await NotificationService().notifyServiceAccepted(
    //     mechanicName: mechanicData['name'],
    //     serviceType: serviceRequest.serviceType,
    //   );
    // }
  }

  // ============================================================================
  // EXAMPLE 2: When mechanic starts traveling
  // ============================================================================
  /// Place this when mechanic status changes to 'on_the_way'
  Future<void> onMechanicOnTheWay({
    required String mechanicName,
    required int etaMinutes,
  }) async {
    await _notificationService.notifyMechanicOnTheWay(
      mechanicName: mechanicName,
      etaMinutes: etaMinutes,
    );

    // Example: Listen to mechanic location updates:
    // FirebaseFirestore.instance
    //   .collection('serviceRequests')
    //   .doc(requestId)
    //   .snapshots()
    //   .listen((snapshot) {
    //     if (snapshot.data()?['status'] == 'on_the_way') {
    //       NotificationService().notifyMechanicOnTheWay(
    //         mechanicName: snapshot.data()?['mechanicName'],
    //         etaMinutes: snapshot.data()?['eta'],
    //       );
    //     }
    //   });
  }

  // ============================================================================
  // EXAMPLE 3: When mechanic arrives at location
  // ============================================================================
  /// Place this when mechanic reaches customer location
  Future<void> onMechanicArrived({required String mechanicName}) async {
    await _notificationService.notifyMechanicArrived(
      mechanicName: mechanicName,
    );

    // Example: Check distance and notify when within 50 meters
    // if (distance < 0.05) { // 50 meters
    //   await NotificationService().notifyMechanicArrived(
    //     mechanicName: mechanicData['name'],
    //   );
    // }
  }

  // ============================================================================
  // EXAMPLE 4: When service starts
  // ============================================================================
  /// Place this when mechanic starts working
  Future<void> onServiceStarted({
    required String mechanicName,
    required String serviceType,
  }) async {
    await _notificationService.notifyServiceStarted(
      mechanicName: mechanicName,
      serviceType: serviceType,
    );

    // Example: Add button in your UI to start service
    // ElevatedButton(
    //   onPressed: () async {
    //     await updateServiceStatus('in_progress');
    //     await NotificationService().notifyServiceStarted(
    //       mechanicName: mechanicName,
    //       serviceType: serviceType,
    //     );
    //   },
    //   child: Text('Start Service'),
    // )
  }

  // ============================================================================
  // EXAMPLE 5: When service is completed
  // ============================================================================
  /// Place this when mechanic completes the service
  Future<void> onServiceCompleted({
    required String mechanicName,
    required double amount,
  }) async {
    await _notificationService.notifyServiceCompleted(
      mechanicName: mechanicName,
      amount: amount,
    );

    // Example: In completion screen
    // onPressed: () async {
    //   await updateServiceStatus('completed');
    //   await NotificationService().notifyServiceCompleted(
    //     mechanicName: service.mechanicName,
    //     amount: service.totalAmount,
    //   );
    //   Navigator.push(...); // Navigate to payment
    // }
  }

  // ============================================================================
  // EXAMPLE 6: When payment is confirmed
  // ============================================================================
  /// Place this after successful payment
  Future<void> onPaymentConfirmed({required double amount}) async {
    await _notificationService.notifyPaymentReceived(amount: amount);

    // Example: In payment confirmation screen
    // if (paymentStatus == 'success') {
    //   await NotificationService().notifyPaymentReceived(
    //     amount: paymentAmount,
    //   );
    // }
  }

  // ============================================================================
  // EXAMPLE 7: Emergency request updates
  // ============================================================================
  /// Place this for any emergency-related updates
  Future<void> onEmergencyUpdate({required String message}) async {
    await _notificationService.notifyEmergencyUpdate(message: message);

    // Example: When emergency status changes
    // if (isEmergency) {
    //   await NotificationService().notifyEmergencyUpdate(
    //     message: 'Multiple mechanics have been notified',
    //   );
    // }
  }
}

/// Example: Initialize in your customer dashboard
class ExampleCustomerDashboard extends StatefulWidget {
  const ExampleCustomerDashboard({super.key});

  @override
  State<ExampleCustomerDashboard> createState() =>
      _ExampleCustomerDashboardState();
}

class _ExampleCustomerDashboardState extends State<ExampleCustomerDashboard> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Example: Listen to service request updates from Firestore
    // FirebaseFirestore.instance
    //   .collection('serviceRequests')
    //   .where('customerId', isEqualTo: currentUserId)
    //   .snapshots()
    //   .listen((snapshot) {
    //     for (var change in snapshot.docChanges) {
    //       if (change.type == DocumentChangeType.modified) {
    //         final data = change.doc.data();
    //         handleServiceUpdate(data);
    //       }
    //     }
    //   });
  }

  void handleServiceUpdate(Map<String, dynamic>? data) {
    if (data == null) return;

    final status = data['status'] as String?;

    switch (status) {
      case 'accepted':
        _notificationService.notifyServiceAccepted(
          mechanicName: data['mechanicName'] ?? 'Mechanic',
          serviceType: data['serviceType'] ?? 'Service',
        );
        break;
      case 'on_the_way':
        _notificationService.notifyMechanicOnTheWay(
          mechanicName: data['mechanicName'] ?? 'Mechanic',
          etaMinutes: data['eta'] ?? 10,
        );
        break;
      case 'arrived':
        _notificationService.notifyMechanicArrived(
          mechanicName: data['mechanicName'] ?? 'Mechanic',
        );
        break;
      case 'in_progress':
        _notificationService.notifyServiceStarted(
          mechanicName: data['mechanicName'] ?? 'Mechanic',
          serviceType: data['serviceType'] ?? 'Service',
        );
        break;
      case 'completed':
        _notificationService.notifyServiceCompleted(
          mechanicName: data['mechanicName'] ?? 'Mechanic',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Customer Dashboard')));
  }
}
