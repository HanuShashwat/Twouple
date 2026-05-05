import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';

class ChatHistoryResponse {
  final int totalMessages;
  final int totalPages;
  final int currentPage;
  final List<ChatMessageModel> messages;

  ChatHistoryResponse({
    required this.totalMessages,
    required this.totalPages,
    required this.currentPage,
    required this.messages,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['messages'] as List? ?? [];
    List<ChatMessageModel> messagesList = list.map((i) => ChatMessageModel.fromJson(i)).toList();

    return ChatHistoryResponse(
      totalMessages: json['total_messages'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      messages: messagesList,
    );
  }
}

class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Send a message within the user's active relationship
  Future<ChatMessageModel> sendMessage(String messageBody) async {
    final response = await _apiClient.post(
      '/chat/send',
      data: {'message_body': messageBody},
    );
    return ChatMessageModel.fromJson(response.data['data']);
  }

  /// Retrieve paginated chat history for the active relationship
  Future<ChatHistoryResponse> getChatHistory({int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      '/chat/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return ChatHistoryResponse.fromJson(response.data['data']);
  }
}
