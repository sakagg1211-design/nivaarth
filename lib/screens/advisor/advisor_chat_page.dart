import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/backend_service.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../providers/advisor_question_provider.dart';
import '../../core/theme/app_colors.dart';

class ChatMessageModel {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'time': time.toIso8601String(),
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    text: json['text'] as String? ?? '',
    isUser: json['isUser'] as bool? ?? false,
    time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
  );
}

class AdvisorChatPage extends ConsumerStatefulWidget {
  const AdvisorChatPage({super.key});

  @override
  ConsumerState<AdvisorChatPage> createState() => _AdvisorChatPageState();
}

// The greeting is stored as a key and worded at display, so it follows a language switch
const _greetingKey = '__nv_greeting__';

class _AdvisorChatPageState extends ConsumerState<AdvisorChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BackendService _backendService = BackendService();

  bool _isTyping = false;

  late final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text: _greetingKey,
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  List<String> get _quickSuggestions => [
        context.t.advAsk1,
        context.t.advAsk2,
        context.t.advAsk3,
        context.t.advAsk4,
        context.t.advAsk5,
        context.t.advAsk6,
      ];

  @override
  void initState() {
    super.initState();
    _loadTodayHistory();
    // A question set before this page was built (opened from the Pulse "kyun" button)
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePendingQuestion());
  }

  void _takePendingQuestion() {
    if (!mounted) return;
    final q = ref.read(advisorQuestionProvider);
    if (q == null) return;
    ref.read(advisorQuestionProvider.notifier).state = null;
    _sendMessage(q);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dateKey = "chat_history_${now.year}_${now.month}_${now.day}";
      final raw = prefs.getString(dateKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        if (list.isNotEmpty) {
          final loaded = list.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
          setState(() {
            _messages.clear();
            _messages.addAll(loaded);
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error loading today chat history: $e");
    }
  }

  Future<void> _saveTodayHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dateKey = "chat_history_${now.year}_${now.month}_${now.day}";
      final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString(dateKey, encoded);
    } catch (e) {
      debugPrint("Error saving today chat history: $e");
    }
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
    _saveTodayHistory();

    try {
      final reply = await _backendService.chatWithAdvisor(text);

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
        _saveTodayHistory();
      }

      // Save to Supabase ChatMessages if logged in
      final user = Supabase.instance.client.auth.currentUser;
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
              text: context.t.advBusy,
              isUser: false,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
        _saveTodayHistory();
      }
    }
  }

  void _showTodayHistoryModal() {
    final now = DateTime.now();
    final todayMessages = _messages.where((m) =>
      m.time.year == now.year &&
      m.time.month == now.month &&
      m.time.day == now.day
    ).toList();

    final userQuestions = <Map<String, dynamic>>[];
    for (int i = 0; i < todayMessages.length; i++) {
      if (todayMessages[i].isUser) {
        String answerSnippet = context.t.advNoReply;
        if (i + 1 < todayMessages.length && !todayMessages[i + 1].isUser) {
          answerSnippet = todayMessages[i + 1].text;
        }
        userQuestions.add({
          "question": todayMessages[i].text,
          "time": todayMessages[i].time,
          "answer": answerSnippet,
        });
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollCtrl) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history_rounded, color: AppColors.inkSoft, size: 22),
                          SizedBox(width: 8),
                          Text(
                            context.t.advHistoryTitle,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.inkSoft.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.t.advQueries(userQuestions.length),
                          style: TextStyle(
                            color: AppColors.inkSoft,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.line, height: 1),
                Expanded(
                  child: userQuestions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, color: AppColors.ink.withValues(alpha: 0.38), size: 40),
                              const SizedBox(height: 12),
                              Text(
                                context.t.advNoHistory,
                                style: TextStyle(color: AppColors.ink.withValues(alpha: 0.5), fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: userQuestions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = userQuestions[index];
                            final time = item["time"] as DateTime;
                            final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _controller.text = item["question"];
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Q: ${item['question']}",
                                            style: TextStyle(
                                              color: AppColors.inkSoft,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeStr,
                                          style: TextStyle(color: AppColors.ink.withValues(alpha: 0.4), fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item["answer"],
                                      style: TextStyle(
                                        color: AppColors.ink.withValues(alpha: 0.7),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(advisorQuestionProvider, (_, q) {
      if (q != null) Future.microtask(_takePendingQuestion);
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.accent, Color(0xFFB87B18)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
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
                      Text(
                        "NV Advisor",
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              "LIVE AI",
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    context.t.advSub,
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.5),
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
            tooltip: context.t.advHistoryTitle,
            icon: Icon(Icons.history_rounded, color: AppColors.inkSoft, size: 22),
            onPressed: _showTodayHistoryModal,
          ),
          IconButton(
            tooltip: context.t.advClear,
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.ink.withValues(alpha: 0.54), size: 20),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessageModel(
                    text: context.t.advReset,
                    isUser: false,
                    time: DateTime.now(),
                  ),
                );
              });
              _saveTodayHistory();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Wide screens: one readable chat column instead of edge-to-edge.
            constraints: BoxConstraints(
              maxWidth: Breakpoints.isDesktop(context) ? 860 : double.infinity,
            ),
            child: SizedBox(width: double.infinity, child: _buildChatColumn()),
          ),
        ),
      ),
    );
  }

  Widget _buildChatColumn() {
    return Column(
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
    );
  }

  Widget _buildSuggestionChip(String prompt) {
    return ActionChip(
      label: Text(
        prompt,
        style: TextStyle(
          color: AppColors.inkSoft,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.surfaceSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      onPressed: () => _sendMessage(prompt),
    );
  }

  Widget _buildSuggestionsBar() {
    // Wide screens have room to show every prompt; phones scroll sideways.
    if (Breakpoints.isDesktop(context)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 10, AppSpacing.lg, 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final prompt in _quickSuggestions) _buildSuggestionChip(prompt),
          ],
        ),
      );
    }

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: _quickSuggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) =>
            _buildSuggestionChip(_quickSuggestions[index]),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.inkSoft,
                size: 17,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Breakpoints.isDesktop(context)
                    ? 700
                    : MediaQuery.of(context).size.width * 0.85,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.inkSoft.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.inkSoft.withValues(alpha: 0.40)
                      : AppColors.line,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _formatMessageText(msg.text == _greetingKey ? context.t.advGreeting : msg.text, isUser),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: AppColors.ink.withValues(alpha: 0.3),
                        fontSize: 11,
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary,
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarkdownTable(List<String> tableLines) {
    if (tableLines.isEmpty) return const SizedBox.shrink();

    final List<List<String>> rows = [];
    for (final line in tableLines) {
      final trimmed = line.trim();
      // Skip markdown separator line e.g. | :--- | :--- |
      if (trimmed.replaceAll(RegExp(r'[\s|:-]'), '').isEmpty) {
        continue;
      }
      final cells = trimmed
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.isNotEmpty) {
        rows.add(cells);
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    final headers = rows.first;
    final dataRows = rows.skip(1).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.symmetric(
              inside: BorderSide(color: AppColors.line, width: 1),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                ),
                children: headers.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    h.replaceAll('**', ''),
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    softWrap: true,
                  ),
                )).toList(),
              ),
              ...dataRows.map((r) => TableRow(
                children: List.generate(headers.length, (i) {
                  final text = i < r.length ? r[i] : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      text.replaceAll('**', ''),
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                      ),
                      softWrap: true,
                    ),
                  );
                }),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formatMessageText(String rawText, bool isUser) {
    final lines = rawText.split('\n');
    final List<Widget> widgets = [];
    final List<String> currentTableLines = [];

    void flushTable() {
      if (currentTableLines.isNotEmpty) {
        widgets.add(_buildMarkdownTable(List.from(currentTableLines)));
        currentTableLines.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Check if markdown table row
      if (trimmed.startsWith('|') && trimmed.endsWith('|') && trimmed.length > 2) {
        currentTableLines.add(trimmed);
        continue;
      } else {
        flushTable();
      }

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Section divider ---
      if (trimmed == '---' || trimmed == '***') {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppColors.line, height: 1),
          ),
        );
        continue;
      }

      // Headings: ### or ## or #
      if (trimmed.startsWith('#')) {
        final cleanTitle = trimmed.replaceAll(RegExp(r'^#+\s*'), '').replaceAll('**', '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              cleanTitle,
              softWrap: true,
              textWidthBasis: TextWidthBasis.parent,
              style: TextStyle(
                color: AppColors.inkSoft,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
        continue;
      }

      // Blockquotes: >
      final isQuote = trimmed.startsWith('>');
      final contentText = isQuote ? trimmed.substring(1).trim() : line;

      // Parse inline **bold**
      final spans = _parseInlineSpans(contentText, isUser);

      if (isQuote) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border(
                left: BorderSide(color: AppColors.lineStrong, width: 1),
              ),
            ),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                children: spans,
              ),
              softWrap: true,
              textWidthBasis: TextWidthBasis.parent,
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: isUser ? AppColors.ink : AppColors.inkSoft,
                fontSize: 14,
                height: 1.45,
              ),
              children: spans,
            ),
            softWrap: true,
            textWidthBasis: TextWidthBasis.parent,
          ),
        ),
      );
    }

    flushTable();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<InlineSpan> _parseInlineSpans(String text, bool isUser) {
    final List<InlineSpan> spans = [];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: isUser ? AppColors.ink : AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
      ));
    }

    return spans;
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.inkSoft,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  context.t.advAnalyzing,
                  style: TextStyle(
                    color: AppColors.inkSoft,
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceSecondary, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: AppColors.ink, fontSize: 14),
                cursorColor: AppColors.inkSoft,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: context.t.advHint,
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
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
                color: AppColors.accent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
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
