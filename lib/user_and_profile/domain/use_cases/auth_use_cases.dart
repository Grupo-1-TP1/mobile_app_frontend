import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/repositories/user_repository.dart';

class SignUpUseCase {
  final UserRepository repository;

  SignUpUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }
}

class LogInUseCase {
  final UserRepository repository;

  LogInUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await repository.logIn(email: email, password: password);
  }
}

class LogOutUseCase {
  final UserRepository repository;

  LogOutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logOut();
  }
}

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    return await repository.updateProfile(
      userId: userId,
      name: name,
      profileImageUrl: profileImageUrl,
    );
  }
}
