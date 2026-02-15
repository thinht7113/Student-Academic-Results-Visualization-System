import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/student_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isLoading = false;
  bool _sendContext = true;
  bool _contextSent = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        role: 'assistant',
        text:
            'Xin chào 👋 Mình là Cố vấn học tập AI. Bạn cần hỗ trợ gì về việc học?',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final provider = context.read<StudentProvider>();
      final data = provider.studentData;

      Map<String, dynamic>? contextData;
      if (_sendContext && !_contextSent && data != null) {
        contextData = {
          'grades': data.ketQuaHocTap
              .map(
                (r) => ({
                  'HocKy': r.hocKy,
                  'MaHP': r.maHP,
                  'TenHP': r.tenHP,
                  'SoTinChi': r.soTinChi,
                  'DiemHe10': r.diemHe10,
                  'DiemChu': r.diemChu,
                }),
              )
              .toList(),
          'plan': data.chuongTrinhDaoTao
              .map(
                (c) => ({
                  'HocKy': c.hocKy,
                  'MaHP': c.maHP,
                  'TenHP': c.tenHP,
                  'SoTinChi': c.soTinChi,
                }),
              )
              .toList(),
        };
      }

      final history = _messages
          .map((m) => {'role': m.role, 'text': m.text})
          .toList();

      final apiService = ApiService();
      final response = await apiService.chatWithAI(
        history.cast<Map<String, String>>(),
        contextData: contextData,
      );

      if (_sendContext && !_contextSent && contextData != null) {
        _contextSent = true;
      }

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: response));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            text: 'Lỗi: Không thể kết nối với AI. $e',
          ),
        );
        _isLoading = false;
      });
    }
    _scrollToBottom();
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

  void _newConversation() {
    setState(() {
      _messages.clear();
      _messages.add(
        _ChatMessage(
          role: 'assistant',
          text: 'Bắt đầu cuộc trò chuyện mới. Bạn muốn hỏi điều gì?',
        ),
      );
      _contextSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Cố vấn học tập'),
        actions: [
          IconButton(
            onPressed: _newConversation,
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Cuộc trò chuyện mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Context toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: context.scaffoldColor,
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _sendContext,
                    onChanged: (v) => setState(() => _sendContext = v!),
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gửi kèm dữ liệu học tập',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                if (_contextSent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Đã gửi',
                      style: AppTheme.caption.copyWith(color: AppTheme.success),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingBubble();
                return _buildBubble(_messages[index]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi...',
                        hintStyle: AppTheme.bodySmall.copyWith(
                          color: context.textMuted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        filled: true,
                        fillColor: context.scaffoldColor,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _send,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    final bubbleBg = isUser
        ? AppTheme.primaryColor
        : (context.isDark ? const Color(0xFF1E293B) : Colors.white);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDark ? 0.15 : 0.04,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      msg.text,
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    )
                  : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTheme.bodyMedium.copyWith(
                          color: context.textPrimary,
                        ),
                        strong: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        listBullet: AppTheme.bodyMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    final bubbleBg = context.isDark ? const Color(0xFF1E293B) : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_DotAnimation()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  _ChatMessage({required this.role, required this.text});
}

class _DotAnimation extends StatefulWidget {
  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity =
                0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
