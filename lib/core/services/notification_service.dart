import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../routing/app_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background notification: ${message.messageId}');
}

/// Central notification service for managing push and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;
  String? _fcmToken;

  /// Initialize notification service - call once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for iOS
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      // Save token to Firestore
      await _saveFcmToken();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ Provisional notification permission granted');
    } else {
      debugPrint('❌ Notification permission denied');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📬 Notification tapped: ${response.payload}');
    _navigateForPayload(response.payload ?? '');
  }

  /// Save FCM token to Firestore
  Future<void> _saveFcmToken([String? token]) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final fcmToken = token ?? _fcmToken;
      if (fcmToken == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Failed to save FCM token: $e');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground notification: ${message.notification?.title}');

    // Show local notification when app is in foreground
    _showLocalNotification(
      title: message.notification?.title ?? 'ARS',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap when app is in background / terminated
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📬 Notification opened: ${message.notification?.title}');
    final payload =
        message.data['payload'] as String? ??
        message.data['type'] as String? ??
        '';
    _navigateForPayload(payload);
  }

  /// Navigate to the appropriate screen based on notification payload.
  /// Mechanic payloads → mechanic dashboard; customer payloads → customer booking.
  Future<void> _navigateForPayload(String payload) async {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    const mechanicPayloads = {
      'new_service_request',
      'emergency_request',
      'new_message',
      'payment_earned',
      'new_rating',
      'service_cancelled',
    };

    final route = mechanicPayloads.contains(payload)
        ? AppRoutes.mechanicDashboard
        : AppRoutes.customerBooking;

    try {
      GoRouter.of(context).go(route);
    } catch (_) {
      // Router not ready yet — ignore; user will navigate manually.
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.high,
    bool playSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'ars_channel',
      'ARS Notifications',
      channelDescription: 'Notifications for ARS application',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ============================================================================
  // CUSTOMER NOTIFICATIONS
  // ============================================================================

  /// 1. Service request accepted by mechanic
  Future<void> notifyServiceAccepted({
    required String mechanicName,
    required String serviceType,
  }) async {
    await _showLocalNotification(
      title: '✅ Service Accepted',
      body: '$mechanicName accepted your $serviceType request',
      payload: 'service_accepted',
    );
  }

  /// 2. Mechanic is on the way
  Future<void> notifyMechanicOnTheWay({
    required String mechanicName,
    required int etaMinutes,
  }) async {
    await _showLocalNotification(
      title: '🚗 Mechanic On The Way',
      body: '$mechanicName is heading to your location. ETA: $etaMinutes min',
      payload: 'mechanic_on_way',
    );
  }

  /// 3. Mechanic has arrived
  Future<void> notifyMechanicArrived({required String mechanicName}) async {
    await _showLocalNotification(
      title: '📍 Mechanic Arrived',
      body: '$mechanicName has arrived at your location',
      payload: 'mechanic_arrived',
      playSound: true,
    );
  }

  /// 4. Service started
  Future<void> notifyServiceStarted({
    required String mechanicName,
    required String serviceType,
  }) async {
    await _showLocalNotification(
      title: '🔧 Service Started',
      body: '$mechanicName started working on your $serviceType',
      payload: 'service_started',
    );
  }

  /// 5. Service completed
  Future<void> notifyServiceCompleted({
    required String mechanicName,
    required double amount,
  }) async {
    await _showLocalNotification(
      title: '✅ Service Completed',
      body:
          '$mechanicName completed the service. Total: ₱${amount.toStringAsFixed(2)}',
      payload: 'service_completed',
    );
  }

  /// 6. Payment received confirmation
  Future<void> notifyPaymentReceived({required double amount}) async {
    await _showLocalNotification(
      title: '💰 Payment Confirmed',
      body: 'Payment of ₱${amount.toStringAsFixed(2)} has been processed',
      payload: 'payment_confirmed',
    );
  }

  /// 7. Emergency request status update
  Future<void> notifyEmergencyUpdate({required String message}) async {
    await _showLocalNotification(
      title: '🚨 Emergency Update',
      body: message,
      payload: 'emergency_update',
      priority: NotificationPriority.max,
    );
  }

  // ============================================================================
  // MECHANIC NOTIFICATIONS
  // ============================================================================

  /// 1. New service request nearby
  Future<void> notifyNewServiceRequest({
    required String serviceType,
    required String location,
    required double distance,
  }) async {
    await _showLocalNotification(
      title: '🔔 New Service Request',
      body:
          '$serviceType - ${distance.toStringAsFixed(1)} km away from $location',
      payload: 'new_service_request',
      playSound: true,
    );
  }

  /// 2. Emergency service request (high priority)
  Future<void> notifyEmergencyRequest({
    required String serviceType,
    required String location,
    required double distance,
  }) async {
    await _showLocalNotification(
      title: '🚨 EMERGENCY REQUEST',
      body:
          'URGENT: $serviceType needed - ${distance.toStringAsFixed(1)} km away',
      payload: 'emergency_request',
      priority: NotificationPriority.max,
      playSound: true,
    );
  }

  /// 3. Customer sent a message
  Future<void> notifyNewMessage({
    required String customerName,
    required String message,
  }) async {
    await _showLocalNotification(
      title: '💬 New Message',
      body:
          '$customerName: ${message.length > 50 ? '${message.substring(0, 50)}...' : message}',
      payload: 'new_message',
    );
  }

  /// 4. Payment received
  Future<void> notifyPaymentEarned({
    required double amount,
    required String serviceType,
  }) async {
    await _showLocalNotification(
      title: '💰 Payment Received',
      body: 'You earned ₱${amount.toStringAsFixed(2)} from $serviceType',
      payload: 'payment_earned',
    );
  }

  /// 5. Customer rated your service
  Future<void> notifyNewRating({
    required String customerName,
    required double rating,
    String? review,
  }) async {
    final reviewText = review != null && review.isNotEmpty
        ? ' - "$review"'
        : '';
    await _showLocalNotification(
      title: '⭐ New Rating',
      body:
          '$customerName rated you ${rating.toStringAsFixed(1)} stars$reviewText',
      payload: 'new_rating',
    );
  }

  /// 6. Service request cancelled by customer
  Future<void> notifyServiceCancelled({
    required String customerName,
    required String reason,
  }) async {
    await _showLocalNotification(
      title: '❌ Service Cancelled',
      body:
          '$customerName cancelled the request${reason.isNotEmpty ? ': $reason' : ''}',
      payload: 'service_cancelled',
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic (e.g., 'mechanics', 'customers')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}

enum NotificationPriority { low, medium, high, max }
