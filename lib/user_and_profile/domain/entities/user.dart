import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final List<String> roles;

  const User({
    required this.id,
    required this.username,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final roles = <String>[];
    if (rolesRaw is List) {
      roles.addAll(rolesRaw.map((e) => e.toString()));
    } else if (json['role'] != null) {
      roles.add(json['role'].toString());
    }

    final usernameRaw = json['username'] ?? json['email'] ?? json['userName'];
    final username = usernameRaw != null ? usernameRaw.toString() : '';

    return User(
      id: (json['id'] as num).toInt(),
      username: username,
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

  User copyWith({
    int? id,
    String? username,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [id, username, roles];
}