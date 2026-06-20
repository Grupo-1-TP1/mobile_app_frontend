import 'package:mobile_app_frontend/user_and_profile/domain/entities/profile.dart';
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

  Future<User?> getUserByEmail(String email);
  Future<User?> changePassword(String email, String newPassword);

  Future<void> requestCode(String email);
  Future<bool> verifyCode(String email, String code);

  Future<Profile> getProfileByUserId(int userId);
  Future<Profile> updateProfile(Profile profile);
  Future<Profile> updateProfileName(int userId, String newName);
  Future<Profile> updateProfileSavingPercentage(int userId, int percentage);
  Future<Profile> updateProfilePermissions(int userId, {
    bool? allowMlAnalysis,
    bool? allowPushNotifications,
    bool? useBiometrics,
  });
  Future<void> deleteAccount(int userId);
}
