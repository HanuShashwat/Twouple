import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Simulate checking a token
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/phone-input');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }
}
