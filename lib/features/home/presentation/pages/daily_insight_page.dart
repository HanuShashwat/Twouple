import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class DailyInsightPage extends StatefulWidget {
  const DailyInsightPage({super.key});

  @override
  State<DailyInsightPage> createState() => _DailyInsightPageState();
}

class _DailyInsightPageState extends State<DailyInsightPage> {
  bool _isChatbotExpanded = false;
  final TextEditingController _insightQueryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _toggleChatbot() {
    setState(() {
      _isChatbotExpanded = !_isChatbotExpanded;
    });
    if (_isChatbotExpanded) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _submitQuery() {
    if (_insightQueryController.text.isNotEmpty) {
      // In a real app, send to BLoC or directly navigate to chatbot passing args
      context.push('/chatbot');
      _insightQueryController.clear();
      _toggleChatbot();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _insightQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Required for pretty Hero transitions overlay
      body: Stack(
        children: [
          // The expanded Hero Card
          Hero(
            tag: 'insight_card',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.background,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button Header
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              "Today's Insight",
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 32,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Mercury has entered your 7th house—expect sudden moments of deep clarity. Focus heavily on communication with those you trust today.\n\n"
                          "Historically, when planetary alignments center over the 7th house, the cosmic energy demands relationship re-evaluation. Conflicts that have been simmering beneath the surface are likely to break through. Do not shy away from these moments; instead, approach them with absolute truth and grace.\n\n"
                          "Your emotional balance today sits at a calm center, meaning logic will prevail over temper. Capitalize on this to forge stronger bounds natively and professionally. Tonight, try disconnecting from digital screens early.",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Morphing Chatbot FAB Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: 32,
            right: 24,
            width: _isChatbotExpanded ? MediaQuery.of(context).size.width - 48 : 64,
            height: 64,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(32),
              color: AppColors.surface,
              child: InkWell(
                onTap: _isChatbotExpanded ? null : _toggleChatbot,
                borderRadius: BorderRadius.circular(32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: _isChatbotExpanded ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: _isChatbotExpanded
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                              onPressed: _toggleChatbot,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _insightQueryController,
                                focusNode: _focusNode,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: "Ask about this insight...",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _submitQuery(),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.background, size: 16),
                              ),
                              onPressed: _submitQuery,
                            ),
                          ],
                        )
                      : const Center(
                          child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
