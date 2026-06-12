import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/chat_bloc.dart';
import '../../data/chat_repository.dart';

class NativeChatPage extends StatelessWidget {
  const NativeChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(ChatRepository())..add(LoadChatHistoryEvent()),
      child: const NativeChatView(),
    );
  }
}

class NativeChatView extends StatefulWidget {
  const NativeChatView({super.key});

  @override
  State<NativeChatView> createState() => _NativeChatViewState();
}

class _NativeChatViewState extends State<NativeChatView> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(BuildContext context) {
    if (_controller.text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(_controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatError) {
                  return Center(child: Text(state.error));
                } else if (state is ChatLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true, // Show newest at bottom usually, but wait, if it's reverse, then we insert at 0.
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == 'me'; // Modify depending on your actual logic

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.secondary.withValues(alpha: 0.8) : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.messageBody),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
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
                    decoration: const InputDecoration(hintText: 'Message'),
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.secondary),
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

