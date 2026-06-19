import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/user_and_profile/domain/entities/profile.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/repositories/user_repository.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/data_sources/user_local_data_source.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/model/profile_model.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/model/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource localDataSource;
  final http.Client client;
  final String baseUrl;

  static const String _signUpPath = '/api/v1/authentication/sign-up';
  static const String _signInPath = '/api/v1/authentication/sign-in';

  UserRepositoryImpl({
    required this.localDataSource,
    http.Client? client,
    String? baseUrl,
  }) : client = client ?? http.Client(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'https://finio-api.azurewebsites.net',
           );

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'roles': ['ROLE_USER'],
    };

    final response = await client.post(
      Uri.parse('$baseUrl$_signUpPath'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Sign up failed: ${response.statusCode} ${response.body}',
      );
    }

    // After sign-up, sign-in to obtain token & canonical user data
    return logIn(username: email, password: password);
  }

  @override
  Future<User> logIn({
    required String username,
    required String password,
  }) async {
    final payload = {'email': username.trim(), 'password': password};

    final response = await client.post(
      Uri.parse('$baseUrl$_signInPath'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Login failed: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    final Map<String, dynamic> data =
        (decoded is Map<String, dynamic> &&
            decoded['data'] is Map<String, dynamic>)
        ? decoded['data'] as Map<String, dynamic>
        : (decoded as Map<String, dynamic>);

    final userModel = UserModel.fromJson(data);
    final user = userModel.toEntity();

    final token = data['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await localDataSource.saveAuthToken(token);
    }

    await localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> logOut() async {
    await localDataSource.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    return localDataSource.getUser();
  }

  @override
  Future<bool> recoverPassword(String email) async {
    return true;
  }

  @override
  Future<Profile> getProfileByUserId(int userId) async {
    final token = localDataSource.getAuthToken();

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/profiles/user/$userId'),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load profile from Azure: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    final Map<String, dynamic> data =
        (decoded is Map<String, dynamic> &&
            decoded['data'] is Map<String, dynamic>)
        ? decoded['data'] as Map<String, dynamic>
        : (decoded as Map<String, dynamic>);

    final profileModel = ProfileModel.fromJson(data);
    return profileModel.toEntity();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final token = localDataSource.getAuthToken();

    final Map<String, dynamic> bodyJson = {
      "name": profile.name,
      "saving_percentage": profile.savingPercentage,
      "use_ml_analysis": profile.allowMlAnalysis,
      "allow_push_notifications": profile.allowPushNotifications,
      "use_biometrics": profile.useBiometrics,
    };

    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/profiles/user/${profile.userId}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyJson),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update profile in Azure: ${response.statusCode} ${response.body}',
      );
    }

    return profile;
  }

  @override
  Future<Profile> updateProfileName(int userId, String newName) async {
    final token = localDataSource.getAuthToken();

    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/profiles/change-name/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"name": newName}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update profile name in Azure: ${response.statusCode} ${response.body}',
      );
    }

    return await getProfileByUserId(userId);
  }

  @override
  Future<Profile> updateProfilePermissions(
    int userId, {
    bool? allowMlAnalysis,
    bool? allowPushNotifications,
    bool? useBiometrics,
  }) async {
    final token = localDataSource.getAuthToken();
    final currentProfile = await getProfileByUserId(userId);

    final nextMl = allowMlAnalysis ?? currentProfile.allowMlAnalysis;
    final nextPush =
        allowPushNotifications ?? currentProfile.allowPushNotifications;
    final nextBio = useBiometrics ?? currentProfile.useBiometrics;

    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/profiles/permissions/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "allow_ml_analysis": nextMl,
        "allow_push_notifications": nextPush,
        "use_biometrics": nextBio,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update profile permissions in Azure: ${response.statusCode} ${response.body}',
      );
    }

    return Profile(
      id: currentProfile.id,
      userId: currentProfile.userId,
      name: currentProfile.name,
      savingPercentage: currentProfile.savingPercentage,
      allowMlAnalysis: nextMl,
      allowPushNotifications: nextPush,
      useBiometrics: nextBio,
    );
  }

  @override
  Future<void> deleteAccount(int userId) async {
    final token = localDataSource.getAuthToken();

    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/users/$userId'),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to delete account in Azure: ${response.statusCode} ${response.body}',
      );
    }

    await logOut();
  }
}
