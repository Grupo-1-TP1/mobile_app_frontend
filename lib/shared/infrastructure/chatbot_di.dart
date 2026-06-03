import 'package:mobile_app_frontend/shared/infrastructure/data_sources/chatbot_remote_data_source.dart';
import 'package:mobile_app_frontend/shared/infrastructure/repository/chatbot_repository_impl.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class ChatbotDI {
  static final remoteDataSource = ChatbotRemoteDataSource(
    baseUrl: 'https://finio-api.azurewebsites.net',
    getAuthToken: AuthDI.localDataSource.getAuthToken,
  );

  static final repository = ChatbotRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}