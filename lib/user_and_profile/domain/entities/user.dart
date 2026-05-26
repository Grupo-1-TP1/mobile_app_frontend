import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool hasCompletedSetup;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.hasCompletedSetup = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? hasCompletedSetup,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }

  @override
  List<Object?> get props => [id, email, name, profileImageUrl, createdAt, hasCompletedSetup];
}
