import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/parent_login_screen.dart';
import '../../presentation/screens/auth/kid_login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/parent/dashboard/parent_dashboard_screen.dart';
import '../../presentation/screens/parent/analytics/parent_analytics_screen.dart';
import '../../presentation/screens/parent/settings/parent_settings_screen.dart';
import '../../presentation/screens/parent/profile/add_kid_screen.dart';
import '../../presentation/screens/kid/dashboard/kid_dashboard_screen.dart';
import '../../presentation/screens/kid/quiz/quiz_screen.dart';
import '../../presentation/screens/kid/quiz/quiz_result_screen.dart';
import '../../presentation/screens/kid/games/games_screen.dart';
import '../../presentation/screens/kid/games/game_play_screen.dart';
import '../../presentation/screens/kid/speaking/speaking_screen.dart';
import '../../presentation/screens/kid/achievements/achievements_screen.dart';

part 'app_router.g.dart';

// Route names
class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const parentLogin = '/parent-login';
  static const kidLogin = '/kid-login';
  static const register = '/register';
  static const parentDashboard = '/parent';
  static const parentAnalytics = '/parent/analytics';
  static const parentSettings = '/parent/settings';
  static const addKid = '/parent/add-kid';
  static const kidDashboard = '/kid';
  static const quiz = '/kid/quiz';
  static const quizResult = '/kid/quiz/result';
  static const games = '/kid/games';
  static const gamePlay = '/kid/games/play';
  static const speaking = '/kid/speaking';
  static const achievements = '/kid/achievements';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.parentLogin,
        builder: (context, state) => const ParentLoginScreen(),
      ),
      GoRoute(
        path: Routes.kidLogin,
        builder: (context, state) => const KidLoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.parentDashboard,
        builder: (context, state) => const ParentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const ParentAnalyticsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const ParentSettingsScreen(),
          ),
          GoRoute(
            path: 'add-kid',
            builder: (context, state) => const AddKidScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.kidDashboard,
        builder: (context, state) => const KidDashboardScreen(),
        routes: [
          GoRoute(
            path: 'quiz',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return QuizScreen(
                subject: extra?['subject'] ?? 'Mathematics',
                kidId: extra?['kidId'] ?? '',
              );
            },
          ),
          GoRoute(
            path: 'quiz/result',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return QuizResultScreen(resultData: extra);
            },
          ),
          GoRoute(
            path: 'games',
            builder: (context, state) => const GamesScreen(),
          ),
          GoRoute(
            path: 'games/play',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return GamePlayScreen(gameId: extra['gameId']);
            },
          ),
          GoRoute(
            path: 'speaking',
            builder: (context, state) => const SpeakingScreen(),
          ),
          GoRoute(
            path: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
