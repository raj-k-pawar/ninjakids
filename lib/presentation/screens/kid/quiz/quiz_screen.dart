import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../services/ai/ai_question_service.dart';
import '../../../widgets/quiz/option_tile.dart';
import '../../../widgets/quiz/quiz_timer_ring.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String subject;
  final String kidId;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.kidId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestionEntity> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isLoading = true;
  int _score = 0;
  int _totalXpEarned = 0;
  int _totalCoinsEarned = 0;

  static const int _totalQuestions = 10;
  static const int _secondsPerQuestion = 30;
  int _secondsLeft = _secondsPerQuestion;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _secondsPerQuestion),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(aiQuestionServiceProvider);
      final questions = await service.generateQuestions(
        subject: widget.subject,
        className: 'Class 5',
        difficulty: AppConstants.difficultyMedium,
        questionType: AppConstants.typeMCQ,
        count: _totalQuestions,
        kidId: widget.kidId,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timerController.reset();
    setState(() => _secondsLeft = _secondsPerQuestion);
    _timerController.forward();

    _timerController.addListener(() {
      final remaining =
          (_secondsPerQuestion * (1 - _timerController.value)).ceil();
      if (remaining != _secondsLeft && mounted) {
        setState(() => _secondsLeft = remaining);
      }
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isAnswered) {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        _selectedAnswer = null;
      });
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _onAnswerSelected(String answer) {
    if (_isAnswered) return;
    _timerController.stop();

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
        _totalXpEarned += AppConstants.xpPerCorrectAnswer;
        _totalCoinsEarned += AppConstants.coinsPerCorrectAnswer;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex + 1 >= _questions.length) {
      _finishQuiz();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _isAnswered = false;
    });
    _startTimer();
  }

  void _finishQuiz() {
    context.pushReplacement(
      Routes.quizResult,
      extra: {
        'score': _score,
        'total': _questions.length,
        'xpEarned': _totalXpEarned,
        'coinsEarned': _totalCoinsEarned,
        'subject': widget.subject,
        'kidId': widget.kidId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.darkNavy),
          onPressed: _showExitDialog,
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                widget.subject,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/$_totalQuestions',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppTheme.darkNavy,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildQuiz(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 48))
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 2.seconds),
          const SizedBox(height: 16),
          const Text(
            'AI is generating your questions...',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Personalized just for you!',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    final question = _questions[_currentIndex];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _totalQuestions,
                minHeight: 6,
                backgroundColor: AppTheme.cardBg,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryPurple),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '+${AppConstants.xpPerCorrectAnswer} XP',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ]),
                QuizTimerRing(
                  secondsLeft: _secondsLeft,
                  totalSeconds: _secondsPerQuestion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryPurple,
                          AppTheme.accentPink
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✨ AI GENERATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkNavy,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate(key: ValueKey(_currentIndex))
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  curve: Curves.easeOut,
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = question.options[index];
                final letters = ['A', 'B', 'C', 'D'];
                final letter =
                    index < letters.length ? letters[index] : '${index + 1}';

                OptionState state = OptionState.idle;
                if (_isAnswered) {
                  if (option == question.correctAnswer) {
                    state = OptionState.correct;
                  } else if (option == _selectedAnswer) {
                    state = OptionState.wrong;
                  }
                } else if (option == _selectedAnswer) {
                  state = OptionState.selected;
                }

                return OptionTile(
                  letter: letter,
                  text: option,
                  state: state,
                  onTap: () => _onAnswerSelected(option),
                ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.1);
              },
            ),
          ),
          if (_isAnswered && question.explanation != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedAnswer == question.correctAnswer
                    ? const Color(0xFFDCF5E7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedAnswer == question.correctAnswer ? '✅' : '❌',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedAnswer == question.correctAnswer
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going 💪'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
