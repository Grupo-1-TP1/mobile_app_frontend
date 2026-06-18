import 'dart:convert';
import 'package:mobile_app_frontend/main.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class LocalUserDataSource {
  static const String _userKey = 'current_user';
  static const String _authTokenKey = 'auth_token';

  Future<User> saveUser(User user) async {
    await storageService.saveString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<User?> getUser() async {
    final userJson = storageService.getString(_userKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
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