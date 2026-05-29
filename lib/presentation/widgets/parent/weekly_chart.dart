import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

// Weekly Chart Widget
class WeeklyChart extends ConsumerWidget {
  final String kidId;
  const WeeklyChart({super.key, required this.kidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data — replace with Firestore stream
    final data = [28, 42, 35, 55, 30, 58, 22];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final isToday = i == DateTime.now().weekday - 1;
                final barH = (data[i] / maxVal) * 70;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + i * 60),
                          height: barH,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.accentOrange
                                : AppTheme.primaryPurple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isToday
                                ? AppTheme.accentOrange
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppTheme.primaryPurple, 'Previous days'),
              const SizedBox(width: 16),
              _legend(AppTheme.accentOrange, 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }
}

// Subject Performance Widget
class SubjectPerformanceList extends ConsumerWidget {
  final String kidId;
  const SubjectPerformanceList({super.key, required this.kidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data — replace with Firestore query
    final subjects = [
      {'name': 'Mathematics', 'score': 0.82, 'color': AppTheme.accentOrange},
      {'name': 'Science', 'score': 0.75, 'color': AppTheme.accentBlue},
      {'name': 'English', 'score': 0.91, 'color': AppTheme.accentGreen},
      {'name': 'GK', 'score': 0.58, 'color': AppTheme.primaryPurple},
      {'name': 'Geography', 'score': 0.67, 'color': AppTheme.accentPink},
    ];

    return Column(
      children: subjects.map((s) {
        final score = s['score'] as double;
        final color = s['color'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  s['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8E4FF),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '${(score * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
