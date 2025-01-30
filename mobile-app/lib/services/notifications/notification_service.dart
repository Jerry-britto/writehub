import 'package:client/main.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handle background messages when app is terminated/in background
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
  debugPrint("Payload: ${message.data}");
}

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  navigateScreen() async {
    String userRole = "/login";

    User? user = await Auth().getCurrentUser();
    if (user != null) {
      Map<String, dynamic> profileDetails = await Profile().getDetails(
        user.email.toString(),
      );
      userRole = "/${profileDetails["role"]}";
    }
    return userRole;
  }

  // Define Android notification channel
  final AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  // Handle notification tap - navigate to notifications screen
  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    // Navigate dynamically based on user role and screen index
    final navigationData = await navigateScreen();
    final screen = navigationData['screen'];

    navigatorKey.currentState?.pushNamed(screen);
  }

  // Initialize local notifications
  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings("@drawable/ic_launcher");
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final navigationData = await navigateScreen();
        navigatorKey.currentState?.pushNamed(
          navigationData['screen'],
          arguments: navigationData['screenIdx'],
        );
      },
    );

    final platform =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await platform?.createNotificationChannel(androidChannel);
  }

  // Initialize push notifications
  Future initPushNotifications() async {
    // Configure foreground notification presentation
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Handle various notification tap scenarios
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            icon: "@drawable/ic_launcher",
          ),
        ),
        payload:
            'notifications', // Add payload to handle local notification tap
      );
    });
  }

  // Main initialization method
  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final fCMToken = await _firebaseMessaging.getToken();
      User? user = await Auth().getCurrentUser();
      if (fCMToken != null && user != null) {
        debugPrint("FCM Token: $fCMToken");
        await Profile().saveFcmToken(user.email.toString());
      }

      // Initialize notifications
      await initPushNotifications();
      await initLocalNotifications();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }
}
