import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class QuizResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  const QuizResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final score = resultData['score'] as int? ?? 0;
    final total = resultData['total'] as int? ?? 10;
    final xpEarned = resultData['xpEarned'] as int? ?? 0;
    final coinsEarned = resultData['coinsEarned'] as int? ?? 0;
    final subject = resultData['subject'] as String? ?? 'Quiz';
    final accuracy = total > 0 ? (score / total * 100).round() : 0;

    final (emoji, message, color) = switch (accuracy) {
      >= 90 => ('🌟', 'Outstanding!', AppTheme.accentGreen),
      >= 70 => ('⭐', 'Great Job!', AppTheme.primaryPurple),
      >= 50 => ('👍', 'Good Effort!', AppTheme.accentOrange),
      _ => ('💪', 'Keep Practicing!', AppTheme.accentBlue),
    };

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(message,
                style: TextStyle(
                  fontFamily: 'FredokaOne', fontSize: 32, color: color)),
              const SizedBox(height: 8),
              Text('$subject Quiz Complete!',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _stat('$score/$total', 'Score', AppTheme.primaryPurple),
                    _stat('$accuracy%', 'Accuracy', color),
                    _stat('+$xpEarned', 'XP', AppTheme.accentOrange),
                    _stat('+$coinsEarned', 'Coins', AppTheme.secondaryYellow),
                  ]),
                ]),
              ),
              const SizedBox(height: 32),
              // Score bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? score / total : 0,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE8E4FF),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go(Routes.kidDashboard),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
                child: const Text('Back to Home 🏠'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
                child: const Text('Play Again 🔄'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(children: [
      Text(value,
        style: TextStyle(
          fontFamily: 'FredokaOne', fontSize: 22, color: color)),
      Text(label,
        style: const TextStyle(
          fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
    ]);
  }
}
