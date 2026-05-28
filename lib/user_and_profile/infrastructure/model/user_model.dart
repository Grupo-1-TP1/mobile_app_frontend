import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class UserModel {
  final int id;
  final String username;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.username,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final roles = <String>[];
    if (rolesRaw is List) {
      roles.addAll(rolesRaw.map((e) => e.toString()));
    } else if (json['role'] != null) {
      roles.add(json['role'].toString());
    }
    return UserModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'roles': roles,
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      roles: roles,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      roles: entity.roles,
    );
  }
}