import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _floatController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textController);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (auth.isLoggedIn) {
      if (auth.isParent) {
        context.go(AppRoutes.parentDashboard);
      } else {
        context.go(AppRoutes.childDashboard);
      }
    }
    // Stay on splash for manual navigation via buttons
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background floating elements
            ..._buildFloatingElements(size),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    ),
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _buildLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFB84C), Color(0xFFFF6B35)],
                            ).createShader(bounds),
                            child: Text(
                              'NinjaKids',
                              style: GoogleFonts.poppins(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Learn • Play • Level Up',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          GradientButton(
                            text: '🚀 Get Started',
                            colors: AppColors.goldGradient,
                            onTap: () => context.go(AppRoutes.parentRegister),
                          ),
                          const SizedBox(height: 16),
                          OutlineButton(
                            text: '👨‍👩‍👧 Parent Login',
                            color: Colors.white,
                            onTap: () => context.go(AppRoutes.parentLogin),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      'AI-Powered Learning for Every Child',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dark circle background
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A1A2E),
            ),
          ),
          // Ninja emoji
          const Text('🥷', style: TextStyle(fontSize: 72)),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    final elements = [
      ('⭐', 0.1, 0.15, 24.0),
      ('📚', 0.85, 0.12, 28.0),
      ('🔢', 0.05, 0.45, 22.0),
      ('💡', 0.88, 0.42, 26.0),
      ('🎯', 0.15, 0.78, 24.0),
      ('🏆', 0.8, 0.75, 28.0),
      ('⚡', 0.45, 0.08, 20.0),
      ('🌟', 0.5, 0.88, 22.0),
    ];

    return elements.map((e) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) => Positioned(
          left: e.$2 * MediaQuery.of(context).size.width,
          top: e.$3 * MediaQuery.of(context).size.height + (_floatAnim.value * 0.5),
          child: Opacity(
            opacity: 0.3,
            child: Text(e.$1, style: TextStyle(fontSize: e.$4)),
          ),
        ),
      );
    }).toList();
  }
}
