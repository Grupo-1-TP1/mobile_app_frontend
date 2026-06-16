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
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ??
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
      throw Exception('Sign up failed: ${response.statusCode} ${response.body}');
    }

    // After sign-up, sign-in to obtain token & canonical user data
    return logIn(username: email, password: password);
  }

  @override
  Future<User> logIn({
    required String username,
    required String password,
  }) async {
    final payload = {
      'email': username.trim(),
      'password': password,
    };

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

    final Map<String, dynamic> data = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
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
    // 🔑 Recuperamos el token de Azure almacenado localmente en la sesión activa
    final token = localDataSource.getAuthToken();

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/profiles/user/$userId'),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load profile from Azure: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    // Manejo seguro de la respuesta por si viene envuelta en un nodo "data"
    final Map<String, dynamic> data = (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
        ? decoded['data'] as Map<String, dynamic>
        : (decoded as Map<String, dynamic>);

    final profileModel = ProfileModel.fromJson(data);
    return profileModel.toEntity();
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    final token = localDataSource.getAuthToken();
    final profileModel = ProfileModel.fromEntity(profile);

    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/profiles/${profile.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileModel.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update profile in Azure: ${response.statusCode} ${response.body}');
    }
  }
}