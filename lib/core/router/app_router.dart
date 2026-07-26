import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/onboarding_birth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/daily_insight_page.dart';
import '../../features/home/presentation/pages/mode_selector_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/chat/presentation/pages/native_chat_page.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/subscription/presentation/pages/paywall_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/auth/token_manager.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(TokenManager.authStateStream),
    redirect: (context, state) async {
      final isLoggedIn = await TokenManager.hasValidToken();
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/auth' || state.matchedLocation == '/landing';
      
      if (!isLoggedIn && !isSplash && !isAuth) {
        return '/landing';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/onboarding-birth',
        builder: (context, state) => const OnboardingBirthPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/daily-insight',
        builder: (context, state) => const DailyInsightPage(),
      ),
      GoRoute(
        path: '/mode-selector',
        builder: (context, state) => const ModeSelectorPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),
      GoRoute(
        path: '/native-chat',
        builder: (context, state) => const NativeChatPage(),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportPage(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallPage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
    ],
  );
}
