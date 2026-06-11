import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(_messageController.text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Support Chat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: chatState.when(
        data: (messages) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _ChatBubble(message: message);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    (isUser
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onTertiaryContainer)
                        .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
