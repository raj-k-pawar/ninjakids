import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class GamePlayScreen extends StatelessWidget {
  final String gameId;
  const GamePlayScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _gameName(gameId),
          style: const TextStyle(
            fontFamily: 'FredokaOne', color: Colors.white, fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_gameEmoji(gameId),
              style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(_gameName(gameId),
              style: const TextStyle(
                fontFamily: 'FredokaOne', fontSize: 28, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Coming Soon! 🚀',
              style: TextStyle(
                fontSize: 16, color: Colors.white60,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Games'),
            ),
          ],
        ),
      ),
    );
  }

  String _gameName(String id) {
    final game = _games.firstWhere(
      (g) => g['id'] == id,
      orElse: () => {'name': 'Game'},
    );
    return game['name'] as String;
  }

  String _gameEmoji(String id) {
    final game = _games.firstWhere(
      (g) => g['id'] == id,
      orElse: () => {'emoji': '🎮'},
    );
    return game['emoji'] as String;
  }

  static const _games = [
    {'id': 'sudoku', 'name': 'Sudoku', 'emoji': '🧩'},
    {'id': 'memory_match', 'name': 'Memory Match', 'emoji': '🃏'},
    {'id': 'kbc_kids', 'name': 'KBC for Kids', 'emoji': '📺'},
    {'id': 'word_puzzle', 'name': 'Word Puzzle', 'emoji': '🔤'},
    {'id': 'math_puzzle', 'name': 'Math Puzzle', 'emoji': '🔢'},
    {'id': 'typing_speed', 'name': 'Typing Speed', 'emoji': '⌨️'},
    {'id': 'brain_challenge', 'name': 'Brain Challenge', 'emoji': '🧠'},
    {'id': 'color_match', 'name': 'Color Match', 'emoji': '🎨'},
    {'id': 'quiz_battle', 'name': 'Quiz Battle', 'emoji': '⚔️'},
    {'id': 'zigzag', 'name': 'ZigZag', 'emoji': '⚡'},
  ];
}
