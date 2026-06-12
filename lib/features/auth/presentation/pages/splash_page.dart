import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../api/user_api.dart';

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
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final userApi = UserApi();
        final profile = await userApi.getCurrentUser();
        if (mounted) {
          if (profile.fullName == null || profile.fullName!.isEmpty) {
            context.go('/onboarding/birth');
          } else {
            context.go('/home');
          }
        }
        return;
      } catch (e) {
        // Token invalid or network error
        await TokenManager.deleteToken();
      }
    }

    if (mounted) {
      context.go('/landing');
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
