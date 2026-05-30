import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _badges = [
    {'emoji': '🔥', 'name': 'On Fire', 'desc': '7 day streak', 'unlocked': true},
    {'emoji': '🧠', 'name': 'Brain Box', 'desc': '100 correct answers', 'unlocked': true},
    {'emoji': '⚡', 'name': 'Speed Star', 'desc': 'Answer in under 5s', 'unlocked': false},
    {'emoji': '📚', 'name': 'Scholar', 'desc': 'Complete all subjects', 'unlocked': false},
    {'emoji': '🏆', 'name': 'Champion', 'desc': 'Reach Level 10', 'unlocked': false},
    {'emoji': '🎯', 'name': 'Perfect Score', 'desc': '10/10 in a quiz', 'unlocked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('Achievements 🏆')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _badges.length,
        itemBuilder: (context, i) {
          final b = _badges[i];
          final unlocked = b['unlocked'] as bool;
          return Container(
            decoration: BoxDecoration(
              color: unlocked ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked
                    ? const Color(0xFFE8E4FF)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorFiltered(
                  colorFilter: unlocked
                      ? const ColorFilter.mode(
                          Colors.transparent, BlendMode.saturation)
                      : const ColorFilter.matrix([
                          0.2, 0.2, 0.2, 0, 0,
                          0.2, 0.2, 0.2, 0, 0,
                          0.2, 0.2, 0.2, 0, 0,
                          0,   0,   0,   1, 0,
                        ]),
                  child: Text(b['emoji'] as String,
                    style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 8),
                Text(b['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: unlocked ? AppTheme.darkNavy : Colors.grey,
                  ),
                ),
                Text(b['desc'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: unlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                if (unlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('✅ Unlocked',
                      style: TextStyle(
                        fontSize: 10, color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
