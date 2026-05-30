import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('AI Speaking Practice')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎤', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text('AI Speaking Practice',
              style: TextStyle(
                fontFamily: 'FredokaOne', fontSize: 24,
                color: AppTheme.darkNavy)),
            const SizedBox(height: 8),
            Text('English & Marathi voice lessons',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(children: [
                Text('🚀 Coming Soon!',
                  style: TextStyle(fontFamily: 'FredokaOne', fontSize: 20)),
                SizedBox(height: 8),
                Text(
                  'AI-powered pronunciation scoring, conversation bot, and speaking streaks are being built.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
