import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/entities.dart';
import '../../../providers/kid_providers.dart';
import '../../../widgets/common/ninja_app_bar.dart';
import '../../../widgets/common/xp_progress_bar.dart';
import '../../../widgets/kid/subject_card.dart';
import '../../../widgets/kid/daily_challenge_card.dart';
import '../../../widgets/kid/streak_widget.dart';

class KidDashboardScreen extends ConsumerStatefulWidget {
  const KidDashboardScreen({super.key});

  @override
  ConsumerState<KidDashboardScreen> createState() => _KidDashboardScreenState();
}

class _KidDashboardScreenState extends ConsumerState<KidDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _greetingController;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kidAsync = ref.watch(currentKidProvider);

    return kidAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (kid) => _buildDashboard(kid),
    );
  }

  Widget _buildDashboard(KidEntity kid) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(kid),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildHomeTab(kid),
                  _buildLearnTab(kid),
                  _buildGamesTab(kid),
                  _buildTrophiesTab(kid),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(KidEntity kid) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryPurple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(kid),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${kid.name}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'FredokaOne',
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                    Text(
                      '${kid.className} · Level ${kid.level} Ninja ⚡',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              StreakWidget(streak: kid.currentStreak),
            ],
          ),
          const SizedBox(height: 12),
          XpProgressBar(
            currentXp: kid.xpInCurrentLevel,
            maxXp: kid.xpToNextLevel,
            level: kid.level,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(KidEntity kid) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.secondaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(kid.avatarEmoji, style: const TextStyle(fontSize: 22)),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  // ─── Home Tab ─────────────────────────────────────────────────────────────

  Widget _buildHomeTab(KidEntity kid) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _buildStatCard('⭐', '${kid.coins}', 'Stars'),
              const SizedBox(width: 10),
              _buildStatCard('🏆', '${kid.level}', 'Level'),
              const SizedBox(width: 10),
              _buildStatCard('🔥', '${kid.currentStreak}d', 'Streak'),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Daily Challenge
          const Text(
            '⚡ Daily Challenge',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 10),
          DailyChallengeCard(kid: kid),

          const SizedBox(height: 20),

          // Subjects
          const Text(
            '📚 Choose a Subject',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 10),
          _buildSubjectGrid(kid),

          const SizedBox(height: 20),

          // Speaking practice
          _buildSpeakingBanner(kid),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'FredokaOne',
                fontSize: 18,
                color: AppTheme.primaryPurple,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888899),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectGrid(KidEntity kid) {
    final subjects = kid.allowedSubjects.isEmpty
        ? AppConstants.subjects
        : kid.allowedSubjects;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return SubjectCard(
          subject: subject,
          onTap: () => context.push(
            Routes.quiz,
            extra: {'subject': subject, 'kidId': kid.id},
          ),
        ).animate(delay: (index * 60).ms).fadeIn().scale(
              begin: const Offset(0.8, 0.8),
              curve: Curves.easeOutBack,
            );
      },
    );
  }

  Widget _buildSpeakingBanner(KidEntity kid) {
    return GestureDetector(
      onTap: () => context.push(Routes.speaking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3FE8), Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('🎤', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Speaking Practice',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FredokaOne',
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Practice English & Marathi with AI!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
    );
  }

  // ─── Learn Tab ────────────────────────────────────────────────────────────

  Widget _buildLearnTab(KidEntity kid) {
    return const Center(
      child: Text('📚 Learning Mode Coming Soon!'),
    );
  }

  // ─── Games Tab ────────────────────────────────────────────────────────────

  Widget _buildGamesTab(KidEntity kid) {
    if (kid.isGamesLocked) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Games are locked!',
              style: TextStyle(fontFamily: 'FredokaOne', fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask your parent to unlock games.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('🎮 Games Tab'));
  }

  // ─── Trophies Tab ─────────────────────────────────────────────────────────

  Widget _buildTrophiesTab(KidEntity kid) {
    return const Center(child: Text('🏆 Trophies & Badges'));
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const tabs = [
      {'icon': '🏠', 'label': 'Home'},
      {'icon': '📚', 'label': 'Learn'},
      {'icon': '🎮', 'label': 'Games'},
      {'icon': '🏆', 'label': 'Awards'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabs[index]['icon']!,
                      style: TextStyle(
                        fontSize: isActive ? 22 : 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[index]['label']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppTheme.primaryPurple
                            : const Color(0xFFB0A8CC),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
