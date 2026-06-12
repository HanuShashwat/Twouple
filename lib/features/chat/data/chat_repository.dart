import '../../../../api/chat_api.dart';
import '../../../../models/chat_message_model.dart';

class ChatRepository {
  final ChatApi _chatApi;

  ChatRepository({ChatApi? chatApi}) : _chatApi = chatApi ?? ChatApi();

  Future<ChatHistoryResponse> getChatHistory({int page = 1, int limit = 50}) async {
    return await _chatApi.getChatHistory(page: page, limit: limit);
  }

  Future<ChatMessageModel> sendMessage(String messageBody) async {
    return await _chatApi.sendMessage(messageBody);
  }
}
