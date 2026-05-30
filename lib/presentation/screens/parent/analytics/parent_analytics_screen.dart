import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/parent_providers.dart';
import '../../../../presentation/widgets/parent/weekly_chart.dart';

class ParentAnalyticsScreen extends ConsumerWidget {
  const ParentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsAsync = ref.watch(parentKidsProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('Analytics 📊')),
      body: kidsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (kids) {
          if (kids.isEmpty) {
            return const Center(child: Text('No kids added yet.'));
          }
          final kid = kids.first;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${kid.name}\'s Progress',
                  style: const TextStyle(
                    fontFamily: 'FredokaOne', fontSize: 22,
                    color: AppTheme.darkNavy)),
                const SizedBox(height: 16),
                const Text('Weekly Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: AppTheme.darkNavy)),
                const SizedBox(height: 10),
                WeeklyChart(kidId: kid.id),
                const SizedBox(height: 20),
                const Text('Subject Performance',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: AppTheme.darkNavy)),
                const SizedBox(height: 10),
                SubjectPerformanceList(kidId: kid.id),
              ],
            ),
          );
        },
      ),
    );
  }
}
