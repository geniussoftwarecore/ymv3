import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/ai_assistant_provider.dart';

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatProvider.notifier).loadConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final chatState = ref.watch(aiChatProvider);
    final isRTL = locale.isRTL;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🤖 المساعد الذكي'),
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            if (chatState.messages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('مسح المحادثة'),
                      content: const Text('هل تريد حذف جميع الرسائل؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            ref
                                .read(aiChatProvider.notifier)
                                .clearConversation();
                            Navigator.pop(context);
                          },
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // Mode Selection Tabs
            Container(
              color: Colors.deepPurple.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ModeButton(
                      label: 'عام',
                      mode: 'general',
                      currentMode: chatState.selectedMode,
                      isRTL: isRTL,
                      onTap: () {
                        ref.read(aiChatProvider.notifier).setMode('general');
                      },
                    ),
                    _ModeButton(
                      label: 'تشخيص',
                      mode: 'diagnostic',
                      currentMode: chatState.selectedMode,
                      isRTL: isRTL,
                      onTap: () {
                        ref.read(aiChatProvider.notifier).setMode('diagnostic');
                      },
                    ),
                    _ModeButton(
                      label: 'صيانة',
                      mode: 'maintenance',
                      currentMode: chatState.selectedMode,
                      isRTL: isRTL,
                      onTap: () {
                        ref
                            .read(aiChatProvider.notifier)
                            .setMode('maintenance');
                      },
                    ),
                    _ModeButton(
                      label: 'تكلفة',
                      mode: 'cost',
                      currentMode: chatState.selectedMode,
                      isRTL: isRTL,
                      onTap: () {
                        ref.read(aiChatProvider.notifier).setMode('cost');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Chat Messages
            Expanded(
              child: chatState.messages.isEmpty
                  ? _EmptyStateWidget(isRTL: isRTL)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState.messages[index];
                        return _ChatBubble(
                          message: message,
                          isRTL: isRTL,
                        );
                      },
                    ),
            ),

            // Error Message
            if (chatState.error != null)
              Container(
                color: Colors.red.withAlpha(25),
                padding: const EdgeInsets.all(12),
                child: Text(
                  '⚠️ ${chatState.error}',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // Input Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _messageController,
                      hintText: 'اسأل المساعد الذكي...',
                      prefixIcon: Icons.chat_bubble_outline,
                      maxLines: null,
                      enabled: !chatState.isLoading && !_isStreaming,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: (chatState.isLoading ||
                            _isStreaming ||
                            _messageController.text.isEmpty)
                        ? null
                        : () => _sendMessage(),
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    setState(() => _isStreaming = true);

    try {
      // Use streaming response
      await for (var _
          in ref.read(aiChatProvider.notifier).sendMessageStream(message)) {
        _scrollToBottom();
      }
    } catch (e) {
      // Error handling done in provider
    }

    setState(() => _isStreaming = false);
  }
}

/// Chat Bubble Widget
class _ChatBubble extends StatelessWidget {
  final AiMessage message;
  final bool isRTL;

  const _ChatBubble({
    required this.message,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final formattedTime = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.deepPurple : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '🤖 المساعد الذكي',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mode Button Widget
class _ModeButton extends StatelessWidget {
  final String label;
  final String mode;
  final String currentMode;
  final bool isRTL;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.isRTL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
          side: BorderSide(
            color: Colors.deepPurple,
            width: isSelected ? 0 : 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  final bool isRTL;

  const _EmptyStateWidget({required this.isRTL});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.smart_toy,
            size: 80,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          const Text(
            'مرحباً بك في المساعد الذكي 🤖',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك طرح أي سؤال حول الصيانة والإصلاحات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          const Column(
            children: [
              _SuggestionCard(
                icon: '🔧',
                title: 'تشخيص المشاكل',
                description: 'اطرح أعراض المشكلة للحصول على تشخيص',
              ),
              _SuggestionCard(
                icon: '🛠️',
                title: 'نصائح الصيانة',
                description: 'احصل على نصائح الصيانة الدورية',
              ),
              _SuggestionCard(
                icon: '💰',
                title: 'تقدير التكاليف',
                description: 'استفسر عن معقولية الأسعار',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
