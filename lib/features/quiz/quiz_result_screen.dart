import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final String subject;
  final int correct;
  final int total;
  final int xpEarned;
  final int coinsEarned;

  const QuizResultScreen({
    super.key,
    required this.subject,
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.coinsEarned,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      if (widget.correct > widget.total / 2) {
        _confettiController.play();
      }
      // Update child XP and coins
      final auth = ref.read(authStateProvider);
      final child = auth.activeChild;
      if (child != null) {
        ref.read(childrenProvider.notifier).addXP(child.id, widget.xpEarned);
        ref.read(childrenProvider.notifier).addCoins(child.id, widget.coinsEarned);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double get _accuracy => widget.total > 0 ? (widget.correct / widget.total) * 100 : 0;

  String get _grade {
    if (_accuracy >= 90) return 'S';
    if (_accuracy >= 80) return 'A';
    if (_accuracy >= 70) return 'B';
    if (_accuracy >= 60) return 'C';
    return 'D';
  }

  String get _message {
    if (_accuracy >= 90) return 'Perfect Ninja! 🥷⚡';
    if (_accuracy >= 80) return 'Excellent Work! 🌟';
    if (_accuracy >= 70) return 'Good Job! 💪';
    if (_accuracy >= 60) return 'Keep Practicing! 📚';
    return 'Never Give Up! 🔥';
  }

  List<Color> get _gradeColors {
    if (_accuracy >= 90) return AppColors.goldGradient;
    if (_accuracy >= 80) return AppColors.primaryGradient;
    if (_accuracy >= 70) return AppColors.greenGradient;
    return AppColors.redGradient;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradeColors.first.withValues(alpha: 0.15), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.08,
              numberOfParticles: 30,
              gravity: 0.15,
              colors: const [AppColors.primary, AppColors.secondary, AppColors.green, AppColors.red, Colors.white],
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Grade circle
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _gradeColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _gradeColors.first.withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _grade,
                              style: GoogleFonts.poppins(
                                fontSize: 60,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _message,
                      style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subject,
                      style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textGrey),
                    ),

                    const SizedBox(height: 24),

                    // Score card
                    AnimatedCard(
                      gradientColors: _gradeColors,
                      child: Column(
                        children: [
                          Text(
                            '${widget.correct} / ${widget.total}',
                            style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          Text(
                            'Correct Answers',
                            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _accuracy / 100,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Score: ${_accuracy.toInt()}%',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rewards earned
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedCard(
                            gradientColors: AppColors.primaryGradient,
                            child: Column(
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 32)),
                                Text(
                                  '+${widget.xpEarned}',
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                Text('XP Earned',
                                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedCard(
                            gradientColors: AppColors.goldGradient,
                            child: Column(
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 32)),
                                Text(
                                  '+${widget.coinsEarned}',
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                Text('Coins Earned',
                                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < (_accuracy >= 90 ? 3 : _accuracy >= 70 ? 2 : 1);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            filled ? '⭐' : '☆',
                            style: TextStyle(fontSize: 36, color: filled ? AppColors.secondary : Colors.grey.shade300),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Buttons
                    GradientButton(
                      text: '🔄 Play Again',
                      onTap: () {
                        ref.read(quizProvider.notifier).reset();
                        context.go(AppRoutes.quiz, extra: {
                          'subject': widget.subject,
                          'difficulty': 'Easy',
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    OutlineButton(
                      text: '🏠 Back to Home',
                      color: AppColors.primary,
                      onTap: () {
                        ref.read(quizProvider.notifier).reset();
                        context.go(AppRoutes.childDashboard);
                      },
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        ref.read(quizProvider.notifier).reset();
                        context.push(AppRoutes.aiTutor);
                      },
                      child: Text(
                        '🤖 Review with AI Tutor',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
