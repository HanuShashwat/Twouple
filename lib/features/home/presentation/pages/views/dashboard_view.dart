import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/celestial_background.dart';

class DashboardView extends StatefulWidget {
  const DashboardView();

  @override
  State<DashboardView> createState() => DashboardViewState();
}


class DashboardViewState extends State<DashboardView> {
  final TextEditingController _promptController = TextEditingController();
  final PageController _chartPageController = PageController(initialPage: 1);
  DateTime _selectedDate = DateTime.now();

  int? _expandedInfluenceIdx;

  final List<String> _userDoItems = [
    'Schedule important conversations',
    'Make financial decisions before 3 PM',
    "Reach out to someone you've been distant from",
  ];
  final List<bool> _userDoChecked = [false, false, false];
  
  final List<String> _userAvoidItems = [
    'Avoid reactive decisions after 6 PM',
    "Don't sign contracts without reading twice",
    'Skip high-intensity workouts — rest is better today',
  ];
  final List<bool> _userAvoidChecked = [false, false, false];

  bool _isAddingDo = false;
  bool _isAddingAvoid = false;
  final TextEditingController _customDoController = TextEditingController();
  final TextEditingController _customAvoidController = TextEditingController();


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
  // Deterministic score 40-99 from date + seed string
  int _score(String seed) {
    final h = (_selectedDate.day * 17 + _selectedDate.month * 31 + seed.hashCode).abs();
    return (h % 60) + 40;
  }

  Widget _buildInfluencesSection() {
    // ── 5 influence cards ─────────────────────────────────────────────────
    final cards = [
      InfluenceCardData(
        label: 'LOVE',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFDEA080),
        planet: 'Venus trine Moon',
        tip: "Express something you've been holding back.",
        score: _score('love'),
      ),
      InfluenceCardData(
        label: 'CAREER',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF788B7A),
        planet: 'Sun sextile Saturn',
        tip: 'Ideal for pitching ideas to authority figures.',
        score: _score('career'),
      ),
      InfluenceCardData(
        label: 'HEALTH',
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF8784B4),
        planet: 'Mars in 6th house',
        tip: 'Physical activity will feel especially rewarding.',
        score: _score('health'),
      ),
      InfluenceCardData(
        label: 'MINDSET',
        icon: Icons.lightbulb_outline_rounded,
        color: const Color(0xFFE7AD5D),
        planet: 'Mercury sextile Jupiter',
        tip: 'Your mind is sharp — tackle complex problems now.',
        score: _score('mindset'),
      ),
      InfluenceCardData(
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
              return InteractiveInfluenceCard(
                 card: cards[i],
                 isLast: i == cards.length - 1,
                 isExpanded: _expandedInfluenceIdx == i,
                 onTap: () {
                    setState(() {
                       if (_expandedInfluenceIdx == i) {
                          _expandedInfluenceIdx = null;
                       } else {
                          _expandedInfluenceIdx = i;
                       }
                    });
                 },
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
        ...List.generate(_userDoItems.length, (i) => Dismissible(
          key: ValueKey('do_${_userDoItems[i]}_$i'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              _userDoItems.removeAt(i);
              _userDoChecked.removeAt(i);
            });
          },
          child: _buildCheckItem(
            _userDoItems[i],
            _userDoChecked[i],
            const Color(0xFF788B7A),
            () => setState(() => _userDoChecked[i] = !_userDoChecked[i]),
          ),
        )),
        _buildCustomAddInput('Do', _isAddingDo, _customDoController, const Color(0xFF788B7A), () => setState(() => _isAddingDo = true), (val) {
           if (val.trim().isNotEmpty) {
             setState(() {
                _userDoItems.add(val.trim());
                _userDoChecked.add(false);
             });
           }
           setState(() {
             _isAddingDo = false;
             _customDoController.clear();
           });
        }),
        const SizedBox(height: 16),

        // ── Avoid today ───────────────────────────────────────────────────
        const Text(
          'AVOID TODAY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        ...List.generate(_userAvoidItems.length, (i) => Dismissible(
          key: ValueKey('avoid_${_userAvoidItems[i]}_$i'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              _userAvoidItems.removeAt(i);
              _userAvoidChecked.removeAt(i);
            });
          },
          child: _buildCheckItem(
            _userAvoidItems[i],
            _userAvoidChecked[i],
            const Color(0xFFDEA080),
            () => setState(() => _userAvoidChecked[i] = !_userAvoidChecked[i]),
            isWarning: true,
          ),
        )),
        _buildCustomAddInput('Avoid', _isAddingAvoid, _customAvoidController, const Color(0xFFDEA080), () => setState(() => _isAddingAvoid = true), (val) {
           if (val.trim().isNotEmpty) {
             setState(() {
                _userAvoidItems.add(val.trim());
                _userAvoidChecked.add(false);
             });
           }
           setState(() {
             _isAddingAvoid = false;
             _customAvoidController.clear();
           });
        }),
      ],
    );
  }

  Widget _buildCustomAddInput(String type, bool isAdding, TextEditingController controller, Color color, VoidCallback onAdd, ValueChanged<String> onSubmitted) {
     if (!isAdding) {
       return GestureDetector(
         onTap: onAdd,
         child: Container(
           margin: const EdgeInsets.only(bottom: 8),
           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
           decoration: BoxDecoration(
             color: AppColors.elevated,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
           ),
           child: Row(
             children: [
                Icon(Icons.add_rounded, color: color, size: 20),
                const SizedBox(width: 12),
                Text('Add custom $type...', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
             ],
           ),
         ),
       );
     }
     
     return Container(
       margin: const EdgeInsets.only(bottom: 8),
       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
       decoration: BoxDecoration(
         color: AppColors.elevated,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: color.withValues(alpha: 0.3)),
       ),
       child: TextField(
         controller: controller,
         autofocus: true,
         style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
         decoration: InputDecoration(
            hintText: 'Enter a custom $type...',
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
            border: InputBorder.none,
         ),
         onSubmitted: onSubmitted,
       ),
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
              const AnimatedOutlookCard(),
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


class AnimatedOutlookCard extends StatefulWidget {
  const AnimatedOutlookCard();

  @override
  State<AnimatedOutlookCard> createState() => AnimatedOutlookCardState();
}


class AnimatedOutlookCardState extends State<AnimatedOutlookCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
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


class InfluenceCardData {
  final String label;
  final IconData icon;
  final Color color;
  final String planet;
  final String tip;
  final int score;
  const InfluenceCardData({
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


class InteractiveInfluenceCard extends StatelessWidget {
  final InfluenceCardData card;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback onTap;

  const InteractiveInfluenceCard({
    required this.card, 
    required this.isLast,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,
        width: isExpanded ? 240 : 140,
        margin: EdgeInsets.only(right: isLast ? 0 : 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpanded ? card.color.withValues(alpha: 0.05) : AppColors.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: card.color.withValues(alpha: isExpanded ? 0.4 : 0.2)),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: Text(
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
                secondChild: Text(
                  card.tip,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              ),
            ],
          ),
        ),
      ),
    );
  }
}




