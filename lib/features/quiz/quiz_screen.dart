import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/models/app_models.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';
import 'package:ninjakids/core/constants/app_constants.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String subject;
  final String difficulty;

  const QuizScreen({super.key, required this.subject, required this.difficulty});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late ConfettiController _confettiController;
  late AnimationController _answerAnimController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late Animation<double> _scaleAnim;
  int _hintsLeft = AppConstants.hintsPerQuiz;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _answerAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _answerAnimController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuiz(widget.subject, widget.difficulty);
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(quizProvider.notifier).tickTimer();
      final quiz = ref.read(quizProvider);
      if (quiz.timeLeft == 0 || quiz.isComplete) {
        _timer?.cancel();
        if (quiz.isComplete) _goToResults();
      }
    });
  }

  void _selectAnswer(int index) {
    final quiz = ref.read(quizProvider);
    if (quiz.isAnswered) return;
    HapticFeedback.mediumImpact();
    ref.read(quizProvider.notifier).selectAnswer(index);
    _timer?.cancel();

    final isCorrect = index == quiz.currentQuestion?.correctIndex;
    if (isCorrect) {
      _confettiController.play();
      _answerAnimController.forward(from: 0);
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
    }
    setState(() => _showHint = false);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final updatedQuiz = ref.read(quizProvider);
      if (updatedQuiz.isComplete || updatedQuiz.currentIndex + 1 >= updatedQuiz.questions.length) {
        ref.read(quizProvider.notifier).nextQuestion();
        _goToResults();
      } else {
        ref.read(quizProvider.notifier).nextQuestion();
        _startTimer();
      }
    });
  }

  void _goToResults() {
    final quiz = ref.read(quizProvider);
    final xp = quiz.correctCount * AppConstants.xpPerCorrectAnswer + (quiz.correctCount == quiz.questions.length ? 30 : 0);
    final coins = quiz.correctCount * AppConstants.coinsPerCorrectAnswer;
    context.go(AppRoutes.quizResult, extra: {
      'subject': widget.subject,
      'correct': quiz.correctCount,
      'total': quiz.questions.length,
      'xpEarned': xp,
      'coinsEarned': coins,
    });
  }

  void _useHint() {
    if (_hintsLeft > 0) {
      setState(() {
        _hintsLeft--;
        _showHint = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    _answerAnimController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final question = quiz.currentQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final timerColor = quiz.timeLeft > 15 ? AppColors.green : quiz.timeLeft > 8 ? AppColors.secondary : AppColors.red;
    final progress = (quiz.currentIndex + 1) / quiz.questions.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.1,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [AppColors.primary, AppColors.secondary, AppColors.green, AppColors.red],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _timer?.cancel();
                          context.pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.bgDarkCard : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${quiz.currentIndex + 1} / ${quiz.questions.length}',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.primary.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Timer
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: timerColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: timerColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: timerColor),
                            const SizedBox(width: 4),
                            Text(
                              '${quiz.timeLeft}s',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: timerColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Score indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              'Score: ${quiz.correctCount * AppConstants.xpPerCorrectAnswer}',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Hearts
                      Row(
                        children: const [
                          Text('❤️', style: TextStyle(fontSize: 18)),
                          Text('❤️', style: TextStyle(fontSize: 18)),
                          Text('❤️', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Question card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Mascot
                        const Text('🥷', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),

                        // Question
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(
                              quiz.isAnswered && quiz.selectedAnswer != question.correctIndex
                                  ? _shakeAnim.value * (_shakeController.value > 0.5 ? -1 : 1)
                                  : 0,
                              0,
                            ),
                            child: child,
                          ),
                          child: AnimatedCard(
                            child: Text(
                              question.question,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        // Hint
                        if (_showHint) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    question.explanation,
                                    style: GoogleFonts.nunito(fontSize: 13, color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Options
                        Expanded(
                          child: ListView.separated(
                            itemCount: question.options.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _buildOption(quiz, question, i),
                          ),
                        ),

                        // Action buttons
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _hintsLeft > 0 && !quiz.isAnswered ? _useHint : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _hintsLeft > 0
                                        ? AppColors.secondary.withOpacity(0.15)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _hintsLeft > 0 ? AppColors.secondary.withOpacity(0.4) : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('💡', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Hint ($_hintsLeft)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _hintsLeft > 0 ? AppColors.secondary : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GradientButton(
                                text: quiz.isAnswered ? 'Next →' : 'Submit',
                                onTap: quiz.isAnswered
                                    ? () {
                                        final updatedQuiz = ref.read(quizProvider);
                                        if (updatedQuiz.currentIndex + 1 >= updatedQuiz.questions.length) {
                                          _goToResults();
                                        } else {
                                          ref.read(quizProvider.notifier).nextQuestion();
                                          _startTimer();
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(QuizState quizState, QuizQuestion question, int index) {
    final isAnswered = quizState.isAnswered;
    final selected = quizState.selectedAnswer == index;
    final isCorrect = question.correctIndex == index;

    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    if (!isAnswered) {
      bgColor = Colors.transparent;
      borderColor = AppColors.primary.withOpacity(0.2);
      textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark;
    } else if (isCorrect) {
      bgColor = AppColors.green.withOpacity(0.15);
      borderColor = AppColors.green;
      textColor = AppColors.green;
      trailingIcon = const Text('✅', style: TextStyle(fontSize: 20));
    } else if (selected && !isCorrect) {
      bgColor = AppColors.red.withOpacity(0.15);
      borderColor = AppColors.red;
      textColor = AppColors.red;
      trailingIcon = const Text('❌', style: TextStyle(fontSize: 20));
    } else {
      bgColor = Colors.transparent;
      borderColor = Colors.grey.shade200;
      textColor = AppColors.textGrey;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected || isCorrect && isAnswered ? 2 : 1.5),
          boxShadow: [
            if (!isAnswered)
              BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAnswered && isCorrect
                    ? AppColors.green
                    : isAnswered && selected && !isCorrect
                        ? AppColors.red
                        : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  ['A', 'B', 'C', 'D'][index],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isAnswered && (isCorrect || selected)
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.options[index],
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}
