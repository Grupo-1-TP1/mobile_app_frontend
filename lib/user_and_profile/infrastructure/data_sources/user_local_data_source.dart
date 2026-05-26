import 'dart:convert';
import 'package:mobile_app_frontend/main.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/repositories/user_repository.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/model/user_model.dart';

class LocalUserDataSource {
  static const String _userKey = 'current_user';
  static const String _authTokenKey = 'auth_token';

  Future<User> saveUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await storageService.saveString(_userKey, jsonEncode(userModel.toJson()));
    return user;
  }

  Future<User?> getUser() async {
    final userJson = storageService.getString(_userKey);
    if (userJson == null) return null;
    try {
      final userModel = UserModel.fromJson(jsonDecode(userJson));
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await storageService.remove(_userKey);
    await storageService.remove(_authTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    await storageService.saveString(_authTokenKey, token);
  }

  String? getAuthToken() {
    return storageService.getString(_authTokenKey);
  }
}

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: DateTime.now(),
        hasCompletedSetup: false,
      );

      await localDataSource.saveUser(user);
      await localDataSource.saveAuthToken('token_${user.id}');
      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<User> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final existingUser = await localDataSource.getUser();
      if (existingUser != null && existingUser.email == email) {
        await localDataSource.saveAuthToken('token_${existingUser.id}');
        return existingUser;
      }
      throw Exception('Invalid credentials');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logOut() async {
    await localDataSource.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      var user = await localDataSource.getUser();
      if (user == null) throw Exception('User not found');

      user = user.copyWith(
        name: name ?? user.name,
        profileImageUrl: profileImageUrl ?? user.profileImageUrl,
      );

      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  @override
  Future<bool> recoverPassword(String email) async {
    // Placeholder for password recovery
    return true;
  }
}
