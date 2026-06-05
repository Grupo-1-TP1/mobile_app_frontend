import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app_frontend/shared/domain/entities/app_notification.dart';
import 'package:mobile_app_frontend/shared/infrastructure/data_sources/notifications_local_data_source.dart';

class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationsLocalDataSource _localDataSource =
      NotificationsLocalDataSource();

  final ValueNotifier<List<AppNotification>> notifications =
      ValueNotifier<List<AppNotification>>(<AppNotification>[]);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _loadStoredNotifications();

    if (!kIsWeb) {
      await _requestPermissions();
      await _initLocalNotifications();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleForegroundMessage);
    }

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kIsWeb) return;

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _initLocalNotifications() async {
  if (kIsWeb) return;

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

  await _localNotifications.initialize(initSettings);
}

  Future<void> _loadStoredNotifications() async {
    notifications.value = await _localDataSource.loadNotifications();
  }

  Future<void> subscribeToUserTopic(int userId) async {
  try {
    await _messaging.subscribeToTopic('user_$userId');
  } catch (error) {
    debugPrint('subscribeToUserTopic failed: $error');
  }
}

Future<void> unsubscribeFromUserTopic(int userId) async {
  try {
    await _messaging.unsubscribeFromTopic('user_$userId');
  } catch (error) {
    debugPrint('unsubscribeFromUserTopic failed: $error');
  }
}

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = AppNotification.fromRemoteMessage(message);

    final updated = <AppNotification>[notification, ...notifications.value];

    notifications.value = updated;
    await _localDataSource.saveNotifications(updated);

    await _showLocalNotification(notification);
  }

  Future<void> _showLocalNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts_channel',
      'Budget Alerts',
      channelDescription: 'Notificaciones de presupuesto',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.payload,
    );
  }

  Future<void> addManualNotification(AppNotification notification) async {
    final updated = <AppNotification>[notification, ...notifications.value];

    notifications.value = updated;
    await _localDataSource.saveNotifications(updated);
  }

  Future<void> clearAll() async {
    notifications.value = <AppNotification>[];
    await _localDataSource.clear();
  }
}
