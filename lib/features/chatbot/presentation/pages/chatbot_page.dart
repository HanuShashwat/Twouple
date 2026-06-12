import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../features/chat/data/chat_repository.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(ChatRepository()),
      child: const _ChatbotContent(),
    );
  }
}

class _ChatbotContent extends StatefulWidget {
  const _ChatbotContent();

  @override
  State<_ChatbotContent> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<_ChatbotContent> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [
    "Hello! I'm Twouple. How can I guide you today?"
  ];
  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _messages.add("You: ${_controller.text}");
      _isTyping = true;
    });

    context.read<ChatBloc>().add(SendMessageEvent(_controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) {
          if (state.messages.isNotEmpty) {
            final latestMsg = state.messages.first;
            if (latestMsg.senderId != 'me' && _isTyping) {
              setState(() {
                _isTyping = false;
                _messages.add("Twouple: ${latestMsg.messageBody}");
              });
            }
          }
        } else if (state is ChatError) {
          setState(() {
            _isTyping = false;
            _messages.add("Twouple: Error - ${state.error}");
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Twouple Guide')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUser = _messages[index].startsWith("You:");
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primary.withValues(alpha: 0.8) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_messages[index]),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Twouple is typing...', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Type your situation...'),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
