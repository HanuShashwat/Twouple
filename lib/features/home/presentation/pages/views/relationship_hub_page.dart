import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/celestial_background.dart';

class RelationshipHubPage extends StatefulWidget {
  const RelationshipHubPage();

  @override
  State<RelationshipHubPage> createState() => RelationshipHubPageState();
}


class RelationshipHubPageState extends State<RelationshipHubPage> {
  bool _isInsightExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Relationship Hub', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: CelestialBackground(
        child: CustomScrollView(
          slivers: [
             SliverToBoxAdapter(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                 child: Column(
                   children: [
                     // Avatars & Score
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          _buildAvatar('You', AppColors.primary),
                          Transform.translate(
                            offset: const Offset(-20, 0),
                            child: _buildAvatar('Emily', const Color(0xFFDEA080)),
                          ),
                       ],
                     ),
                     const SizedBox(height: 12),
                     const Text('COMPOSITE HARMONY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textMuted)),
                     const SizedBox(height: 4),
                     const Text('92%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                   ]
                 )
               )
             ),
             
             // Daily Insight (Interactive)
             SliverToBoxAdapter(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                 child: GestureDetector(
                   onTap: () {
                     setState(() {
                       _isInsightExpanded = !_isInsightExpanded;
                     });
                   },
                   child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastEaseInToSlowEaseOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.surface],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               const Row(
                                 children: [
                                   Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                                   SizedBox(width: 8),
                                   Text('SHARED DAILY INSIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary)),
                                 ]
                               ),
                               Icon(_isInsightExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.primary, size: 20)
                            ]
                          ),
                          const SizedBox(height: 12),
                          const Text('Venus is transiting your shared 7th house today. A perfect evening for vulnerability and deep conversation.', style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
                          if (_isInsightExpanded) ...[
                             const SizedBox(height: 12),
                             const Text(
                               'Because your natal moons are in trine, the effect of Venus today acts as a double multiplier for empathy. Avoid bringing up logistical disagreements until tomorrow—use tonight solely for emotional connection and relaxation.',
                               style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary)
                             ),
                          ]
                        ]
                      )
                   ),
                 )
               )
             ),

             // Grid of Dynamics (Interactive)
             SliverPadding(
               padding: const EdgeInsets.all(16),
               sliver: SliverGrid.count(
                 crossAxisCount: 2,
                 childAspectRatio: 1.15,
                 mainAxisSpacing: 12,
                 crossAxisSpacing: 12,
                 children: const [
                   InteractiveMetricTile(title: 'Communication', score: '94%', reason: 'Mercury aligns well today. Words flow easily.', icon: Icons.chat_bubble_outline_rounded, color: Color(0xFF8784B4)),
                   InteractiveMetricTile(title: 'Intimacy', score: '82%', reason: 'Venus provides a warm, protective emotional shell.', icon: Icons.favorite_border_rounded, color: Color(0xFFDEA080)),
                   InteractiveMetricTile(title: 'Trust', score: '90%', reason: 'Saturn anchors your shared foundations securely.', icon: Icons.shield_outlined, color: Color(0xFF788B7A)),
                   InteractiveMetricTile(title: 'Growth', score: '75%', reason: 'Jupiter is retrograde; focus on internal lessons.', icon: Icons.park_outlined, color: Color(0xFFE7AD5D)),
                 ]
               )
             ),
             
             const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ]
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            boxShadow: const [
               BoxShadow(color: AppColors.background, spreadRadius: 2),
            ]
          ),
          child: Center(
            child: Icon(Icons.person, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ]
    );
  }
}


class InteractiveMetricTile extends StatefulWidget {
  final String title;
  final String score;
  final String reason;
  final IconData icon;
  final Color color;

  const InteractiveMetricTile({
    required this.title,
    required this.score,
    required this.reason,
    required this.icon,
    required this.color,
  });

  @override
  State<InteractiveMetricTile> createState() => InteractiveMetricTileState();
}


class InteractiveMetricTileState extends State<InteractiveMetricTile> {
  bool _showReason = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showReason = !_showReason;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _showReason ? widget.color.withValues(alpha: 0.1) : AppColors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withValues(alpha: 0.2)),
        ),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showReason ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
            return Stack(
               alignment: Alignment.center,
               children: [
                  Positioned(
                    key: bottomChildKey,
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  ),
               ],
            );
          },
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 16),
                  ),
                  Text(widget.score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: widget.color)),
                ]
              ),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.5)),
            ]
          ),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text('${widget.title} Insights', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.color)),
               const SizedBox(height: 8),
               Text(widget.reason, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary)),
            ],
          ),
        )
      )
    );
  }
}

