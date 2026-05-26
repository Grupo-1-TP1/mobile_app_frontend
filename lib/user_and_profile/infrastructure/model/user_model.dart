import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool hasCompletedSetup;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.hasCompletedSetup = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      hasCompletedSetup: json['has_completed_setup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'has_completed_setup': hasCompletedSetup,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      hasCompletedSetup: hasCompletedSetup,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      hasCompletedSetup: entity.hasCompletedSetup,
    );
  }
}
