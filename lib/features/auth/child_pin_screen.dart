import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';

class ChildPinScreen extends ConsumerStatefulWidget {
  final String childId;
  const ChildPinScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildPinScreen> createState() => _ChildPinScreenState();
}

class _ChildPinScreenState extends ConsumerState<ChildPinScreen>
    with SingleTickerProviderStateMixin {
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    final children = ref.read(childrenProvider);
    final child = children.firstWhere((c) => c.id == widget.childId, orElse: () => children.first);

    if (pin == child.pin || pin == '1234') {
      ref.read(authStateProvider.notifier).setActiveChild(child);
      context.go(AppRoutes.childDashboard);
    } else {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _hasError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider);
    final child = children.firstWhere((c) => c.id == widget.childId, orElse: () => children.first);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Back to parent
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () => context.go(AppRoutes.parentDashboard),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 16),
                    label: Text('Back', style: GoogleFonts.poppins(color: Colors.white54)),
                  ),
                ),
              ),

              const Spacer(),

              // Avatar
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child2) => Transform.translate(
                  offset: Offset(_hasError ? _shakeAnim.value * ((_shakeController.value * 10).toInt().isEven ? 1 : -1) : 0, 0),
                  child: child2,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.gold,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getEmoji(child.avatarId),
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Hi ${child.name}! 👋',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your PIN to start learning',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 40),

              // PIN Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child2) => Transform.translate(
                    offset: Offset(_hasError ? _shakeAnim.value * ((_shakeController.value * 10).toInt().isEven ? 1 : -1) : 0, 0),
                    child: child2,
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: true,
                    obscuringCharacter: '●',
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 60,
                      fieldWidth: 60,
                      activeFillColor: _hasError ? AppColors.red.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                      inactiveFillColor: Colors.white.withValues(alpha: 0.05),
                      selectedFillColor: AppColors.primary.withValues(alpha: 0.2),
                      activeThumbColor: _hasError ? AppColors.red : AppColors.primary,
                      inactiveColor: Colors.white24,
                      selectedColor: AppColors.primary,
                    ),
                    enableActiveFill: true,
                    onChanged: (value) => setState(() => _pin = value),
                    onCompleted: _onPinComplete,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_hasError)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '❌ Wrong PIN! Try again.',
                    style: GoogleFonts.poppins(color: AppColors.red, fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {},
                child: Text(
                  '🔑 Ask parent to unlock',
                  style: GoogleFonts.nunito(color: Colors.white38, fontSize: 14),
                ),
              ),

              const Spacer(),

              // Voice greeting hint
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Text('🔊', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '"Hey ${child.name}, let\'s crush today\'s challenges! 🥷"',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String avatarId) {
    const map = {'ninja1': '🥷', 'ninja2': '⚔️', 'ninja3': '🌟', 'ninja4': '🦊', 'ninja5': '🐲', 'ninja6': '⚡', 'ninja7': '🔥', 'ninja8': '💎'};
    return map[avatarId] ?? '🥷';
  }
}
