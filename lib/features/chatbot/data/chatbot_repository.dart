import '../../../../api/chatbot_api.dart';
import '../../../../models/chat_message_model.dart';

class ChatbotRepository {
  final ChatbotApi _api;

  ChatbotRepository({ChatbotApi? api}) : _api = api ?? ChatbotApi();

  Future<List<ChatMessageModel>> getHistory({int page = 1}) async {
    final response = await _api.getHistory(page: page);
    final messages = response['messages'] as List? ?? [];
    return messages.map((m) => ChatMessageModel.fromJson(m)).toList();
  }

  Future<ChatMessageModel> sendMessage(String text) async {
    final response = await _api.sendMessage(text);
    return ChatMessageModel.fromJson(response['message']); // backend returns userMessage and aiResponse
  }
}
