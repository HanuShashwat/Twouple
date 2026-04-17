import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import 'views/dashboard_view.dart';
import 'views/partner_sync_view.dart';
import 'views/ai_assistant_view.dart';
import 'views/more_view.dart';

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
          DashboardView(),
          SizedBox.shrink(),
          AIAssistantView(),
          MoreView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          if (idx == 1) {
             Navigator.push(context, PageRouteBuilder(
               pageBuilder: (context, anim1, anim2) => const PartnerSyncView(),
               transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
               transitionDuration: const Duration(milliseconds: 300),
             ));
             return;
          }
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
            label: 'Sync',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
            label: 'Guru',
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

