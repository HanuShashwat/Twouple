import 'dart:async';
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

class IncomingMessageEvent extends ChatEvent {
  final ChatMessageModel message;
  IncomingMessageEvent(this.message);
}

class InitSocketEvent extends ChatEvent {
  final String relationshipId;
  InitSocketEvent(this.relationshipId);
}

class DisposeSocketEvent extends ChatEvent {}

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
  StreamSubscription? _messageSubscription;
  bool _socketInitialized = false;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<IncomingMessageEvent>(_onIncomingMessage);
    on<InitSocketEvent>(_onInitSocket);
    on<DisposeSocketEvent>(_onDisposeSocket);
  }

  void _onLoadChatHistory(LoadChatHistoryEvent event, Emitter<ChatState> emit) async {
    if (event.page == 1) {
      emit(ChatLoading());
      _currentMessages.clear();
    }
    
    try {
      final response = await repository.getChatHistory(page: event.page);
      _currentPage = response.currentPage;
      
      _currentMessages.addAll(response.messages);
      
      emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: response.currentPage >= response.totalPages));

      // Try to initialize socket if we have messages and know the relationship ID
      if (!_socketInitialized && response.messages.isNotEmpty) {
        add(InitSocketEvent(response.messages.first.relationshipId));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onInitSocket(InitSocketEvent event, Emitter<ChatState> emit) async {
    if (_socketInitialized) return;
    
    await repository.initSocket(event.relationshipId);
    _socketInitialized = true;

    _messageSubscription = repository.newMessageStream.listen((message) {
      add(IncomingMessageEvent(message));
    });
  }

  void _onIncomingMessage(IncomingMessageEvent event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Avoid duplicating messages if we already optimistically added it or we sent it
      // In a real app we'd compare senderId with our own userId or temp IDs
      final exists = _currentMessages.any((m) => m.id == event.message.id);
      if (!exists) {
        _currentMessages.insert(0, event.message);
        emit(ChatLoaded(List.from(_currentMessages), hasReachedMax: currentState.hasReachedMax));
      }
    }
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Optimistically add message
      final optimisticMsg = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        senderId: 'me', // placeholder
        relationshipId: _currentMessages.isNotEmpty ? _currentMessages.first.relationshipId : 'rel',
        messageBody: event.messageBody,
        isAi: false,
        createdAt: DateTime.now(),
      );
      
      _currentMessages.insert(0, optimisticMsg);
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

  void _onDisposeSocket(DisposeSocketEvent event, Emitter<ChatState> emit) {
    _messageSubscription?.cancel();
    repository.disposeSocket();
    _socketInitialized = false;
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    repository.disposeSocket();
    return super.close();
  }
}
