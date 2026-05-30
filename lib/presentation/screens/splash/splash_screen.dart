import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      context.go(Routes.parentLogin);
    } else {
      // User is signed in — go to parent dashboard
      // (kid login is PIN-based from within the parent dashboard)
      context.go(Routes.parentDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF3B0E8C), Color(0xFF6C3FE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryYellow,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryYellow.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🥷', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App name
                  const Text(
                    'NinjaKids',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 40,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn Smart. Play Smart.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Loading dots
                  _buildLoadingDots(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1.0),
          duration: Duration(milliseconds: 600 + i * 150),
          curve: Curves.easeInOut,
          builder: (context, value, _) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.secondaryYellow.withValues(alpha: value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
