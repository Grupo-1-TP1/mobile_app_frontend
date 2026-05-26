import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<User> logIn({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<User?> getCurrentUser();

  Future<User> updateProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  });

  Future<bool> recoverPassword(String email);
}
