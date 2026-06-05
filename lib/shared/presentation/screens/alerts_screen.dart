import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/shared/domain/entities/app_notification.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  Color _colorForNotification(AppNotification notification) {
    final text = '${notification.title} ${notification.body}'.toLowerCase();

    if (text.contains('exced') || text.contains('superado')) {
      return Colors.red;
    }

    if (text.contains('80%') || text.contains('advert') || text.contains('alert')) {
      return Colors.orange;
    }

    return AppTheme.primaryGreen;
  }

  IconData _iconForNotification(AppNotification notification) {
    final text = '${notification.title} ${notification.body}'.toLowerCase();

    if (text.contains('exced') || text.contains('superado')) {
      return Icons.warning;
    }

    if (text.contains('advert') || text.contains('80%')) {
      return Icons.info;
    }

    return Icons.check_circle;
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Alertas', style: TextStyle(color: AppTheme.textPrimary)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => PushNotificationsService.instance.clearAll(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: PushNotificationsService.instance.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No tienes alertas todavía',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final color = _colorForNotification(notification);
              final icon = _iconForNotification(notification);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatTime(notification.receivedAt),
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}