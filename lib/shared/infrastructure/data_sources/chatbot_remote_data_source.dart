import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotRemoteDataSource {
  final String baseUrl;
  final http.Client client;
  final String? Function()? getAuthToken;

  ChatbotRemoteDataSource({
    required this.baseUrl,
    this.getAuthToken,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required int userId,
    required String sessionId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/chatbot/send').replace(
      queryParameters: {
        'userId': userId.toString(),
        'sessionId': sessionId,
      },
    );

    final response = await client.post(
      uri,
      headers: _headers(),
      body: message,
    );

    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is String) {
      return {'content': decoded};
    }

    throw FormatException('Unexpected chatbot response format');
  }

  Map<String, String> _headers() {
    final token = getAuthToken?.call();

    return {
      'Content-Type': 'text/plain; charset=utf-8',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Chatbot request failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}