import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QuizTimerRing extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  const QuizTimerRing({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;
    final isUrgent = secondsLeft <= 10;
    final color = isUrgent ? AppTheme.accentOrange : AppTheme.primaryPurple;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: AppTheme.cardBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isUrgent ? AppTheme.accentOrange : AppTheme.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
