import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Hello, Parent! 👋',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              "Here's what's happening today",
              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Text('🔔', style: TextStyle(fontSize: 22)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Text('⚙️', style: TextStyle(fontSize: 22)),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createChild),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Child', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Children cards
            const SectionHeader(title: 'Your Children', actionText: 'Manage'),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: children.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  if (i == children.length) {
                    return GestureDetector(
                      onTap: () => context.push(AppRoutes.createChild),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 32),
                            const SizedBox(height: 4),
                            Text('Add Child', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }
                  final child = children[i];
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.childPin, extra: child.id),
                    child: AnimatedCard(
                      gradientColors: AppColors.primaryGradient,
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            NinjaAvatar(avatarId: child.avatarId, size: 50, showGlow: true),
                            const SizedBox(height: 8),
                            Text(
                              child.name,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              child.grade,
                              style: GoogleFonts.nunito(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Quick stats for first child
            if (children.isNotEmpty) ...[
              SectionHeader(title: '${children.first.name}\'s Overview'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard('⏱️', '1h 20m', 'Screen Time', AppColors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('📚', '45m', 'Learning Time', AppColors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('🔥', '${children.first.streakDays}', 'Day Streak', AppColors.orange)),
                ],
              ),

              const SizedBox(height: 24),

              // Subject performance
              SectionHeader(title: 'Subject Performance', actionText: 'View All',
                  onAction: () => context.push(AppRoutes.progressAnalytics)),
              const SizedBox(height: 12),
              AnimatedCard(
                child: _buildSubjectChart(context),
              ),

              const SizedBox(height: 24),

              // Parent Actions
              const SectionHeader(title: 'Parent Controls'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _actionCard('⏰', 'Screen Time', 'Set daily limits', AppColors.blue,
                      () => context.push(AppRoutes.screenTime)),
                  _actionCard('📗', 'Subjects', 'Enable/disable subjects', AppColors.green,
                      () => context.push(AppRoutes.subjectAccess, extra: children.first.id)),
                  _actionCard('📊', 'Reports', 'View progress', AppColors.purple,
                      () => context.push(AppRoutes.progressAnalytics)),
                  _actionCard('⭐', 'Premium', 'Unlock all features', AppColors.secondary,
                      () => context.push(AppRoutes.subscription)),
                ],
              ),

              const SizedBox(height: 24),

              // AI Suggestions
              _buildAISuggestions(),

              const SizedBox(height: 80),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String emoji, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectChart(BuildContext context) {
    final subjects = [
      ('English', 85.0, AppColors.blue),
      ('Math', 78.0, AppColors.primary),
      ('Science', 90.0, AppColors.green),
      ('Marathi', 80.0, AppColors.orange),
    ];

    return Column(
      children: subjects.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(s.$1, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: s.$2 / 100,
                    backgroundColor: s.$3.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(s.$3),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${s.$2.toInt()}%',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: s.$3),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAISuggestions() {
    return AnimatedCard(
      gradientColors: const [Color(0xFF6C63FF), Color(0xFF9C63FF)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'AI Recommendations',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _suggestion('📈', 'Focus on Geography — lowest progress this week'),
          _suggestion('⏰', 'Best learning time: 4 PM - 6 PM (based on activity)'),
          _suggestion('🎯', 'Try the Marathi speaking practice — great for fluency'),
        ],
      ),
    );
  }

  Widget _suggestion(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }
}
