import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
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
  int? _currentUserId; // Identificador del usuario autenticado actualmente

  Future<void> initialize() async {
    if (_initialized) return;

    // Nota: Ya no cargamos notificaciones globales aquí para evitar mezclar datos.
    // La carga se delega a loadUserNotifications una vez tengamos el ID del usuario.

    if (!kIsWeb) {
      await _requestPermissions();
      await _initLocalNotifications();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleForegroundMessage);
    }

    _initialized = true;
  }

  Future<void> loadUserNotifications(
    int userId,
    http.Client client,
    String baseUrl,
  ) async {
    _currentUserId = userId;

    final localNotes = await _localDataSource.loadNotifications(userId);
    notifications.value = localNotes;

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/notifications/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final remoteNotes = decodedList
            .map(
              (json) => AppNotification.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        notifications.value = remoteNotes;
        await _localDataSource.saveNotifications(userId, remoteNotes);
      }
    } catch (e) {
      debugPrint("⚠️ Falló la sincronización remota de alertas con Azure: $e");
    }
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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

  Future<void> subscribeToUserTopic(int userId) async {
    if (kIsWeb) return;
    _currentUserId = userId;
    await _messaging.subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserTopic(int userId) async {
    if (kIsWeb) return;
    await _messaging.unsubscribeFromTopic('user_$userId');
    _currentUserId = null;
    notifications.value = <AppNotification>[];
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = AppNotification.fromRemoteMessage(message);

    final updated = <AppNotification>[notification, ...notifications.value];
    notifications.value = updated;

    if (_currentUserId != null) {
      await _localDataSource.saveNotifications(_currentUserId!, updated);
    }

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

    if (_currentUserId != null) {
      await _localDataSource.saveNotifications(_currentUserId!, updated);
    }
  }

  Future<void> clearAll() async {
    if (_currentUserId != null) {
      await _localDataSource.clear(_currentUserId!);
    }
    notifications.value = <AppNotification>[];
  }
}
