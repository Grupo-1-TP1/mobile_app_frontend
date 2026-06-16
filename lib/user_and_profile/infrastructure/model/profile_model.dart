import 'package:mobile_app_frontend/user_and_profile/domain/entities/profile.dart';

class ProfileModel {
  final int id;
  final String name;
  final int userId;
  final int savingPercentage;
  final bool allowMlAnalysis;
  final bool allowPushNotifications;
  final bool useBiometrics;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.savingPercentage,
    required this.allowMlAnalysis,
    required this.allowPushNotifications,
    required this.useBiometrics,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      userId: json['userId'] != null ? (json['userId'] as num).toInt() : 0,
      savingPercentage: json['saving_percentage'] != null
          ? (json['saving_percentage'] as num).toInt()
          : 0,
      allowMlAnalysis: json['allow_ml_analysis'] as bool? ?? true,
      allowPushNotifications: json['allow_push_notifications'] as bool? ?? true,
      useBiometrics: json['use_biometrics'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'saving_percentage': savingPercentage,
      'allow_ml_analysis': allowMlAnalysis,
      'allow_push_notifications': allowPushNotifications,
      'use_biometrics': useBiometrics,
    };
  }

  // Mapeo limpio hacia la Entidad de Dominio que consume tu pantalla
  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      userId: userId,
      savingPercentage: savingPercentage,
      allowMlAnalysis: allowMlAnalysis,
      allowPushNotifications: allowPushNotifications,
      useBiometrics: useBiometrics,
    );
  }

  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      userId: entity.userId,
      savingPercentage: entity.savingPercentage,
      allowMlAnalysis: entity.allowMlAnalysis,
      allowPushNotifications: entity.allowPushNotifications,
      useBiometrics: entity.useBiometrics,
    );
  }
}
