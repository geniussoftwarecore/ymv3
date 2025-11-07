import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/themes/app_theme.dart';

class EnhancedChatPage extends ConsumerStatefulWidget {
  const EnhancedChatPage({super.key});

  @override
  ConsumerState<EnhancedChatPage> createState() => _EnhancedChatPageState();
}

class _EnhancedChatPageState extends ConsumerState<EnhancedChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 1,
      'name': 'محمد علي',
      'lastMessage': 'شكراً على خدمتك',
      'lastMessageTime': '2024-11-03 14:30',
      'unreadCount': 2,
      'isOnline': true,
      'avatar': 'م',
    },
    {
      'id': 2,
      'name': 'فريق الميكانيكا',
      'lastMessage': 'تم إكمال الصيانة',
      'lastMessageTime': '2024-11-03 13:15',
      'unreadCount': 0,
      'isOnline': true,
      'avatar': 'ف',
    },
    {
      'id': 3,
      'name': 'نور محمد',
      'lastMessage': 'ما موعد جاهزية السيارة؟',
      'lastMessageTime': '2024-11-03 12:00',
      'unreadCount': 1,
      'isOnline': false,
      'avatar': 'ن',
    },
  ];

  final List<Map<String, dynamic>> _currentMessages = [
    {
      'id': 1,
      'sender': 'محمد علي',
      'content': 'السلام عليكم، كيف حالة سيارتي؟',
      'timestamp': '10:30',
      'isFromMe': false,
      'type': 'text',
    },
    {
      'id': 2,
      'sender': 'أنت',
      'content': 'وعليكم السلام، السيارة بحالة جيدة ويتم العمل عليها الآن',
      'timestamp': '10:35',
      'isFromMe': true,
      'type': 'text',
    },
    {
      'id': 3,
      'sender': 'محمد علي',
      'content': 'شكراً! متى ستكون جاهزة؟',
      'timestamp': '10:40',
      'isFromMe': false,
      'type': 'text',
    },
  ];

  int _selectedConversation = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرسائل والمحادثات'),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: AppTheme.primaryWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: Row(
          children: [
            // Conversations List
            Container(
              width: 300,
              color: AppTheme.lightGray,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن محادثة...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppTheme.mediumGray),
                        ),
                        filled: true,
                        fillColor: AppTheme.primaryWhite,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        return _buildConversationTile(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Chat Area
            Expanded(
              child: Column(
                children: [
                  // Chat Header
                  _buildChatHeader(),
                  // Messages
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  // Input Area
                  _buildInputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(int index) {
    final conversation = _conversations[index];
    final isSelected = _selectedConversation == index;

    return Container(
      color: isSelected ? AppTheme.primaryWhite : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedConversation = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          AppTheme.primaryGreen.withValues(alpha: 0.3),
                      child: Text(
                        conversation['avatar'],
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (conversation['isOnline'])
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.successGreen,
                            border: Border.all(
                              color: AppTheme.primaryWhite,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation['name'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkGray.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversation['lastMessageTime'],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.darkGray.withValues(alpha: 0.5),
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (conversation['unreadCount'] > 0)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen,
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: AppTheme.primaryWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    final conversation = _conversations[_selectedConversation];

    return Container(
      color: AppTheme.primaryWhite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.3),
                    child: Text(
                      conversation['avatar'],
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (conversation['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.successGreen,
                          border: Border.all(
                            color: AppTheme.primaryWhite,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation['isOnline'] ? 'نشط الآن' : 'غير متصل',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: conversation['isOnline']
                              ? AppTheme.successGreen
                              : AppTheme.darkGray.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.call, color: AppTheme.primaryGreen),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('بدء مكالمة صوتية')),
                  );
                },
              ),
              IconButton(
                icon:
                    const Icon(Icons.video_call, color: AppTheme.primaryGreen),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('بدء مكالمة فيديو')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.info, color: AppTheme.primaryGreen),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('معلومات المحادثة')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _currentMessages.length,
      itemBuilder: (context, index) {
        final message = _currentMessages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment:
          message['isFromMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: Column(
          crossAxisAlignment: message['isFromMe']
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message['isFromMe']
                    ? AppTheme.primaryGreen
                    : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message['content'],
                style: TextStyle(
                  color: message['isFromMe']
                      ? AppTheme.primaryWhite
                      : AppTheme.darkGray,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['timestamp'],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.darkGray.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: AppTheme.primaryWhite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.mediumGray.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إضافة ملف أو صورة')),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.mediumGray),
                ),
                filled: true,
                fillColor: AppTheme.lightGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppTheme.primaryGreen,
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _currentMessages.add({
                    'id': _currentMessages.length + 1,
                    'sender': 'أنت',
                    'content': _messageController.text,
                    'timestamp': DateTime.now().toString(),
                    'isFromMe': true,
                    'type': 'text',
                  });
                  _messageController.clear();
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });
              }
            },
            child: const Icon(Icons.send, color: AppTheme.primaryWhite),
          ),
        ],
      ),
    );
  }
}
