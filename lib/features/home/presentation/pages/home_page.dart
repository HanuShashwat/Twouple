import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/celestial_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardView(),
          _AIAssistantView(),
          _PartnerSyncView(),
          _MoreView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
            label: 'AI Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Sync',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.menu_open_rounded, color: AppColors.primary),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final TextEditingController _promptController = TextEditingController();
  final PageController _chartPageController = PageController(initialPage: 1);
  DateTime _selectedDate = DateTime.now();


  @override
  void dispose() {
    _promptController.dispose();
    _chartPageController.dispose();
    super.dispose();
  }

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final difference = selected.difference(today).inDays;
    
    if (difference == 0) return 'TODAY';
    if (difference == -1) return 'YESTERDAY';
    if (difference == 1) return 'TOMORROW';
    
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${selected.day} ${months[selected.month - 1]}';
  }

  int _getRingValue(String type, DateTime date) {
    int hash = date.day + date.month * 31 + date.year + type.hashCode;
    return (hash % 60) + 40;
  }

  List<String> _getDaysMap(bool isPast) {
    final now = DateTime.now();
    List<String> result = [];
    for (int i = 0; i < 7; i++) {
      DateTime d = isPast ? now.subtract(Duration(days: 7 - i)) : now.add(Duration(days: i));
      switch (d.weekday) {
        case 1: result.add('Mon'); break;
        case 2: result.add('Tue'); break;
        case 3: result.add('Wed'); break;
        case 4: result.add('Thu'); break;
        case 5: result.add('Fri'); break;
        case 6: result.add('Sat'); break;
        case 7: result.add('Sun'); break;
      }
    }
    return result;
  }

  Widget _buildRing(String label, int percentage, Color color, String tooltipText) {
    return Tooltip(
      message: tooltipText,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Drop Shadow Glow (Optional, but adds immense premium feel)
              Container(
                height: 85,
                width: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 16, spreadRadius: 4),
                  ]
                ),
              ),
              SizedBox(
                height: 85,
                width: 85,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.15), // Tinted background track
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
               TweenAnimationBuilder<double>(
                 tween: Tween<double>(begin: 0, end: percentage.toDouble()),
                 duration: const Duration(milliseconds: 1500),
                 builder: (context, value, _) => Text(
                   '${value.toInt()}%', 
                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrimary)
                 ),
               ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartWidget(List<FlSpot> spots, List<String> daysMap) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 850),
        curve: Curves.fastEaseInToSlowEaseOut,
        builder: (context, animValue, _) {
          final animatedSpots = spots.map((e) => FlSpot(e.x, e.y * animValue)).toList();
          return LineChart(
            LineChartData(
              maxY: 8,
              minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) => LineTooltipItem(
                      'Energy Score: ${(spot.y / (animValue > 0 ? animValue : 1)).toStringAsFixed(1)}\n${daysMap[spot.x.toInt()]}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0 && value.toInt() >= 0 && value.toInt() < daysMap.length) {
                         return Text(daysMap[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7AD5D), AppColors.primary],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3.0 * (animValue > 0.2 ? animValue : 0),
                        color: AppColors.surface,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.4),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            duration: Duration.zero,
          );
        }
      ),
    );
  }

  void _openGraphPopup(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.7), // Dimmed background
        transitionDuration: const Duration(milliseconds: 750),
        reverseTransitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut, // Extremely Apple-like heavy inertia curve
            reverseCurve: Curves.fastOutSlowIn,
          );
          return FadeTransition(
            opacity: curvedAnim,
            child: child,
          );
        },
        pageBuilder: (context, _, __) {
          int currentChartPage = 1; // Default to upcoming week!
          
          return StatefulBuilder(
            builder: (context, setState) {
              final pastSpots = const [
                FlSpot(0, 5), FlSpot(1, 4.5), FlSpot(2, 3), FlSpot(3, 4), FlSpot(4, 6), FlSpot(5, 5.5), FlSpot(6, 4)
              ];
              final futureSpots = const [
                FlSpot(0, 4), FlSpot(1, 3.5), FlSpot(2, 5), FlSpot(3, 6), FlSpot(4, 5.5), FlSpot(5, 7), FlSpot(6, 6.5)
              ];
    
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 400,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 32,
                          spreadRadius: 8,
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            currentChartPage == 0 ? 'Energy Trend (Previous Week)' : 'Energy Trend (Upcoming Week)',
                            key: ValueKey(currentChartPage),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0 && currentChartPage == 1) {
                                setState(() => currentChartPage = 0);
                              } else if (details.primaryVelocity! < 0 && currentChartPage == 0) {
                                setState(() => currentChartPage = 1);
                              }
                            },
                            // AnimatedSwitcher with directional slide:
                            //   page 0 (past)   = slides in from left
                            //   page 1 (future) = slides in from right
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 550),
                              reverseDuration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.fastEaseInToSlowEaseOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                final isPage0 = (child.key == const ValueKey(0));
                                final beginOffset = isPage0
                                    ? const Offset(-0.18, 0)
                                    : const Offset(0.18, 0);
                                final slideAnim = Tween<Offset>(
                                  begin: beginOffset,
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                ));
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slideAnim,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(currentChartPage),
                                child: currentChartPage == 0
                                    ? _buildLineChartWidget(pastSpots, _getDaysMap(true))
                                    : _buildLineChartWidget(futureSpots, _getDaysMap(false)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: currentChartPage == 0 ? 8 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: currentChartPage == 0 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: currentChartPage == 1 ? 8 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: currentChartPage == 1 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          );
        }
      )
    );
  }

  Widget _buildSyncBar(String label, int value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Text('$value%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            }
          ),
        ),
      ],
    );
  }

  void _openSyncPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8), 
                     decoration: const BoxDecoration(color: Color(0x33DEA080), shape: BoxShape.circle), 
                     child: const Icon(Icons.favorite_rounded, color: Color(0xFFDEA080), size: 20)
                   ),
                   const SizedBox(width: 16),
                   const Expanded(child: Text('Cosmic Alignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary))),
                ]
              ),
              const SizedBox(height: 24),
              _buildSyncBar('Communication', _getRingValue("comm", _selectedDate), const Color(0xFF8784B4), Icons.chat_bubble_outline),
              const SizedBox(height: 16),
              _buildSyncBar('Intimacy', _getRingValue("intimacy", _selectedDate), const Color(0xFFDEA080), Icons.favorite_border),
              const SizedBox(height: 16),
              _buildSyncBar('Patience', _getRingValue("patience", _selectedDate), const Color(0xFF788B7A), Icons.self_improvement),
               const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Today's Influences ──────────────────────────────────────────────────

  // Checklist state: tracked by index
  final List<bool> _doChecked  = [false, false, false];
  final List<bool> _avoidChecked = [false, false, false];

  // Deterministic score 40-99 from date + seed string
  int _score(String seed) {
    final h = (_selectedDate.day * 17 + _selectedDate.month * 31 + seed.hashCode).abs();
    return (h % 60) + 40;
  }

  Widget _buildInfluencesSection() {
    // ── 5 influence cards ─────────────────────────────────────────────────
    final cards = [
      _InfluenceCardData(
        label: 'LOVE',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFDEA080),
        planet: 'Venus trine Moon',
        tip: "Express something you've been holding back.",
        score: _score('love'),
      ),
      _InfluenceCardData(
        label: 'CAREER',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF788B7A),
        planet: 'Sun sextile Saturn',
        tip: 'Ideal for pitching ideas to authority figures.',
        score: _score('career'),
      ),
      _InfluenceCardData(
        label: 'HEALTH',
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF8784B4),
        planet: 'Mars in 6th house',
        tip: 'Physical activity will feel especially rewarding.',
        score: _score('health'),
      ),
      _InfluenceCardData(
        label: 'MINDSET',
        icon: Icons.lightbulb_outline_rounded,
        color: const Color(0xFFE7AD5D),
        planet: 'Mercury sextile Jupiter',
        tip: 'Your mind is sharp — tackle complex problems now.',
        score: _score('mindset'),
      ),
      _InfluenceCardData(
        label: 'TIMING',
        icon: Icons.schedule_rounded,
        color: AppColors.primary,
        planet: 'Moon in 10th house',
        tip: 'Afternoon energies peak. Morning is for planning.',
        score: _score('timing'),
      ),
    ];

    // ── Peak window ───────────────────────────────────────────────────────
    final peakStart = 9 + (_score('peak') % 5); // 9–13
    final peakEnd   = peakStart + 3;
    final peakLabel = '${peakStart > 12 ? peakStart - 12 : peakStart}${peakStart >= 12 ? 'PM' : 'AM'}'
        ' – ${peakEnd > 12 ? peakEnd - 12 : peakEnd}${peakEnd >= 12 ? 'PM' : 'AM'}';

    // ── Do / Avoid lists ─────────────────────────────────────────────────
    final doItems = [
      'Schedule important conversations',
      'Make financial decisions before 3 PM',
      "Reach out to someone you've been distant from",
    ];
    final avoidItems = [
      'Avoid reactive decisions after 6 PM',
      "Don't sign contracts without reading twice",
      'Skip high-intensity workouts — rest is better today',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TODAY'S INFLUENCES",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Horizontal score cards ────────────────────────────────────────
        SizedBox(
          height: 168,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final card = cards[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastEaseInToSlowEaseOut,
                width: 140,
                margin: EdgeInsets.only(right: i < cards.length - 1 ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: card.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + label row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: card.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(card.icon, color: card.color, size: 16),
                        ),
                        const Spacer(),
                        Text(
                          '${card.score}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: card.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Score bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: card.score / 100),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        builder: (context, val, _) => LinearProgressIndicator(
                          value: val,
                          minHeight: 5,
                          backgroundColor: card.color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(card.color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Planet
                    Text(
                      card.planet,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tip
                    Text(
                      card.tip,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Peak timing banner ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.08), const Color(0xFFE7AD5D).withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Peak cosmic window today:  '),
                      TextSpan(
                        text: peakLabel,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Do today ──────────────────────────────────────────────────────
        const Text(
          'DO TODAY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        ...List.generate(doItems.length, (i) => _buildCheckItem(
          doItems[i],
          _doChecked[i],
          const Color(0xFF788B7A),
          () => setState(() => _doChecked[i] = !_doChecked[i]),
        )),
        const SizedBox(height: 16),

        // ── Avoid today ───────────────────────────────────────────────────
        const Text(
          'AVOID TODAY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        ...List.generate(avoidItems.length, (i) => _buildCheckItem(
          avoidItems[i],
          _avoidChecked[i],
          const Color(0xFFDEA080),
          () => setState(() => _avoidChecked[i] = !_avoidChecked[i]),
          isWarning: true,
        )),
      ],
    );
  }

  Widget _buildCheckItem(String text, bool checked, Color color, VoidCallback onTap, {bool isWarning = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastEaseInToSlowEaseOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: checked ? color.withValues(alpha: 0.08) : AppColors.elevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? color.withValues(alpha: 0.3) : AppColors.secondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? color : Colors.transparent,
                border: Border.all(
                  color: checked ? color : color.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                  : (isWarning ? Icon(Icons.close_rounded, size: 12, color: color.withValues(alpha: 0.5)) : const SizedBox.shrink()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: checked ? AppColors.textMuted : AppColors.textPrimary,
                  decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: AppColors.textMuted,
                  height: 1.4,
                ),
                child: Text(text),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return CelestialBackground(
      child: Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   // Profile
                   Container(
                     decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha:0.5))),
                     child: InkWell(
                         onTap: () => context.push('/profile'),
                         borderRadius: BorderRadius.circular(24),
                         child: const CircleAvatar(radius: 20, backgroundColor: AppColors.elevated, child: Icon(Icons.person, color: AppColors.primary, size: 20))
                     ),
                   ),
                   // Today Nav
                   GestureDetector(
                     onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.background,
                                  surface: AppColors.surface,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                     },
                     onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                           setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                        } else if (details.primaryVelocity! < 0) {
                           setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                        }
                     },
                     child: AnimatedContainer(
                       duration: const Duration(milliseconds: 300),
                       curve: Curves.easeInOutCubic,
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(24)),
                       child: AnimatedSize(
                         duration: const Duration(milliseconds: 300),
                         curve: Curves.easeInOutCubic,
                         alignment: Alignment.center,
                         child: Row(
                           children: [
                             GestureDetector(
                               onTap: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                               child: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20)
                             ),
                             const SizedBox(width: 8),
                             AnimatedSwitcher(
                               duration: const Duration(milliseconds: 300),
                               layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                                 return Stack(
                                   alignment: Alignment.center,
                                   children: <Widget>[
                                     ...previousChildren,
                                     if (currentChild != null) currentChild,
                                   ],
                                 );
                               },
                               child: Text(_getDateText(), key: ValueKey(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                             ),
                             const SizedBox(width: 8),
                             GestureDetector(
                               onTap: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
                               child: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20)
                             ),
                           ]
                         ),
                       ),
                     ),
                   ),
                   // Score
                   Row(
                     children: [
                       AnimatedSwitcher(
                         duration: const Duration(milliseconds: 300),
                         child: Text('${_getRingValue("score", _selectedDate)}%', key: ValueKey(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       ),
                       const SizedBox(width: 4),
                       const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                     ],
                   )
                ]
              ),
              const SizedBox(height: 32),
              
              // Title
              const Center(
                child: Text('T W O U P L E', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),

              // Data Rings Row
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                     setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                  } else if (details.primaryVelocity! < 0) {
                     setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                  }
                },
                child: Row(
                  key: ValueKey(_selectedDate),
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRing('ENERGY', _getRingValue('energy', _selectedDate), const Color(0xFFE7AD5D), 'Physical drive based on Sun aspect.'),
                    _buildRing('LOGIC', _getRingValue('logic', _selectedDate), const Color(0xFF8784B4), 'Rational speed (Mercury in 3rd House).'),
                    _buildRing('CAREER', _getRingValue('career', _selectedDate), const Color(0xFF788B7A), 'Material goals (Midheaven aspect).'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Twin Monitors (Rectangles)
              Row(
                children: [
                   Expanded(
                     child: GestureDetector(
                       onTap: () => _openSyncPopup(context),
                       child: Container(
                         height: 120,
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [AppColors.surface, AppColors.elevated],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                               const Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Text('PARTNER\nSYNC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textPrimary)),
                                   Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 16),
                                 ]
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('${_getRingValue("sync", _selectedDate)}%', style: const TextStyle(color: Color(0xFFDEA080), fontWeight: FontWeight.bold, fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Text(_getRingValue("sync", _selectedDate) > 65 ? 'STRONG' : 'FAIR', style: const TextStyle(color: Color(0xFFDEA080), fontWeight: FontWeight.w900, fontSize: 12)),
                                ]
                              )
                           ]
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                      child: GestureDetector(
                        onTap: () => _openGraphPopup(context),
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.surface, AppColors.elevated],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ENERGY\nTREND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textPrimary)),
                                    Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 16),
                                  ]
                               ),
                               Row(
                                 crossAxisAlignment: CrossAxisAlignment.baseline,
                                 textBaseline: TextBaseline.alphabetic,
                                 children: [
                                   Text('8.2', style: const TextStyle(color: Color(0xFFDEA080), fontWeight: FontWeight.bold, fontSize: 24)),
                                   const SizedBox(width: 8),
                                   const Text('HIGH', style: TextStyle(color: Color(0xFFDEA080), fontWeight: FontWeight.w900, fontSize: 12)),
                                 ]
                               )
                            ]
                          ),
                        ),
                      ),
                    )
                ]
              ),
              const SizedBox(height: 32),

              // My Day
              const Text('My Day', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.3)),
              const SizedBox(height: 16),
              
              // Daily Outlook (Hero to Full Insight)
              const _AnimatedOutlookCard(),
              const SizedBox(height: 24),

              _buildInfluencesSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _AnimatedOutlookCard extends StatefulWidget {
  const _AnimatedOutlookCard();

  @override
  State<_AnimatedOutlookCard> createState() => _AnimatedOutlookCardState();
}

class _AnimatedOutlookCardState extends State<_AnimatedOutlookCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'insight_card',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/daily-insight'),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface,
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.surface,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    // A very wide distance (4 units) so the gradient is extremely gentle
                    // It moves from left to right as the controller goes 0->1
                    begin: Alignment(-4.0 + (_controller.value * 6), 0.0),
                    end: Alignment(0.0 + (_controller.value * 6), 0.0),
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: AppColors.primary.withValues(alpha: 0.2),
                        boxShadow: [
                           BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1)
                        ]
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20)
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Daily Outlook', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary, letterSpacing: 0.2)),
                          SizedBox(height: 6),
                          Text(
                            'The moon\'s alignment with Venus today signals a sudden shift in how you process intimacy...',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      )
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20)
                  ]
                )
              );
            }
          ),
        ),
      ),
    );
  }
}

class _PartnerSyncView extends StatefulWidget {
  const _PartnerSyncView();

  @override
  State<_PartnerSyncView> createState() => _PartnerSyncViewState();
}

enum SyncPhase { input, splash, synced }

class _PartnerSyncViewState extends State<_PartnerSyncView> with SingleTickerProviderStateMixin {
  final TextEditingController _partnerPhoneController = TextEditingController();
  bool _isLoading = false;
  SyncPhase _phase = SyncPhase.input;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _partnerPhoneController.dispose();
    super.dispose();
  }

  void _syncPartner() async {
    if (_partnerPhoneController.text.length != 10) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _phase = SyncPhase.splash;
    });

    // Automatically transition to the dashboard
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _phase = SyncPhase.synced);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CelestialBackground(
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          switchInCurve: Curves.fastEaseInToSlowEaseOut,
          switchOutCurve: Curves.fastEaseInToSlowEaseOut,
          child: _buildCurrentPhase(),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case SyncPhase.input:
        return Padding(
          key: const ValueKey('input'),
          padding: const EdgeInsets.all(28.0),
          child: _buildInputState(),
        );
      case SyncPhase.splash:
        return Padding(
          key: const ValueKey('splash'),
          padding: const EdgeInsets.all(28.0),
          child: _buildSplashState(),
        );
      case SyncPhase.synced:
        return KeyedSubtree(
          key: const ValueKey('synced'),
          child: _buildSyncedState(),
        );
    }
  }

  Widget _buildInputState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.connect_without_contact_rounded,
              size: 64,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Joint Alignment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'Invite someone special to link charts. Our AI will automatically generate deep personalized astrological insights spanning both of your lives.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          label: "Partner's phone number",
          hint: 'e.g. 9876543210',
          controller: _partnerPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text('+91 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        ),
        const Spacer(),
        CustomButton(
          text: 'Send Invitation',
          isLoading: _isLoading,
          onPressed: _syncPartner,
        ),
      ],
    );
  }

  Widget _buildSplashState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140 + (_pulseController.value * 20),
                    height: 140 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.1 + (0.2 * (1 - _pulseController.value))),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.1 + (0.1 * _pulseController.value)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2 * _pulseController.value),
                          blurRadius: 20 * _pulseController.value,
                          spreadRadius: 5 * _pulseController.value,
                        )
                      ]
                    ),
                    child: const Icon(Icons.flare_rounded, color: AppColors.secondary, size: 48),
                  ),
                ],
              );
            }
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Cosmic Alignment\nComplete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        Text(
          "Unlocking your shared relationship dashboard...",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSyncedState() {
    return CustomScrollView(
      slivers: [
         SliverToBoxAdapter(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
             child: Column(
               children: [
                 const SizedBox(height: 16),
                 Text('RELATIONSHIP HUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textPrimary.withValues(alpha: 0.6))),
                 const SizedBox(height: 24),
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
         
         // Partner Chat / WhatsApp Sync Action
         SliverToBoxAdapter(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: GestureDetector(
               onTap: () {
                  Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => const _PartnerChatPage(),
                    transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ));
               },
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppColors.elevated,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: const Color(0xFF788B7A).withValues(alpha: 0.3)),
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         color: const Color(0xFF788B7A).withValues(alpha: 0.15),
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.forum_rounded, color: Color(0xFF788B7A), size: 20),
                     ),
                     const SizedBox(width: 16),
                     const Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Partner AI Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           SizedBox(height: 4),
                           Text('Sync WhatsApp to analyze real-time relationship metrics.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                         ]
                       ),
                     ),
                     const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                   ],
                 ),
               ),
             ),
           )
         ),

         // Daily Insight
         SliverToBoxAdapter(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.surface],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                       children: [
                         Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                         SizedBox(width: 8),
                         Text('SHARED DAILY INSIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary)),
                       ]
                    ),
                    SizedBox(height: 12),
                    Text('Venus is transiting your shared 7th house today. A perfect evening for vulnerability and deep conversation. Prioritize quality time tonight.', style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
                  ]
                )
             )
           )
         ),

         // Grid of Dynamics
         SliverPadding(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           sliver: SliverGrid.count(
             crossAxisCount: 2,
             childAspectRatio: 1.25,
             mainAxisSpacing: 12,
             crossAxisSpacing: 12,
             children: [
               _buildGridMetricTile('Communication', '94%', Icons.chat_bubble_outline_rounded, const Color(0xFF8784B4)),
               _buildGridMetricTile('Intimacy', '82%', Icons.favorite_border_rounded, const Color(0xFFDEA080)),
               _buildGridMetricTile('Trust', '90%', Icons.shield_outlined, const Color(0xFF788B7A)),
               _buildGridMetricTile('Growth', '75%', Icons.park_outlined, const Color(0xFFE7AD5D)),
             ]
           )
         ),
         
         const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ]
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
            boxShadow: [
               BoxShadow(color: AppColors.background, spreadRadius: 2), // Creates the cutout overlap effect
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

  Widget _buildGridMetricTile(String title, String score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
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
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
            ]
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.5)),
        ]
      )
    );
  }
}

// ─────────────────────────────────────────────
// AI Coach Page
// ─────────────────────────────────────────────

class _AIAssistantView extends StatefulWidget {
  const _AIAssistantView();

  @override
  State<_AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIChatMessage {
  final String text;
  final bool isUser;
  _AIChatMessage({required this.text, required this.isUser});
}

class _AIAssistantViewState extends State<_AIAssistantView>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_AIChatMessage> _messages = [];
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
      _messages.add(_AIChatMessage(text: text, isUser: false));
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
      _messages.add(_AIChatMessage(text: text, isUser: true));
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

class _MoreView extends StatelessWidget {
  const _MoreView();

  // ── Section data ───────────────────────────────────────────────────────────
  static const _kSections = [
    _MoreSection(
      title: 'MY WORLD',
      items: [
        _MoreItem(icon: Icons.person_outline_rounded, label: 'My Profile', subtitle: 'Edit name, photo & birth details', route: '/profile', color: Color(0xFF8784B4)),
        _MoreItem(icon: Icons.circle_outlined, label: 'Birth Chart', subtitle: 'View your full natal chart', route: '/import', color: Color(0xFFDEA080)),
        _MoreItem(icon: Icons.auto_awesome_outlined, label: 'My Zodiac', subtitle: 'Scorpio · Water · Fixed', color: Color(0xFF9C4F36)),
      ],
    ),
    _MoreSection(
      title: 'RELATIONSHIP',
      items: [
        _MoreItem(icon: Icons.people_outline_rounded, label: 'Partner Sync', subtitle: 'Manage your linked partner', color: Color(0xFFDEA080)),
        _MoreItem(icon: Icons.favorite_border_rounded, label: 'Compatibility Report', subtitle: 'Full synastry deep-dive', route: '/paywall', color: Color(0xFFB47B80)),
        _MoreItem(icon: Icons.timeline_rounded, label: 'Relationship Timeline', subtitle: 'Key cosmic milestones', color: Color(0xFF788B7A)),
      ],
    ),
    _MoreSection(
      title: 'EXPLORE',
      items: [
        _MoreItem(icon: Icons.wb_sunny_outlined, label: 'Daily Horoscope', subtitle: 'Today\'s planetary influences', route: '/daily-insight', color: Color(0xFFE7AD5D)),
        _MoreItem(icon: Icons.upload_file_outlined, label: 'Import Chart', subtitle: 'Add a chart from a file', route: '/import', color: Color(0xFF8784B4)),
        _MoreItem(icon: Icons.smart_toy_outlined, label: 'Chat with Aura', subtitle: 'Open the AI coach chatbot', route: '/chatbot', color: Color(0xFF9C4F36)),
      ],
    ),
    _MoreSection(
      title: 'ACCOUNT',
      items: [
        _MoreItem(icon: Icons.notifications_none_rounded, label: 'Notifications', subtitle: 'Daily reminders & alerts', color: Color(0xFF788B7A)),
        _MoreItem(icon: Icons.workspace_premium_outlined, label: 'Upgrade to Premium', subtitle: 'Unlock all cosmic insights', route: '/paywall', color: Color(0xFFE7AD5D), isPremium: true),
        _MoreItem(icon: Icons.lock_outline_rounded, label: 'Privacy & Data', subtitle: 'Manage your information', color: Color(0xFF8784B4)),
      ],
    ),
    _MoreSection(
      title: 'SUPPORT',
      items: [
        _MoreItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', subtitle: 'Answers to common questions', color: Color(0xFF788B7A)),
        _MoreItem(icon: Icons.star_outline_rounded, label: 'Rate Twouple', subtitle: 'Share your experience', color: Color(0xFFE7AD5D)),
        _MoreItem(icon: Icons.mail_outline_rounded, label: 'Contact Support', subtitle: 'We\'re here to help', color: Color(0xFF8784B4)),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildProfileCard(context)),
            // ── Sections ────────────────────────────────────────────────────
            for (final section in _kSections) ...[
              SliverToBoxAdapter(child: _buildSectionHeader(section.title)),
              SliverToBoxAdapter(
                child: _buildSectionCard(context, section.items),
              ),
            ],
            // ── Sign out ────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSignOut(context)),
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.elevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              // Zodiac badge
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name & tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Scorpio · Born under a soulful sky',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Premium badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7AD5D), Color(0xFFDEA080)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  // ── Section card ───────────────────────────────────────────────────────────
  Widget _buildSectionCard(BuildContext context, List<_MoreItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return _buildItem(context, item, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _MoreItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isLast && item == _kSections.last.items.last ? 0 : 0),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        onTap: () {
          if (item.route != null) context.push(item.route!);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  const SizedBox(width: 14),
                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                            if (item.isPremium) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE7AD5D), Color(0xFFDEA080)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                endIndent: 0,
                color: AppColors.elevated,
              ),
          ],
        ),
      ),
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Widget _buildSignOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showSignOutDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ll need to sign back in to access your cosmic insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.go('/landing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _MoreSection {
  final String title;
  final List<_MoreItem> items;
  const _MoreSection({required this.title, required this.items});
}

class _MoreItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? route;
  final Color color;
  final bool isPremium;
  const _MoreItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.route,
    required this.color,
    this.isPremium = false,
  });
}

// ── Influence card data model ─────────────────────────────────────────────────

class _InfluenceCardData {
  final String label;
  final IconData icon;
  final Color color;
  final String planet;
  final String tip;
  final int score;
  const _InfluenceCardData({
    required this.label,
    required this.icon,
    required this.color,
    required this.planet,
    required this.tip,
    required this.score,
  });
}

// ─────────────────────────────────────────────
// Partner Chat Page (AI Synced)
// ─────────────────────────────────────────────

class _PartnerChatPage extends StatefulWidget {
  const _PartnerChatPage();

  @override
  State<_PartnerChatPage> createState() => _PartnerChatPageState();
}

class _PartnerChatPageState extends State<_PartnerChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _messages = [
    "Hey, what did the AI say about us today? 😂"
  ];

  void _showWhatsAppExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sync WhatsApp Chat', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Export your chat from WhatsApp (without media) and upload the .txt file here to get real-time AI relationship insights based on your conversation history.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
             onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Working: WhatsApp sync analyzing...')));
             },
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
             child: const Text('Upload .txt export', style: TextStyle(color: Colors.white)),
          )
        ]
      )
    );
  }

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
       _messages.add(_msgController.text.trim());
       _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
           backgroundColor: AppColors.surface,
           elevation: 0,
           iconTheme: const IconThemeData(color: AppColors.textPrimary),
           title: const Row(
             children: [
                CircleAvatar(
                   backgroundColor: Color(0xFFDEA080),
                   radius: 16,
                   child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
                SizedBox(width: 8),
                Text('Emily & You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
             ]
           ),
           actions: [
             IconButton(
               icon: const Icon(Icons.psychology_rounded, color: AppColors.primary),
               tooltip: 'Ask AI',
               onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI is analyzing your tone...')));
               },
             ),
             PopupMenuButton<String>(
               icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
               color: AppColors.elevated,
               itemBuilder: (context) => [
                 const PopupMenuItem(
                   value: 'export',
                   child: Text('Sync from WhatsApp', style: TextStyle(color: AppColors.textPrimary)),
                 )
               ],
               onSelected: (val) {
                 if (val == 'export') {
                    _showWhatsAppExportDialog();
                 }
               }
             )
           ]
        ),
        body: Column(
          children: [
             Expanded(
               child: ListView.builder(
                 padding: const EdgeInsets.all(16),
                 itemCount: _messages.length,
                 itemBuilder: (context, i) {
                    final isMe = i > 0;
                    return Align(
                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                       child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                             color: isMe ? AppColors.primary : AppColors.elevated,
                             borderRadius: BorderRadius.circular(16).copyWith(
                                bottomRight: isMe ? const Radius.circular(4) : null,
                                bottomLeft: isMe ? null : const Radius.circular(4),
                             )
                          ),
                          child: Text(_messages[i], style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
                       )
                    );
                 }
               )
             ),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.1))),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                       IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
                          onPressed: () {},
                       ),
                       Expanded(
                          child: TextField(
                             controller: _msgController,
                             style: const TextStyle(color: AppColors.textPrimary),
                             decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.elevated,
                                border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(24),
                                   borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                             ),
                             onSubmitted: (_) => _send(),
                          )
                       ),
                       const SizedBox(width: 4),
                       Container(
                         decoration: const BoxDecoration(
                           color: AppColors.primary,
                           shape: BoxShape.circle,
                         ),
                         child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: _send,
                         ),
                       ),
                    ]
                  ),
                )
             )
          ]
        )
     );
  }
}


