import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
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
          _PartnerSyncView(),
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
            icon: Icon(Icons.people_outline_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Joint Sync',
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
  int _currentChartPage = 1;

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
              SizedBox(
                height: 60,
                width: 60,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percentage / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surface,
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartWidget(List<FlSpot> spots, List<String> daysMap) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) => LineTooltipItem(
                  'Energy Score: ${spot.y}\n${daysMap[spot.x.toInt()]}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
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
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _buildLineChartSection() {
    final pastSpots = const [
      FlSpot(0, 5), FlSpot(1, 4.5), FlSpot(2, 3), FlSpot(3, 4), FlSpot(4, 6), FlSpot(5, 5.5), FlSpot(6, 4)
    ];
    final futureSpots = const [
      FlSpot(0, 4), FlSpot(1, 3.5), FlSpot(2, 5), FlSpot(3, 6), FlSpot(4, 5.5), FlSpot(5, 7), FlSpot(6, 6.5)
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _currentChartPage == 0 ? 'Energy Trend (Previous 7 Days)' : 'Energy Trend (Upcoming 7 Days)', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              const Icon(Icons.swipe_rounded, size: 16, color: AppColors.textSecondary),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 4, decoration: BoxDecoration(color: _currentChartPage == 0 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 4),
              Container(width: 8, height: 4, decoration: BoxDecoration(color: _currentChartPage == 1 ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _chartPageController,
              onPageChanged: (idx) => setState(() => _currentChartPage = idx),
              children: [
                _buildLineChartWidget(pastSpots, _getDaysMap(true)),
                _buildLineChartWidget(futureSpots, _getDaysMap(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Elemental Balance', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                       final elements = ['Fire (Action/Passion)', 'Earth (Stability)', 'Air (Intellect)', 'Water (Emotion/Intuition)'];
                       return BarTooltipItem(
                         '${elements[group.x.toInt()]}\n${rod.toY.toInt()}%',
                         const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                       );
                    }
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Fire', style: TextStyle(fontSize: 10, color: Colors.orangeAccent));
                          case 1: return const Text('Earth', style: TextStyle(fontSize: 10, color: Colors.greenAccent));
                          case 2: return const Text('Air', style: TextStyle(fontSize: 10, color: Colors.lightBlueAccent));
                          case 3: return const Text('Water', style: TextStyle(fontSize: 10, color: Colors.blueAccent));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Colors.orangeAccent, width: 20, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 40, color: Colors.greenAccent, width: 20, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 60, color: Colors.lightBlueAccent, width: 20, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 90, color: Colors.blueAccent, width: 20, borderRadius: BorderRadius.circular(6))]),
                ],
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F1525), // Deeper cosmic blue
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good evening',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String username = 'Guest';
                          if (state is AuthAuthenticated) {
                            username = state.user.name.split(' ').first; // Extract first name
                          }
                          return Text(
                            username,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                          );
                        },
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/profile'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Insight Briefing Card
              Hero(
                tag: 'insight_card',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/daily-insight'),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.secondary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Today's Insight",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Mercury has entered your 7th house—expect sudden moments of deep clarity. Focus heavily on communication with those you trust today.",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  fontSize: 15,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Data Rings Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRing('Energy', 78, Colors.amberAccent, 'Your pure life-force and physical drive today based on Sun alignments.'),
                  _buildRing('Logic', 92, Colors.lightBlueAccent, 'Your rational processing speed dictated by Mercury in the 3rd House.'),
                  _buildRing('Career', 60, Colors.purpleAccent, 'Material goals and public recognition linked to your Midheaven aspect.'),
                ],
              ),
              const SizedBox(height: 24),

              // Graphs Zone
              _buildLineChartSection(),
              const SizedBox(height: 24),
              _buildBarChart(),
              const SizedBox(height: 48),

              // Chatbot Master Search Bar (Relocated to bottom)
              Text(
                'Ask the Universe',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.elevated,
                    hintText: "What do the stars say about my career?",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_upward_rounded, color: AppColors.background, size: 20),
                        ),
                        onPressed: () {
                          if (_promptController.text.isNotEmpty) {
                            context.push('/chatbot');
                            _promptController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
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
