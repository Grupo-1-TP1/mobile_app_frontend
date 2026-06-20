import 'dart:convert';
import 'package:mobile_app_frontend/shared/domain/entities/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsLocalDataSource {
  // Ahora la clave base es dinámica por usuario
  String _getUserKey(int userId) => 'app_notifications_user_$userId';

  Future<List<AppNotification>> loadNotifications(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_getUserKey(userId)) ?? <String>[];

    return rawList
        .map((item) => AppNotification.fromJson(
              Map<String, dynamic>.from(jsonDecode(item) as Map),
            ))
        .toList();
  }

  Future<void> saveNotifications(int userId, List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = notifications.map((item) => jsonEncode(item.toJson())).toList(); // Asegura codificar como JSON string completo
    await prefs.setStringList(_getUserKey(userId), rawList);
  }

  Future<void> clear(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserKey(userId));
  }
}