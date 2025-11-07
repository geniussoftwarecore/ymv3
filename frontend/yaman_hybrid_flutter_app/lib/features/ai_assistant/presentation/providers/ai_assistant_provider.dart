import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/openai_service.dart';
import 'dart:convert';

// AI Message model
class AiMessage {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final bool isStreaming;

  AiMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: json['id'] ?? '',
        content: json['content'] ?? '',
        role: json['role'] ?? 'user',
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
      );
}

// AI Chat State
class AiChatState {
  final List<AiMessage> messages;
  final bool isLoading;
  final String? error;
  final String selectedMode; // 'general', 'diagnostic', 'maintenance', 'cost'

  AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedMode = 'general',
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    String? error,
    String? selectedMode,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedMode: selectedMode ?? this.selectedMode,
      );
}

// OpenAI Service Provider
final openAiServiceProvider = Provider<OpenAiService>((ref) {
  // Get API key from environment or secure storage
  const apiKey = 'sk-your-api-key-here'; // Replace with actual API key
  return OpenAiService(apiKey: apiKey);
});

// AI Chat State Notifier
class AiChatNotifier extends StateNotifier<AiChatState> {
  final OpenAiService openAiService;
  final Ref ref;

  AiChatNotifier({required this.openAiService, required this.ref})
      : super(AiChatState());

  /// Add a user message and get AI response
  Future<void> sendMessage(String userMessage) async {
    // Add user message
    final userMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      role: 'user',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      // Prepare conversation history
      final conversationHistory = state.messages
          .map((msg) => {
                'role': msg.role,
                'content': msg.content,
              })
          .toList();

      // Get AI response based on mode
      String response = '';

      switch (state.selectedMode) {
        case 'diagnostic':
          response = await openAiService.getDiagnosticSuggestions(
            symptom: userMessage,
            vehicleType: 'General',
          );
          break;
        case 'maintenance':
          response = await openAiService.getServiceRecommendations(
            vehicleInfo: 'General',
            mileage: 0,
          );
          break;
        case 'cost':
          response = await openAiService.getCostEstimation(
            services: [],
            estimatedCost: 0,
          );
          break;
        default:
          response = await openAiService.getChatCompletion(
            userMessage: userMessage,
            conversationHistory: conversationHistory,
          );
      }

      // Add AI response
      final aiMsg = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );

      // Save conversation
      await _saveConversation();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get streaming response
  Stream<String> sendMessageStream(String userMessage) async* {
    // Add user message
    final userMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      role: 'user',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    final conversationHistory = state.messages
        .map((msg) => {
              'role': msg.role,
              'content': msg.content,
            })
        .toList();

    String fullResponse = '';
    try {
      await for (var chunk in openAiService.getChatCompletionStream(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
      )) {
        fullResponse += chunk;
        yield chunk;
      }

      // Add complete AI response
      final aiMsg = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: fullResponse,
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );

      await _saveConversation();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change conversation mode
  void setMode(String mode) {
    state = state.copyWith(selectedMode: mode);
  }

  /// Clear conversation
  void clearConversation() {
    state = AiChatState();
    _clearSavedConversation();
  }

  /// Load saved conversation
  Future<void> loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMessages = prefs.getStringList('ai_messages') ?? [];

      if (savedMessages.isNotEmpty) {
        final messages = savedMessages
            .map((msg) => AiMessage.fromJson(jsonDecode(msg)))
            .toList();
        state = state.copyWith(messages: messages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load conversation: $e');
    }
  }

  /// Save conversation
  Future<void> _saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messages =
          state.messages.map((msg) => jsonEncode(msg.toJson())).toList();
      await prefs.setStringList('ai_messages', messages);
    } catch (e) {
      // Silent fail for now
    }
  }

  /// Clear saved conversation
  Future<void> _clearSavedConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_messages');
    } catch (e) {
      // Silent fail
    }
  }
}

// AI Chat State Provider
final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final openAiService = ref.watch(openAiServiceProvider);
  return AiChatNotifier(openAiService: openAiService, ref: ref);
});

// Stream provider for streaming responses
final aiResponseStreamProvider =
    StreamProvider.family<String, String>((ref, userMessage) async* {
  final notifier = ref.watch(aiChatProvider.notifier);
  yield* notifier.sendMessageStream(userMessage);
});
