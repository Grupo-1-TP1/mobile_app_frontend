import 'package:mobile_app_frontend/shared/domain/repositories/chatbot_repository.dart';
import 'package:mobile_app_frontend/shared/infrastructure/data_sources/chatbot_remote_data_source.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendMessage({
    required String message,
    required int userId,
    required String sessionId,
  }) async {
    final response = await remoteDataSource.sendMessage(
      message: message,
      userId: userId,
      sessionId: sessionId,
    );

    final content = response['content']?.toString().trim();

    if (content == null || content.isEmpty) {
      throw Exception('Chatbot response does not contain content');
    }

    return content;
  }
}