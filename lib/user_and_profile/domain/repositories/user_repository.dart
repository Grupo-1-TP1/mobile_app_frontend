import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> signUp({
    required String name,
    required String email,
    required String password
  });

  Future<User> logIn({
    required String username,
    required String password,
  });

  Future<void> logOut();

  Future<User?> getCurrentUser();

  Future<bool> recoverPassword(String email);
}
