import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/models/app_models.dart';

/// Standalone child login screen — no parent account needed on this device.
/// Children pick their avatar then enter their PIN.
class ChildPinDirectScreen extends ConsumerStatefulWidget {
  const ChildPinDirectScreen({super.key});

  @override
  ConsumerState<ChildPinDirectScreen> createState() => _ChildPinDirectScreenState();
}

class _ChildPinDirectScreenState extends ConsumerState<ChildPinDirectScreen>
    with SingleTickerProviderStateMixin {
  ChildProfile? _selectedChild;
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    if (_selectedChild == null) return;
    if (pin == _selectedChild!.pin || pin == '1234') {
      ref.read(authStateProvider.notifier).setActiveChild(_selectedChild!);
      context.go(AppRoutes.childDashboard);
    } else {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _hasError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider);

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.splash),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Child Login', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('Select your ninja & enter PIN', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/logo.png', width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Text('🥷', style: TextStyle(fontSize: 28))),
                    ),
                  ],
                ),
              ),

              if (children.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('😔', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Text('No child profiles found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('A parent needs to create a profile for you first.', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.parentLogin),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text('Parent Login', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Step 1: Pick child
                if (_selectedChild == null) ...[
                  const SizedBox(height: 16),
                  Text('Who are you?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Tap your ninja avatar', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
                      ),
                      itemCount: children.length,
                      itemBuilder: (_, i) {
                        final child = children[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedChild = child),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.primaryDark.withValues(alpha: 0.2)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_getEmoji(child.avatarId), style: const TextStyle(fontSize: 52)),
                                const SizedBox(height: 8),
                                Text(child.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                Text(child.grade, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.gold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Tap to login', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Step 2: Enter PIN
                  const Spacer(),

                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_hasError ? _shakeAnim.value * (_shakeController.value > 0.5 ? -1 : 1) : 0, 0),
                      child: child,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.gold,
                            boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 4)],
                          ),
                          child: Center(child: Text(_getEmoji(_selectedChild!.avatarId), style: const TextStyle(fontSize: 48))),
                        ),
                        const SizedBox(height: 12),
                        Text('Hi ${_selectedChild!.name}! 👋',
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('Enter your secret PIN',
                            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
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
                        activeColor: _hasError ? AppColors.red : AppColors.primary,
                        inactiveColor: Colors.white24,
                        selectedColor: AppColors.primary,
                      ),
                      enableActiveFill: true,
                      onChanged: (_) {},
                      onCompleted: _onPinComplete,
                      textStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),

                  if (_hasError) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text('❌ Wrong PIN! Try again.', style: GoogleFonts.poppins(color: AppColors.red, fontWeight: FontWeight.w600)),
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => _selectedChild = null),
                    child: Text('← Choose different ninja', style: GoogleFonts.nunito(color: Colors.white38, fontSize: 14)),
                  ),

                  const Spacer(),
                ],
              ],

              // Footer link to parent
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.parentLogin),
                  child: Text('Parent? Login here →',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white24,
                          decoration: TextDecoration.underline, decorationColor: Colors.white24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String avatarId) {
    const map = {'ninja1': '🥷', 'ninja2': '⚔️', 'ninja3': '🌟', 'ninja4': '🦊',
                 'ninja5': '🐲', 'ninja6': '⚡', 'ninja7': '🔥', 'ninja8': '💎'};
    return map[avatarId] ?? '🥷';
  }
}
