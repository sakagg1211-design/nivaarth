import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../services/backend_service.dart';

class ChatMessageModel {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AdvisorChatPage extends ConsumerStatefulWidget {
  const AdvisorChatPage({super.key});

  @override
  ConsumerState<AdvisorChatPage> createState() => _AdvisorChatPageState();
}

class _AdvisorChatPageState extends ConsumerState<AdvisorChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BackendService _backendService = BackendService();

  bool _isTyping = false;

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text: "Namaste! Main hoon **NV Advisor** 🤖\n\n"
          "Aapka personal AI hedge-fund co-pilot. Main aapke portfolio holdings, live P&L, NV conviction scores aur Indian market trends ko real-time analyze karke personalized advice deta hoon.\n\n"
          "Aap mujhse koi bhi financial ya portfolio question pooch sakte hain!",
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  final List<String> _quickSuggestions = [
    "Mera portfolio performance kaisa hai?",
    "Aapke hisaab se sabse weak stock kaunsa hai?",
    "Top conviction holding kaunsi hai?",
    "Nifty 50 aur market ka trend kya hai?",
    "Portfolio risk aur concentration balance kaise karein?",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();
    setState(() {
      _messages.add(
        ChatMessageModel(
          text: text,
          isUser: true,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final reply = await _backendService.chatWithAdvisor(
        text,
        userId: user?.id,
      );

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessageModel(
              text: reply,
              isUser: false,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }

      // Save to Supabase ChatMessages if logged in
      if (user != null) {
        try {
          await Supabase.instance.client.from('ChatMessages').insert([
            {
              'user_id': user.id,
              'sender': 'user',
              'message': text,
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'user_id': user.id,
              'sender': 'advisor',
              'message': reply,
              'created_at': DateTime.now().toIso8601String(),
            },
          ]);
        } catch (_) {
          // Table may not exist yet; session state is retained
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessageModel(
              text: "⚠️ NV Advisor filhal busy hai ya connection me issue hai. Kripya thodi der baad dobara poochhein.",
              isUser: false,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111215),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5A93C), Color(0xFFB87B18)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5A93C).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "NV Advisor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: const Color(0xFF00C853).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Color(0xFF00C853)),
                            SizedBox(width: 4),
                            Text(
                              "LIVE AI",
                              style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Quantitative Hedge-Fund Copilot",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Clear Chat",
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 20),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessageModel(
                    text: "Chat reset. Aap mujhse apne portfolio ke bare me kuch bhi pooch sakte hain!",
                    isUser: false,
                    time: DateTime.now(),
                  ),
                );
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick suggestions chips
            _buildSuggestionsBar(),

            // Chat conversation
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping) _buildTypingIndicator(),

            // Bottom Input Field
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _quickSuggestions[index];
          return ActionChip(
            label: Text(
              prompt,
              style: const TextStyle(
                color: Color(0xFFD6DADF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF191B20),
            side: const BorderSide(color: Color(0xFF2C2F37)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              height: 32,
              width: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E2024),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFFE5A93C),
                size: 17,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFFE5A93C).withValues(alpha: 0.16)
                    : const Color(0xFF16181D),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFFE5A93C).withValues(alpha: 0.40)
                      : const Color(0xFF26282E),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _formatMessageText(msg.text, isUser),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              height: 32,
              width: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF262930),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _formatMessageText(String rawText, bool isUser) {
    // Splits text with bold tags or bullet points for readability
    final lines = rawText.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 6);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line.replaceAll('**', ''),
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFFE1E5EA),
              fontSize: 14,
              height: 1.4,
              fontWeight: line.contains('**') || line.startsWith('•') || line.startsWith('#')
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16181D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF26282E)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE5A93C),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "NV Advisor analyzing...",
                  style: TextStyle(
                    color: Color(0xFFE5A93C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF111215),
        border: Border(
          top: BorderSide(color: Color(0xFF23252B), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF191B20),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: const Color(0xFF2C2F36)),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: const Color(0xFFE5A93C),
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: "Ask NV Advisor anything about your portfolio...",
                  hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _sendMessage(_controller.text),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5A93C),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5A93C).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
