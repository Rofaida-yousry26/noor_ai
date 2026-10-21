import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeChanged;
  static List<Map<String, dynamic>> get savedCitations =>
    _ChatScreenState.savedCitations;
  const ChatScreen({super.key, this.isDarkMode = true, this.onThemeChanged});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Keep the conversation while ChatScreen is closed and reopened during this app run.
  static final List<Map<String, dynamic>> _savedMessages = [];

  /// Citations returned by the backend, kept for the current app session.
  /// They are not persisted across a full app restart.
  static final List<Map<String, dynamic>> _savedCitations = [];
  static List<Map<String, dynamic>> get savedCitations =>
      List<Map<String, dynamic>>.unmodifiable(_savedCitations);
  static bool _savedDarkMode = true;

  bool _isLoading = false;
  late bool _isDarkMode;
  String _answerLanguage = 'auto';

  Color get _background =>
      _isDarkMode ? const Color(0xFF070B14) : const Color(0xFFF4F7FC);
  Color get _panel => _isDarkMode ? const Color(0xFF101B2D) : Colors.white;
  Color get _accent =>
      _isDarkMode ? const Color(0xFF52F5E5) : const Color(0xFF008F87);
  Color get _text =>
      _isDarkMode ? const Color(0xFFF1F6FF) : const Color(0xFF10233F);
  Color get _muted =>
      _isDarkMode ? const Color(0xFF8391A8) : const Color(0xFF697B95);
  Color get _border =>
      _isDarkMode ? const Color(0xFF1C2A40) : const Color(0xFFDCE5F0);
  Color get _userBubble =>
      _isDarkMode ? const Color(0xFF164A50) : const Color(0xFFDDF5F1);

  List<Map<String, dynamic>> get _messages => _savedMessages;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _savedDarkMode = widget.isDarkMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isLoading) return;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await ApiService.askQuestion(
        question: question,
        answerLanguage: _answerLanguage,
      );
      if (!mounted) return;
      final answer =
          response['answer']?.toString() ?? 'The AI returned no answer.';
      final rawSources = response['sources'];
      final sources = rawSources is List ? rawSources : <dynamic>[];
      final seenForAnswer = <String>{};
      for (final item in sources) {
        if (item is! Map) continue;
        final document = (item['document'] ?? 'Document').toString();
        final page = item['page'];
        final key = '$document|$page';
        if (!seenForAnswer.add(key)) continue;
        _savedCitations.insert(0, {
          'question': question,
          'document': document,
          'page': page,
          'answer': answer,
          'createdAt': DateTime.now(),
        });
      }
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': answer,
          'sources': sources,
        });
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Could not get an answer. Please try again.\n$error',
          'sources': <dynamic>[],
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _toggleTheme() {
    final nextValue = !_isDarkMode;
    setState(() {
      _isDarkMode = nextValue;
      _savedDarkMode = nextValue;
    });
    widget.onThemeChanged?.call(nextValue);
  }

  List<Map<String, dynamic>> _uniqueSources(List sources) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final item in sources) {
      if (item is! Map) continue;
      final document = (item['document'] ?? 'Document').toString();
      final page = item['page'];
      final key = '$document|$page';
      if (seen.add(key)) result.add({'document': document, 'page': page});
    }
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: _accent),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOOR AI',
                  style: TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'DOCUMENT ASSISTANT',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            onPressed: _toggleTheme,
            icon: Icon(
              _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: _accent,
            ),
          ),
          PopupMenuButton<String>(
            initialValue: _answerLanguage,
            icon: Icon(Icons.translate, color: _accent),
            onSelected: (value) => setState(() => _answerLanguage = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'auto', child: Text('Auto language')),
              PopupMenuItem(value: 'ar', child: Text('العربية')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 58, color: _accent),
                          const SizedBox(height: 20),
                          Text(
                            'Ask your documents',
                            style: TextStyle(
                              color: _text,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ask a question about your uploaded PDFs and NOOR AI will try to find the answer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      final sources = message['sources'] is List
                          ? message['sources'] as List
                          : <dynamic>[];
                      final uniqueSources = _uniqueSources(sources);
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.87,
                          ),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isUser ? _userBubble : _panel,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isUser
                                  ? _accent.withValues(alpha: 0.25)
                                  : _border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'].toString(),
                                style: TextStyle(
                                  color: _text,
                                  height: 1.6,
                                  fontSize: 14,
                                ),
                              ),
                              if (!isUser && uniqueSources.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Divider(color: _border),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.library_books_outlined,
                                      color: _accent,
                                      size: 17,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'SOURCES & REFERENCES',
                                      style: TextStyle(
                                        color: _accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${uniqueSources.length} refs',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...uniqueSources.map((source) {
                                  final page = source['page'];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 7),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _background,
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(color: _border),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf_outlined,
                                          color: _accent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            source['document'].toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _text,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (page != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _accent.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'PAGE $page',
                                              style: TextStyle(
                                                color: _accent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NOOR AI is thinking...',
                    style: TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: _panel,
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: _text),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask about your documents...',
                        hintStyle: TextStyle(color: _muted),
                        filled: true,
                        fillColor: _background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _background,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
