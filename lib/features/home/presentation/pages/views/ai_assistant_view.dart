import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/celestial_background.dart';

class AIAssistantView extends StatefulWidget {
  const AIAssistantView();

  @override
  State<AIAssistantView> createState() => AIAssistantViewState();
}


class AIAssistantViewState extends State<AIAssistantView>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIChatMessage> _messages = [];
  final List<AnimationController> _bubbleControllers = [];
  bool _isTyping = false;
  AnimationController? _pulseController;

  // ── Greeting ──────────────────────────────────────────────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Mock responses ────────────────────────────────────────────────────────
  static const List<String> _mockResponses = [
    'The stars suggest a moment of pause before you react. Mercury retrograde is softening your usual clarity — give it a day before any major decisions with your partner. 🌿',
    'Venus is forming a beautiful trine with your natal Moon right now. This is one of the most emotionally receptive windows of the month. Tonight, open up — even just a little. ✨',
    'Your composite chart shows Saturn sitting firmly in the 7th house. This creates beautiful longevity, but can bring periods of emotional distance. Patience is your superpower here. 🪐',
    'Mars in your 5th house is lighting up creativity and passion — use that energy to plan something unexpected together. A small, thoughtful gesture will land powerfully tonight. 🔥',
    'The lunar cycle is in its waning phase, a time for release and reflection rather than initiation. Try not to force breakthroughs right now — let things settle naturally. 🌙',
  ];

  static const List<Map<String, String>> _suggestionChips = [
    {'icon': '✨', 'label': 'Why do we keep clashing?'},
    {'icon': '💭', 'label': 'What does today\'s sky say?'},
    {'icon': '❤️', 'label': 'Improve our intimacy'},
    {'icon': '🌙', 'label': 'What should I avoid tonight?'},
    {'icon': '🔮', 'label': 'Read my partner\'s energy'},
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Pre-load the greeting as the first AI message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addAIMessage(
        '$_greeting ✨ I\'ve been watching the skies for you. '
        'Venus is in a gentle trine with your Moon today — '
        'a perfect time to open up. What\'s on your heart?',
      );
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _pulseController?.dispose();
    for (final c in _bubbleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _addAIMessage(String text) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    setState(() {
      _messages.add(AIChatMessage(text: text, isUser: false));
      _bubbleControllers.add(ctrl);
    });
    ctrl.forward();
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    setState(() {
      _messages.add(AIChatMessage(text: text, isUser: true));
      _bubbleControllers.add(ctrl);
    });
    ctrl.forward();
    _scrollToBottom();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _promptController.clear();
    _addUserMessage(trimmed);

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() => _isTyping = false);

    final response =
        _mockResponses[trimmed.length % _mockResponses.length];
    _addAIMessage(response);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return CelestialBackground(
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildChatList()),
              _buildTypingIndicator(),
              _buildSuggestionChips(),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pulsing glow avatar
          AnimatedBuilder(
            animation: _pulseController ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, _) {
              final pulse = _pulseController?.value ?? 0.0;
              final glowOpacity = 0.08 + pulse * 0.12;
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glowOpacity),
                      blurRadius: 14,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 22,
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aura',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your Cosmic Relationship Coach',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF788B7A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 7, color: Color(0xFF788B7A)),
                SizedBox(width: 5),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF788B7A),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat list ─────────────────────────────────────────────────────────────
  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final ctrl = _bubbleControllers[index];
        final slideAnim = Tween<Offset>(
          begin: msg.isUser
              ? const Offset(0.3, 0)
              : const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ctrl,
          curve: Curves.easeOutCubic,
        ));
        final fadeAnim =
            CurvedAnimation(parent: ctrl, curve: Curves.easeOut);

        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: msg.isUser
                  ? _buildUserBubble(msg.text)
                  : _buildAIBubble(msg.text),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    height: 1.65,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildUserBubble(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Typing indicator ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _pulseController ?? const AlwaysStoppedAnimation(0.0),
                  builder: (context, _) {
                    final pulse = _pulseController?.value ?? 0.0;
                    final delay = i * 0.25;
                    final t = (pulse + delay) % 1.0;
                    final opacity = 0.3 + (t < 0.5 ? t * 1.4 : (1.0 - t) * 1.4);
                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                            alpha: opacity.clamp(0.3, 1.0)),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestion chips ──────────────────────────────────────────────────────
  Widget _buildSuggestionChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestionChips.length,
        itemBuilder: (context, index) {
          final chip = _suggestionChips[index];
          return GestureDetector(
            onTap: () => _send(chip['label']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${chip['icon']}  ${chip['label']}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: IconButton(
                icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
                onPressed: () { /* Future attachment handler */ },
              ),
            ),
            Expanded(
              child: TextField(
                controller: _promptController,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask me anything about your charts...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => _send(_promptController.text),
                child: AnimatedBuilder(
                  animation: _pulseController ?? const AlwaysStoppedAnimation(0.0),
                  builder: (context, _) {
                    final pulse = _pulseController?.value ?? 0.0;
                    return Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                                alpha: 0.25 + pulse * 0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// More / Settings Page
// ─────────────────────────────────────────────


class AIChatMessage {
  final String text;
  final bool isUser;
  AIChatMessage({required this.text, required this.isUser});
}

