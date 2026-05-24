import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/features/auth/splash_screen.dart';
import 'package:ninjakids/features/auth/parent_login_screen.dart';
import 'package:ninjakids/features/auth/parent_register_screen.dart';
import 'package:ninjakids/features/auth/child_pin_screen.dart';
import 'package:ninjakids/features/auth/child_pin_direct_screen.dart';
import 'package:ninjakids/features/parent/parent_dashboard.dart';
import 'package:ninjakids/features/parent/create_child_profile.dart';
import 'package:ninjakids/features/parent/screen_time_manager.dart';
import 'package:ninjakids/features/child/child_dashboard.dart';
import 'package:ninjakids/features/child/subjects_screen.dart';
import 'package:ninjakids/features/quiz/quiz_screen.dart';
import 'package:ninjakids/features/quiz/quiz_result_screen.dart';
import 'package:ninjakids/features/speaking/speaking_screen.dart';
import 'package:ninjakids/features/ai_tutor/ai_tutor_screen.dart';
import 'package:ninjakids/features/settings/settings_screen.dart';
import 'package:ninjakids/features/parent/child_management_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const parentLogin = '/parent-login';
  static const parentRegister = '/parent-register';
  static const parentDashboard = '/parent-dashboard';
  static const createChild = '/create-child';
  static const childPin = '/child-pin';
  static const childPinDirect = '/child-pin-direct';  // standalone child login
  static const childDashboard = '/child-dashboard';
  static const subjects = '/subjects';
  static const games = '/games';
  static const rewards = '/rewards';
  static const childProfile = '/child-profile';
  static const quiz = '/quiz';
  static const quizResult = '/quiz-result';
  static const speaking = '/speaking';
  static const aiTutor = '/ai-tutor';
  static const screenTime = '/screen-time';
  static const subjectAccess = '/subject-access';
  static const progressAnalytics = '/progress-analytics';
  static const settings = '/settings';
  static const subscription = '/subscription';
  static const childManagement = '/child-management';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // Pages where auto-redirect applies (if already logged in, skip them)
      final parentAuthPages = [AppRoutes.parentLogin, AppRoutes.parentRegister];
      final isParentAuthPage = parentAuthPages.contains(loc);
      final isSplash = loc == AppRoutes.splash;

      // If logged-in parent tries to open parent auth pages or splash → send to dashboard
      if (authState.isLoggedIn && authState.isParent && (isSplash || isParentAuthPage)) {
        return AppRoutes.parentDashboard;
      }
      // If logged-in child tries to open splash → send to child dashboard
      if (authState.isLoggedIn && !authState.isParent && isSplash) {
        return AppRoutes.childDashboard;
      }
      // childPinDirect is always accessible — child picks their profile there
      // No redirect away from childPinDirect even if logged in
      return null;
    },
    routes: [
      // ─── Auth ────────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.parentLogin, builder: (_, __) => const ParentLoginScreen()),
      GoRoute(path: AppRoutes.parentRegister, builder: (_, __) => const ParentRegisterScreen()),

      // Standalone child login (from splash — no parent session needed on this device)
      GoRoute(path: AppRoutes.childPinDirect, builder: (_, __) => const ChildPinDirectScreen()),

      // Child PIN from parent dashboard (parent already logged in, taps child)
      GoRoute(
        path: AppRoutes.childPin,
        builder: (_, state) => ChildPinScreen(childId: state.extra as String? ?? ''),
      ),

      // ─── Parent ────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.parentDashboard, builder: (_, __) => const ParentDashboard()),
      GoRoute(path: AppRoutes.createChild, builder: (_, __) => const CreateChildProfile()),
      GoRoute(path: AppRoutes.screenTime, builder: (_, __) => const ScreenTimeManager()),
      GoRoute(
        path: AppRoutes.subjectAccess,
        builder: (_, state) => SubjectAccessScreen(childId: state.extra as String? ?? ''),
      ),
      GoRoute(path: AppRoutes.progressAnalytics, builder: (_, __) => const ProgressAnalyticsScreen()),
      GoRoute(
        path: AppRoutes.childManagement,
        builder: (_, state) => ChildManagementScreen(childId: state.extra as String? ?? ''),
      ),

      // ─── Child ──────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.childDashboard, builder: (_, __) => const ChildDashboard()),
      GoRoute(path: AppRoutes.subjects, builder: (_, __) => const SubjectsScreen()),
      GoRoute(path: AppRoutes.games, builder: (_, __) => const GamesScreen()),
      GoRoute(path: AppRoutes.rewards, builder: (_, __) => const RewardsScreen()),
      GoRoute(path: AppRoutes.childProfile, builder: (_, __) => const ChildProfileScreen()),

      // ─── Features ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.quiz,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return QuizScreen(subject: extra['subject'] ?? 'Mathematics', difficulty: extra['difficulty'] ?? 'Easy');
        },
      ),
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return QuizResultScreen(
            subject: extra['subject'] ?? '', correct: extra['correct'] ?? 0,
            total: extra['total'] ?? 0, xpEarned: extra['xpEarned'] ?? 0, coinsEarned: extra['coinsEarned'] ?? 0,
          );
        },
      ),
      GoRoute(path: AppRoutes.speaking, builder: (_, state) => SpeakingScreen(subject: state.extra as String? ?? 'English')),
      GoRoute(path: AppRoutes.aiTutor, builder: (_, __) => const AiTutorScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: AppRoutes.subscription, builder: (_, __) => const SubscriptionScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go(AppRoutes.splash), child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );
});
