import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_api.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final NotificationApi _api = NotificationApi();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _registerToken(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_registerToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background message tap
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

        // Check if app was opened from notification
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessageTap(initialMessage);
        }

        _initialized = true;
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'silah_notifications',
        'Silah Notifications',
        description: 'Notifications for messages, requests, and matches',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    try {
      final deviceType = Platform.isAndroid ? 'android' : 'ios';
      await _api.registerToken(
        fcmToken: token,
        deviceType: deviceType,
      );
    } catch (e) {
      print('Error registering token: $e');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'silah_notifications',
      'Silah Notifications',
      channelDescription: 'Notifications for messages, requests, and matches',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Navigate to relevant screen based on payload
  }

  /// Handle background message tap
  void _handleBackgroundMessageTap(RemoteMessage message) {
    // Handle notification tap when app is in background
    // Navigate to relevant screen based on message.data
  }

  /// Get unread notification counts
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await _api.getUnreadCounts();
      if (response['success'] == true) {
        final counts = response['counts'] as Map<String, dynamic>;
        return {
          'total': ((counts['notifications'] as int? ?? 0) +
              (counts['messages'] as int? ?? 0) +
              (counts['requests'] as int? ?? 0) +
              (counts['matches'] as int? ?? 0)),
          'messages': counts['messages'] as int? ?? 0,
          'requests': counts['requests'] as int? ?? 0,
          'matches': counts['matches'] as int? ?? 0,
          'notifications': counts['notifications'] as int? ?? 0,
        };
      }
      return {'total': 0, 'messages': 0, 'requests': 0, 'matches': 0, 'notifications': 0};
    } catch (e) {
      print('Error getting unread counts: $e');
      return {'total': 0, 'messages': 0, 'requests': 0, 'matches': 0, 'notifications': 0};
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Background message: ${message.messageId}');
}
