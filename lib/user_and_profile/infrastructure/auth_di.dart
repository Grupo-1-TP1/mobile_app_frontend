import 'package:mobile_app_frontend/user_and_profile/infrastructure/data_sources/user_local_data_source.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/repositories/user_repository_impl.dart';

class AuthDI {
  static final LocalUserDataSource localDataSource = LocalUserDataSource();

  static final UserRepositoryImpl userRepository = UserRepositoryImpl(
    localDataSource: localDataSource,
  );
}