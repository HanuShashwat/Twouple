import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/phone_input_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/otp_verify_page.dart';
import '../../features/auth/presentation/pages/onboarding_birth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/mode_selector_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/chat/presentation/pages/native_chat_page.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/subscription/presentation/pages/paywall_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/phone-input',
        builder: (context, state) => const PhoneInputPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) => const OtpVerifyPage(),
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
    ],
  );
}
