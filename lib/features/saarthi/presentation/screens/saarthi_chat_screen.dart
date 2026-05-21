import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamsatech_design_system/hamsatech_design_system.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_helper.dart';
import '../../../../core/services/session_memory.dart';
import '../../../../core/widgets/saarthi_avatar.dart';
import '../../../../core/widgets/saarthi_welcome_card.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser})
      : timestamp = DateTime.now();
}

// ── Suggestion data ───────────────────────────────────────────────────────────

class _Suggestion {
  final String title;
  final String subtitle;
  final IconData icon;
  final String prompt;

  const _Suggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.prompt,
  });
}

const _kSuggestions = [
  _Suggestion(
    title: 'Analyze last session',
    subtitle: 'Review shot spread and metrics',
    icon: Icons.bar_chart_rounded,
    prompt: 'Analyze my last session and review the shot spread and metrics.',
  ),
  _Suggestion(
    title: 'Technique tips',
    subtitle: 'Get advice on grip and breathing',
    icon: Icons.my_location_rounded,
    prompt: 'Give me technique tips on grip and breathing.',
  ),
  _Suggestion(
    title: 'Plan next training',
    subtitle: 'Set goals for your upcoming session',
    icon: Icons.calendar_month_rounded,
    prompt: 'Help me plan my next training session and set goals.',
  ),
  _Suggestion(
    title: 'Breathing control',
    subtitle: 'Improve your breathing techniques',
    icon: Icons.air_rounded,
    prompt: 'Help me improve my breathing control techniques.',
  ),
  _Suggestion(
    title: 'Mental focus coaching',
    subtitle: 'Build focus and concentration',
    icon: Icons.psychology_rounded,
    prompt: 'Coach me on mental focus and concentration.',
  ),
];

// ── Mock AI responses ─────────────────────────────────────────────────────────

const _kMockResponses = <String, String>{
  'Analyze my last session and review the shot spread and metrics.':
      "Looking at your last session, your shot spread was 12.4 cm with 87% of shots in the 9–10 ring. Your grouping tightened in rounds 3–5, which suggests better rhythm. The slight drop in your final round could be fatigue-related — let's work on maintaining consistency under pressure.",
  'Give me technique tips on grip and breathing.':
      'For grip, aim for a consistent 6-pressure grip — firm enough for control but not so tight it creates tension in your forearm. For breathing, try the 4-7-8 technique: inhale for 4 counts, hold for 7, exhale for 8. Release your shot at the natural respiratory pause.',
  'Help me plan my next training session and set goals.':
      'Based on your recent performance, I suggest focusing on: (1) 30-min technique drill with slow follow-through emphasis, (2) 3 series of 10 shots with mental-cue practice, and (3) a 10-min review session analysing your shot-call accuracy. Goal: improve 10-ring percentage by 5%.',
  'Help me improve my breathing control techniques.':
      'Great focus area! Start with diaphragmatic breathing exercises — 5 min before training. During shooting, use abdominal breathing and sync your shot release with the end of your natural respiratory pause. Practice box breathing (4-4-4-4) daily to build baseline control.',
  'Coach me on mental focus and concentration.':
      "Your mental game is key! Try the 'pre-shot routine' — a consistent 15-second ritual before each shot: 2 breaths, check alignment, set your mental cue word (e.g., 'smooth'). Use the '3-second rule' to commit fully and block distractions. Mindfulness for 10 min daily will compound over time.",
};

String _mockReply(String prompt) =>
    _kMockResponses[prompt] ??
    "That's a great question! Based on your recent sessions, focus on consistency in your routine and maintaining a steady mental state throughout each series.";

// ── Screen ────────────────────────────────────────────────────────────────────

class SaarthiChatScreen extends StatefulWidget {
  const SaarthiChatScreen({super.key});

  @override
  State<SaarthiChatScreen> createState() => _SaarthiChatScreenState();
}

class _SaarthiChatScreenState extends State<SaarthiChatScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isTyping = false;

  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final reply = _mockReply(trimmed);
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();

    _persistChat(trimmed, reply);
  }

  void _persistChat(String userMessage, String aiResponse) {
    final athleteId = AuthHelper.getCurrentAthleteId();
    if (athleteId == null) {
      debugPrint('[SAARTHI] chat save skipped — no athlete_id (onboarding incomplete)');
      return;
    }
    final sessionId = SessionMemory.sessionId ?? 'no-session';

    Future(() async {
      debugPrint('[SAARTHI] saving chat athleteId=$athleteId sessionId=$sessionId');
      try {
        final res = await ApiService.instance.saveChat(
          athleteId: athleteId,
          sessionId: sessionId,
          userMessage: userMessage,
          aiResponse: aiResponse,
        );
        debugPrint('[SAARTHI] chat saved status=${res.statusCode}');
      } catch (e) {
        debugPrint('[SAARTHI] chat save failed: $e');
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleClose() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMessages = _messages.isNotEmpty;

    return Scaffold(
      backgroundColor: DSColors.appBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onClose: _handleClose),
            const Divider(height: 1, color: DSColors.appBorder),
            Expanded(
              child: hasMessages ? _buildChat() : _buildWelcome(),
            ),
            _BottomInput(
              controller: _controller,
              onSend: () => _send(_controller.text),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome / empty state ────────────────────────────────────────────────────

  Widget _buildWelcome() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        const SaarthiWelcomeCard(),
        const SizedBox(height: 24),
        Text(
          'Quick actions',
          style: DSTypography.labelMd.copyWith(color: DSColors.textSecondary),
        ),
        const SizedBox(height: 12),
        ..._buildSuggestionGrid(),
      ],
    );
  }

  List<Widget> _buildSuggestionGrid() {
    final rows = <Widget>[];
    for (var i = 0; i < _kSuggestions.length; i += 2) {
      final isOdd = i + 1 >= _kSuggestions.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: _SuggestionCard(
                  item: _kSuggestions[i],
                  onTap: () => _send(_kSuggestions[i].prompt),
                ),
              ),
              if (!isOdd) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _SuggestionCard(
                    item: _kSuggestions[i + 1],
                    onTap: () => _send(_kSuggestions[i + 1].prompt),
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  // ── Chat view ─────────────────────────────────────────────────────────────────

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) {
                return _TypingBubble(controller: _dotController);
              }
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        if (!_isTyping)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: _kSuggestions.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _send(s.prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: DSColors.appCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DSColors.appBorder),
                      ),
                      child: Text(
                        s.title,
                        style: DSTypography.labelSm
                            .copyWith(color: DSColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: DSColors.textPrimary,
            onPressed: onClose,
          ),
          const SaarthiAvatar(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saarthi AI',
                  style: DSTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: DSTypography.caption.copyWith(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            color: DSColors.textPrimary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const SaarthiAvatar(size: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF2F7E8F)
                        : DSColors.appCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: DSColors.appBorder),
                  ),
                  child: Text(
                    message.text,
                    style: DSTypography.bodyMedium.copyWith(
                      color:
                          isUser ? Colors.white : DSColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: DSTypography.caption,
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded,
                          size: 14, color: Color(0xFF2F7E8F)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SaarthiAvatar(size: 32),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: DSColors.appCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: DSColors.appBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _AnimatedDot(controller: controller, index: i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  const _AnimatedDot({required this.controller, required this.index});
  final AnimationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          index * 0.2,
          0.6 + index * 0.2,
          curve: Curves.easeInOut,
        ),
      ),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Opacity(
          opacity: anim.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF2F7E8F),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Suggestion card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.item, required this.onTap});
  final _Suggestion item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DSColors.appCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DSColors.appBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF2F7E8F).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon,
                  color: const Color(0xFF2F7E8F), size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: DSTypography.labelMd.copyWith(
                color: DSColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: DSTypography.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom input bar ──────────────────────────────────────────────────────────

class _BottomInput extends StatelessWidget {
  const _BottomInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: DSColors.appBackground,
        border: Border(top: BorderSide(color: DSColors.appBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded,
              color: DSColors.textMuted, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DSColors.appCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DSColors.appBorder),
              ),
              child: TextField(
                controller: controller,
                style: DSTypography.bodyMedium,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textPlaceholder,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2F7E8F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

