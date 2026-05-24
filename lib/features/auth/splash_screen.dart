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
  late AnimationController _floatController;
  late AnimationController _buttonsController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _floatAnim;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _buttonsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.4)),
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(_buttonsController);
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _buttonsController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _checkAutoLogin();
  }

  void _checkAutoLogin() {
    if (!mounted) return;
    final auth = ref.read(authStateProvider);
    if (auth.isLoggedIn) {
      if (auth.isParent) {
        context.go(AppRoutes.parentDashboard);
      } else {
        context.go(AppRoutes.childDashboard);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _floatController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            ..._buildFloatingElements(),
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

                  const SizedBox(height: 12),

                  FadeTransition(
                    opacity: _buttonsOpacity,
                    child: Text(
                      'Learn • Play • Level Up',
                      style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: Colors.white54, letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // TWO separate login paths
                  SlideTransition(
                    position: _buttonsSlide,
                    child: FadeTransition(
                      opacity: _buttonsOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // ─ PARENT section ────────────────────────────
                            _sectionLabel('👨‍👩‍👧 Parents'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _loginButton(
                                    icon: '✨',
                                    label: 'Sign Up',
                                    sublabel: 'New account',
                                    gradient: AppColors.primaryGradient,
                                    onTap: () => context.go(AppRoutes.parentRegister),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _loginButton(
                                    icon: '🔑',
                                    label: 'Login',
                                    sublabel: 'Existing account',
                                    gradient: [AppColors.primary.withValues(alpha: 0.7), AppColors.primaryDark],
                                    onTap: () => context.go(AppRoutes.parentLogin),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ─ CHILDREN section ───────────────────────────
                            _sectionLabel('🧒 Children'),
                            const SizedBox(height: 10),
                            _loginButton(
                              icon: '🥷',
                              label: 'Child Login with PIN',
                              sublabel: 'Enter your 4-digit secret PIN',
                              gradient: AppColors.goldGradient,
                              onTap: () => context.go(AppRoutes.childPinDirect),
                              wide: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _buttonsOpacity,
                    child: Text(
                      '🛡️ Safe • Fun • Educational',
                      style: GoogleFonts.nunito(fontSize: 12, color: Colors.white24),
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

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white60)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: Colors.white12)),
      ],
    );
  }

  Widget _loginButton({
    required String icon,
    required String label,
    required String sublabel,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool wide = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text(sublabel, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(sublabel, style: GoogleFonts.nunito(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 6)],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.goldGradient)),
                child: const Center(child: Text('🥷', style: TextStyle(fontSize: 72))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFB84C)],
          ).createShader(b),
          child: Text('NinjaKids',
              style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingElements() {
    final els = [
      ('⭐', 0.08, 0.10), ('📚', 0.85, 0.08), ('🔢', 0.04, 0.40),
      ('💡', 0.88, 0.38), ('🎯', 0.12, 0.74), ('🏆', 0.82, 0.72),
      ('⚡', 0.44, 0.06), ('🎮', 0.20, 0.28), ('🧩', 0.76, 0.24),
    ];
    return els.map((e) => AnimatedBuilder(
      animation: _floatController,
      builder: (_, __) => Positioned(
        left: e.$2 * MediaQuery.of(context).size.width,
        top: e.$3 * MediaQuery.of(context).size.height + (_floatAnim.value * 0.3),
        child: Opacity(opacity: 0.2, child: Text(e.$1, style: const TextStyle(fontSize: 22))),
      ),
    )).toList();
  }
}
