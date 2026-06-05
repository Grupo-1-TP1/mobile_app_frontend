import 'dart:convert';

import 'package:mobile_app_frontend/shared/domain/entities/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsLocalDataSource {
  static const String _storageKey = 'app_notifications';

  Future<List<AppNotification>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];

    return rawList
        .map((item) => AppNotification.fromJson(
              Map<String, dynamic>.from(jsonDecode(item) as Map),
            ))
        .toList();
  }

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = notifications.map((item) => item.payload).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}