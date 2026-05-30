import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const _gameColors = [
    [Color(0xFF1D4ED8), Color(0xFF93C5FD)],
    [Color(0xFF166534), Color(0xFF86EFAC)],
    [Color(0xFF9A3412), Color(0xFFFDBA74)],
    [Color(0xFFBE185D), Color(0xFFF9A8D4)],
    [Color(0xFF0F766E), Color(0xFF5EEAD4)],
    [Color(0xFF92400E), Color(0xFFFCD34D)],
    [Color(0xFF6D28D9), Color(0xFFC4B5FD)],
    [Color(0xFF065F46), Color(0xFF6EE7B7)],
    [Color(0xFF9F1239), Color(0xFFFDA4AF)],
    [Color(0xFF1E3A8A), Color(0xFF93C5FD)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF3B0E8C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text('Fun Games 🎮',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 24, color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ]),
              ),
              // Coins / XP strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CoinStat(icon: '🪙', label: '1,240 Coins'),
                      _CoinStat(icon: '⚡', label: '2,450 XP'),
                      _CoinStat(icon: '🏆', label: 'Rank #7'),
                    ],
                  ),
                ),
              ),
              // Game grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: AppConstants.funGames.length,
                  itemBuilder: (context, i) {
                    final game = AppConstants.funGames[i];
                    final colors = _gameColors[i % _gameColors.length];
                    return _GameCard(
                      game: game,
                      bgColor: colors[0],
                      textColor: colors[1],
                      onTap: () => context.push(
                        Routes.gamePlay,
                        extra: {'gameId': game['id']},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinStat extends StatelessWidget {
  final String icon;
  final String label;
  const _CoinStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 6),
      Text(label,
        style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(game['emoji'] as String,
              style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              (game['name'] as String).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text('⭐⭐⭐',
              style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
