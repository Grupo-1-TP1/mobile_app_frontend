abstract class ChatbotRepository {
  Future<String> sendMessage({
    required String message,
    required int userId,
    required String sessionId,
  });
}