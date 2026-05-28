import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

const _subjectEmojis = {
  'Mathematics': '🔢',
  'English': '📖',
  'Science': '🔬',
  'History': '🏛️',
  'Geography': '🌍',
  'GK': '🧠',
  'Marathi': '📝',
  'Coding Basics': '💻',
  'Logical Reasoning': '🧩',
};

class SubjectCard extends StatelessWidget {
  final String subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppTheme.subjectColors[subject] ?? const Color(0xFFF3F0FF);
    final textColor = AppTheme.subjectTextColors[subject] ?? AppTheme.primaryPurple;
    final emoji = _subjectEmojis[subject] ?? '📚';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              subject.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
