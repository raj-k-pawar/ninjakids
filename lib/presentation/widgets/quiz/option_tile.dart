import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

enum OptionState { idle, selected, correct, wrong }

class OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final OptionState state;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return GestureDetector(
      onTap: state == OptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 2),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.letterBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  state == OptionState.correct
                      ? '✓'
                      : state == OptionState.wrong
                          ? '✗'
                          : letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.letterText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
            ),
            if (state == OptionState.correct)
              const Text('🎉', style: TextStyle(fontSize: 18))
                  .animate()
                  .scale(curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }

  _OptionColors _getColors() {
    return switch (state) {
      OptionState.correct => _OptionColors(
          bg: const Color(0xFFDCF5E7),
          border: AppTheme.accentGreen,
          text: const Color(0xFF166534),
          letterBg: AppTheme.accentGreen,
          letterText: Colors.white,
        ),
      OptionState.wrong => _OptionColors(
          bg: const Color(0xFFFEE2E2),
          border: Colors.red,
          text: const Color(0xFF991B1B),
          letterBg: Colors.red,
          letterText: Colors.white,
        ),
      OptionState.selected => _OptionColors(
          bg: AppTheme.cardBg,
          border: AppTheme.primaryPurple,
          text: AppTheme.primaryPurple,
          letterBg: AppTheme.primaryPurple,
          letterText: Colors.white,
        ),
      OptionState.idle => _OptionColors(
          bg: Colors.white,
          border: const Color(0xFFE8E4FF),
          text: AppTheme.darkNavy,
          letterBg: const Color(0xFFE8E4FF),
          letterText: AppTheme.primaryPurple,
        ),
    };
  }
}

class _OptionColors {
  final Color bg;
  final Color border;
  final Color text;
  final Color letterBg;
  final Color letterText;

  const _OptionColors({
    required this.bg,
    required this.border,
    required this.text,
    required this.letterBg,
    required this.letterText,
  });
}
