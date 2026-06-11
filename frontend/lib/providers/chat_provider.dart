import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  late AiService _aiService;

  @override
  Future<List<ChatMessage>> build() async {
    _aiService = AiService();
    // Start with a greeting
    return [
      ChatMessage(
        text: 'Hello! I\'m here to support you. How are you feeling today?',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String userMessage) async {
    final newUserMessage = ChatMessage(
      text: userMessage,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final currentState = state.value ?? [];
    final updatedMessages = [...currentState, newUserMessage];
    state = AsyncValue.data(updatedMessages);

    try {
      final aiReply = await _aiService.chatWithAi(userMessage);
      final aiMessage = ChatMessage(
        text: aiReply,
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      final finalMessages = [...updatedMessages, aiMessage];
      state = AsyncValue.data(finalMessages);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I couldn\'t respond. Please try again.',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      );
      final errorMessages = [...updatedMessages, errorMessage];
      state = AsyncValue.data(errorMessages);
    }
  }

  void clearChat() {
    state = AsyncValue.data([
      ChatMessage(
        text: 'Hello! I\'m here to support you. How are you feeling today?',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
      ),
    ]);
  }
}

final chatProvider = AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);
