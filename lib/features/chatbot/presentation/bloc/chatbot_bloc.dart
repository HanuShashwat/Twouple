import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/chatbot_repository.dart';
import '../../../../models/chat_message_model.dart';

abstract class ChatbotEvent {}

class LoadChatbotHistoryEvent extends ChatbotEvent {
  final int page;
  LoadChatbotHistoryEvent({this.page = 1});
}

class SendChatbotMessageEvent extends ChatbotEvent {
  final String text;
  SendChatbotMessageEvent(this.text);
}

abstract class ChatbotState {}
class ChatbotInitial extends ChatbotState {}
class ChatbotLoading extends ChatbotState {}
class ChatbotLoaded extends ChatbotState {
  final List<ChatMessageModel> messages;
  ChatbotLoaded(this.messages);
}
class ChatbotError extends ChatbotState {
  final String error;
  ChatbotError(this.error);
}

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotRepository repository;
  final List<ChatMessageModel> _messages = [];

  ChatbotBloc(this.repository) : super(ChatbotInitial()) {
    on<LoadChatbotHistoryEvent>((event, emit) async {
      if (event.page == 1) emit(ChatbotLoading());
      try {
        final history = await repository.getHistory(page: event.page);
        _messages.addAll(history);
        emit(ChatbotLoaded(List.from(_messages)));
      } catch (e) {
        emit(ChatbotError(e.toString()));
      }
    });

    on<SendChatbotMessageEvent>((event, emit) async {
      try {
        // Optimistic UI for user message
        final userTempMsg = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          relationshipId: 'coach',
          senderId: 'me',
          messageBody: event.text,
          isAi: false,
          createdAt: DateTime.now(),
        );
        _messages.insert(0, userTempMsg);
        emit(ChatbotLoaded(List.from(_messages)));
        
        final aiResponseModel = await repository.sendMessage(event.text); // backend returns AI response
        
        // Add AI response to the list
        _messages.insert(0, aiResponseModel);
        emit(ChatbotLoaded(List.from(_messages)));
        
      } catch (e) {
        emit(ChatbotError(e.toString()));
      }
    });
  }
}
