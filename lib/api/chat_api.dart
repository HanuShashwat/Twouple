import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/network/api_client.dart';
import '../core/auth/token_manager.dart';
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

class ChatApi {
  final ApiClient _apiClient;
  IO.Socket? _socket;
  final _messageController = StreamController<ChatMessageModel>.broadcast();

  ChatApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Stream<ChatMessageModel> get newMessageStream => _messageController.stream;

  /// Initialize WebSocket connection for real-time chat
  Future<void> initSocket(String relationshipId) async {
    final token = await TokenManager.getToken();
    if (token == null) return;

    final socketUrl = ApiClient.baseUrl.replaceAll('/api/v1', '');
    
    _socket = IO.io(socketUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': 'Bearer $token'})
        .build());
        
    _socket?.onConnect((_) {
      print('Connected to chat socket');
      _socket?.emit('join_relationship', relationshipId);
    });
    
    _socket?.on('new_message', (data) {
      if (data != null) {
        _messageController.add(ChatMessageModel.fromJson(data));
      }
    });

    _socket?.onDisconnect((_) => print('Disconnected from chat socket'));
  }

  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

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
