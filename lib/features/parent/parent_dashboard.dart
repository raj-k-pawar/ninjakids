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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text('🥷', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 8),
            Text('Parent Dashboard', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(icon: const Text('⚙️', style: TextStyle(fontSize: 20)), onPressed: () => context.push(AppRoutes.settings)),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.splash);
            },
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
            // ─── Your Children ──────────────────────────────────────────
            SectionHeader(
              title: 'Your Children (${children.length})',
              actionText: 'Add Child',
              onAction: () => context.push(AppRoutes.createChild),
            ),
            const SizedBox(height: 12),

            if (children.isEmpty)
              AnimatedCard(
                child: Column(
                  children: [
                    const Text('👶', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text('No children added yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Tap "Add Child" to create a profile', style: GoogleFonts.nunito(color: AppColors.textGrey)),
                    const SizedBox(height: 16),
                    GradientButton(text: '+ Add First Child', onTap: () => context.push(AppRoutes.createChild)),
                  ],
                ),
              )
            else
              Column(
                children: children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedCard(
                    child: Column(
                      children: [
                        // Child header row
                        Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primary,
                              ),
                              child: Center(child: Text(_emoji(child.avatarId), style: const TextStyle(fontSize: 30))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(child.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                  Text('${child.grade} • Level ${child.level}', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _miniStat('⭐', '${child.totalXP}', AppColors.primary),
                                      const SizedBox(width: 8),
                                      _miniStat('🪙', '${child.coins}', AppColors.secondary),
                                      const SizedBox(width: 8),
                                      _miniStat('🔥', '${child.streakDays}d', AppColors.orange),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Manage button
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.childManagement, extra: child.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('Manage', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // XP bar
                        XPProgressBar(current: child.totalXP % 500, max: 500, level: child.level),

                        const SizedBox(height: 12),

                        // Quick actions row
                        Row(
                          children: [
                            _quickAction(context, '👤', 'Login as\n${child.name}', AppColors.green,
                                () => context.push(AppRoutes.childPin, extra: child.id)),
                            const SizedBox(width: 8),
                            _quickAction(context, '📊', 'View\nProgress', AppColors.blue,
                                () => context.push(AppRoutes.childManagement, extra: child.id)),
                            const SizedBox(width: 8),
                            _quickAction(context, '📚', 'Subjects', AppColors.purple,
                                () => context.push(AppRoutes.childManagement, extra: child.id)),
                            const SizedBox(width: 8),
                            _quickAction(context, '⏰', 'Screen\nTime', AppColors.orange,
                                () => context.push(AppRoutes.screenTime)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),

            const SizedBox(height: 20),

            // ─── AI Recommendations ────────────────────────────────────
            if (children.isNotEmpty) ...[
              const SectionHeader(title: '🤖 AI Recommendations'),
              const SizedBox(height: 12),
              AnimatedCard(
                gradientColors: const [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _suggestion('📈', 'Focus on Geography — lowest progress this week'),
                    _suggestion('⏰', 'Best learning time: 4 PM - 6 PM'),
                    _suggestion('🎯', 'Try the Marathi speaking practice for fluency'),
                    _suggestion('🏆', '3 more days to complete a 10-day streak!'),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ],
    ),
  );

  Widget _quickAction(BuildContext context, String emoji, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestion(String emoji, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)))),
      ],
    ),
  );

  String _emoji(String id) {
    const map = {'ninja1': '🥷', 'ninja2': '⚔️', 'ninja3': '🌟', 'ninja4': '🦊',
                 'ninja5': '🐲', 'ninja6': '⚡', 'ninja7': '🔥', 'ninja8': '💎'};
    return map[id] ?? '🥷';
  }
}
