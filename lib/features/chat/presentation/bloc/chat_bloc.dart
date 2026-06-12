import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/chat_repository.dart';
import '../../../../models/chat_message_model.dart';

// Events
abstract class ChatEvent {}

class LoadChatHistoryEvent extends ChatEvent {
  final int page;
  LoadChatHistoryEvent({this.page = 1});
}

class SendMessageEvent extends ChatEvent {
  final String messageBody;
  SendMessageEvent(this.messageBody);
}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool hasReachedMax;
  
  ChatLoaded(this.messages, {this.hasReachedMax = false});
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  int _currentPage = 1;
  List<ChatMessageModel> _currentMessages = [];

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
  }

  void _onLoadChatHistory(LoadChatHistoryEvent event, Emitter<ChatState> emit) async {
    if (event.page == 1) {
      emit(ChatLoading());
      _currentMessages.clear();
    }
    
    try {
      final response = await repository.getChatHistory(page: event.page);
      _currentPage = response.currentPage;
      
      // The API might return messages in desc order, we might need to sort them.
      // But let's just append for now
      _currentMessages.addAll(response.messages);
      
      emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: response.currentPage >= response.totalPages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Optimistically add message
      final optimisticMsg = ChatMessageModel(
        id: DateTime.now().toString(),
        senderId: 'me', // placeholder
        relationshipId: 'rel',
        messageBody: event.messageBody,
        isAi: false,
        createdAt: DateTime.now(),
      );
      
      _currentMessages.insert(0, optimisticMsg); // assuming list is built reversed or we append
      emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: currentState.hasReachedMax));
      
      try {
        final realMsg = await repository.sendMessage(event.messageBody);
        // Replace optimistic with real
        final index = _currentMessages.indexWhere((m) => m.id == optimisticMsg.id);
        if (index != -1) {
          _currentMessages[index] = realMsg;
        }
        emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: currentState.hasReachedMax));
      } catch (e) {
        // Remove optimistic message on failure
        _currentMessages.removeWhere((m) => m.id == optimisticMsg.id);
        emit(ChatError('Failed to send message'));
        emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: currentState.hasReachedMax));
      }
    }
  }
}
