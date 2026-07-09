import '../core/network/api_client.dart';

class ChatbotApi {
  final ApiClient _apiClient;

  ChatbotApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Send a message to the AI coach
  Future<Map<String, dynamic>> sendMessage(String messageBody) async {
    final response = await _apiClient.post(
      '/coach/send',
      data: {'message': messageBody},
    );
    return response.data['data'];
  }

  /// Retrieve paginated coach history
  Future<Map<String, dynamic>> getHistory({int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      '/coach/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data['data'];
  }
}
