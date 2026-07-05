import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/chatbot_bloc.dart';
import '../../data/chatbot_repository.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatbotBloc(ChatbotRepository())..add(LoadChatbotHistoryEvent()),
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

  void _sendMessage(BuildContext context) {
    if (_controller.text.isEmpty) return;
    context.read<ChatbotBloc>().add(SendChatbotMessageEvent(_controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twouple Guide')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatbotBloc, ChatbotState>(
              builder: (context, state) {
                if (state is ChatbotLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatbotError) {
                  return Center(child: Text(state.error));
                } else if (state is ChatbotLoaded) {
                  final messages = state.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = !msg.isAi;
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary.withValues(alpha: 0.8) : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.messageBody),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start chatting with Aura!'));
              },
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
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

