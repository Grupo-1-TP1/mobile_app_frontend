import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? topic;
  final DateTime receivedAt;
  final Map<String, dynamic> data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.data,
    this.topic,
  });

  factory AppNotification.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    return AppNotification(
      id: message.messageId ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: notification?.title ??
          data['title']?.toString() ??
          'Alerta de presupuesto',
      body: notification?.body ??
          data['body']?.toString() ??
          data['message']?.toString() ??
          '',
      topic: data['topic']?.toString() ?? data['userTopic']?.toString(),
      receivedAt: DateTime.now(),
      data: data,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      topic: json['topic']?.toString(),
      receivedAt: DateTime.tryParse(json['receivedAt']?.toString() ?? '') ??
          DateTime.now(),
      data: (json['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'topic': topic,
      'receivedAt': receivedAt.toIso8601String(),
      'data': data,
    };
  }

  String get payload => jsonEncode(toJson());

  @override
  List<Object?> get props => [id, title, body, topic, receivedAt, data];
}