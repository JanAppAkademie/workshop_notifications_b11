import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.messageId}');
}

class FcmService {
  FcmService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('FCM Permission status: ${settings.authorizationStatus}');

    _fcmToken = await _messaging.getToken();
    log('FCM Token: $_fcmToken');

    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      log('FCM Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  Future<String?> getToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log('Foreground message: ${message.notification?.title}');
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    log('Notification tapped (background): ${message.data}');
  }

  void _handleInitialMessage(RemoteMessage message) {
    log('App opened from notification: ${message.data}');
  }
}
