import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';

class CoachHistoryResponse {
  final int totalMessages;
  final int totalPages;
  final int currentPage;
  final List<ChatMessageModel> messages;

  CoachHistoryResponse({
    required this.totalMessages,
    required this.totalPages,
    required this.currentPage,
    required this.messages,
  });

  factory CoachHistoryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['messages'] as List? ?? [];
    List<ChatMessageModel> messagesList =
        list.map((i) => ChatMessageModel.fromJson(i)).toList();

    return CoachHistoryResponse(
      totalMessages: json['total_messages'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      messages: messagesList,
    );
  }
}

class CoachApi {
  final ApiClient _apiClient;

  CoachApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Send a message to Aura (AI coach) and get a response
  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await _apiClient.post(
      '/coach/send',
      data: {'message': message},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Retrieve paginated coach conversation history
  Future<CoachHistoryResponse> getHistory({int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      '/coach/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return CoachHistoryResponse.fromJson(response.data['data']);
  }
}
