import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

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


  @override
  void dispose() {
    _promptController.dispose();
    _chartPageController.dispose();
    super.dispose();
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
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textPrimary)
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
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
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
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
                    colors: [Colors.amberAccent, AppColors.primary],
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
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
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
                child: Hero(
                  tag: 'energy_trend_hero',
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
                          Row(
                            children: [
                              Text(
                                currentChartPage == 0 ? 'Energy Trend (Previous Week)' : 'Energy Trend (Upcoming Week)', 
                                style: const TextStyle(fontWeight: FontWeight.bold)
                              ),
                              const Spacer(),
                              const Icon(Icons.swipe_rounded, size: 16, color: AppColors.textSecondary),
                            ],
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
                              child: currentChartPage == 0 
                                  ? _buildLineChartWidget(pastSpots, _getDaysMap(true))
                                  : _buildLineChartWidget(futureSpots, _getDaysMap(false)),
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
                                  borderRadius: BorderRadius.circular(6)
                                )
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: currentChartPage == 1 ? 8 : 6, 
                                height: 6, 
                                decoration: BoxDecoration(
                                  color: currentChartPage == 1 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3), 
                                  borderRadius: BorderRadius.circular(6)
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
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

  void _openVibePopup(BuildContext context) {
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
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), 
                    child: const Icon(Icons.check, color: AppColors.background, size: 20)
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: Text('Vibe Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary))),
                ]
              ),
              const SizedBox(height: 16),
              const Text(
                'Your overall frequency is currently operating in an Optimal Range. The cosmic alignment today provides an excellent baseline for stable emotions and grounded decisions.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
              ),
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

  Widget _buildListTile(String title, String subtitle, IconData icon, Color color) {
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
             Container(
               width: 48,
               height: 48,
               decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
               child: Icon(icon, color: color),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                 ]
               )
             )
          ]
        )
     );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background, // WHOOP is very dark flat
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
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(24)),
                     child: const Row(
                       children: [
                         Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
                         SizedBox(width: 8),
                         Text('TODAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                         SizedBox(width: 8),
                         Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                       ]
                     ),
                   ),
                   // Score
                   const Row(
                     children: [
                       Text('85%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       SizedBox(width: 4),
                       Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRing('ENERGY', 78, Colors.amberAccent, 'Physical drive based on Sun aspect.'),
                  _buildRing('LOGIC', 92, Colors.lightBlueAccent, 'Rational speed (Mercury in 3rd House).'),
                  _buildRing('CAREER', 60, Colors.purpleAccent, 'Material goals (Midheaven aspect).'),
                ],
              ),
              const SizedBox(height: 32),

              // Twin Monitors (Rectangles)
              Row(
                children: [
                   Expanded(
                     child: GestureDetector(
                       onTap: () => _openVibePopup(context),
                       child: Container(
                         height: 120,
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(16)),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('VIBE\nMONITOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                                ]
                              ),
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), child: const Icon(Icons.check, color: AppColors.background, size: 12)),
                                  const SizedBox(width: 8),
                                  const Text('OPTIMAL\nRANGE', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ]
                              )
                           ]
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Hero(
                       tag: 'energy_trend_hero',
                       child: Material(
                         color: Colors.transparent,
                         child: GestureDetector(
                           onTap: () => _openGraphPopup(context),
                           child: Container(
                             height: 120,
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               gradient: const LinearGradient(
                                 colors: [Color(0xFF33200B), AppColors.elevated], // Deep cosmic amber gradient
                                 begin: Alignment.topLeft,
                                 end: Alignment.bottomRight,
                               ),
                               borderRadius: BorderRadius.circular(16),
                             ),
                             child: const Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ENERGY\nTREND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                                    ]
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('8.2', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 24)),
                                      SizedBox(width: 8),
                                      Text('HIGH', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                                    ]
                                  )
                               ]
                             ),
                           ),
                         ),
                       ),
                     ),
                   )
                ]
              ),
              const SizedBox(height: 32),

              // My Day
              const Text('My Day', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Daily Outlook (Hero to Full Insight)
              Hero(
                tag: 'insight_card',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/daily-insight'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                           Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.2)),
                              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16)
                           ),
                           const SizedBox(width: 16),
                           const Expanded(child: Text('Daily Outlook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                           const Icon(Icons.chevron_right, color: AppColors.textSecondary)
                        ]
                      )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Today's Activities
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TODAY'S INFLUENCES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textSecondary)),
                  Icon(Icons.open_in_full_rounded, size: 14, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildListTile('Positives', 'Financial gains strongly favored.', Icons.trending_up_rounded, Colors.greenAccent),
              const SizedBox(height: 8),
              _buildListTile('Precautions', 'Avoid arguments around 5 PM.', Icons.warning_amber_rounded, Colors.redAccent),
              const SizedBox(height: 48), // Padding bottom
            ],
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

class _PartnerSyncViewState extends State<_PartnerSyncView> {
  final TextEditingController _partnerPhoneController = TextEditingController();
  bool _isLoading = false;

  void _syncPartner() async {
    if (_partnerPhoneController.text.length != 10) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation sent successfully! Awaiting their approval.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      _partnerPhoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background,
            Color(0xFF101320),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
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
          ),
        ),
      ),
    );
  }
}

class _AIAssistantView extends StatefulWidget {
  const _AIAssistantView();

  @override
  State<_AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<_AIAssistantView> {
  final TextEditingController _promptController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Twouple AI Assistant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('How can the cosmos guide you today?', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Ask anything about your charts...",
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    border: InputBorder.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_upward_rounded, color: AppColors.background, size: 20),
                        ),
                        onPressed: () {
                           if(_promptController.text.isNotEmpty) {
                              context.push('/chatbot');
                              _promptController.clear();
                           }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const SafeArea(
        child: Center(
          child: Text('Settings & More', style: TextStyle(color: AppColors.textSecondary, fontSize: 24)),
        ),
      ),
    );
  }
}
