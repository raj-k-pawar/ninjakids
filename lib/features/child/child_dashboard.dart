import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/models/app_models.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';
import 'package:ninjakids/core/constants/app_constants.dart';

class ChildDashboard extends ConsumerStatefulWidget {
  const ChildDashboard({super.key});

  @override
  ConsumerState<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends ConsumerState<ChildDashboard>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeOpacity;

  @override
  void initState() {
    super.initState();
    _welcomeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _welcomeOpacity = CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn);
    _welcomeController.forward();
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
  }

  final _tabs = [
    _TabItem('🏠', 'Home'),
    _TabItem('📚', 'Subjects'),
    _TabItem('🎮', 'Games'),
    _TabItem('🏆', 'Rewards'),
    _TabItem('👤', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final children = ref.watch(childrenProvider);
    final child = auth.activeChild ?? (children.isNotEmpty ? children.first : null);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
      body: _buildCurrentTab(child, isDark),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildCurrentTab(ChildProfile child, bool isDark) {
    return _buildHomeTab(child, isDark);
  }

  Widget _buildHomeTab(ChildProfile child, bool isDark) {
    return FadeTransition(
      opacity: _welcomeOpacity,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(child),
            ),
            actions: [
              IconButton(
                icon: const Text('🔔', style: TextStyle(fontSize: 22)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Text('🚪', style: TextStyle(fontSize: 22)),
                onPressed: () {
                  ref.read(authStateProvider.notifier).switchToParent();
                  context.go(AppRoutes.parentDashboard);
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // XP Progress
                XPProgressBar(
                  current: child.totalXP % 500,
                  max: 500,
                  level: child.level,
                ),
                const SizedBox(height: 20),

                // Daily Challenge
                _buildDailyChallenge(child),
                const SizedBox(height: 20),

                // Continue Learning
                SectionHeader(title: '▶️ Continue Learning', actionText: 'View All',
                    onAction: () => context.push(AppRoutes.subjects)),
                const SizedBox(height: 12),
                _buildContinueLearning(child),
                const SizedBox(height: 20),

                // Subjects Grid
                SectionHeader(title: '📚 Your Subjects', actionText: 'All',
                    onAction: () => context.push(AppRoutes.subjects)),
                const SizedBox(height: 12),
                _buildSubjectsGrid(child),
                const SizedBox(height: 20),

                // Speaking practice
                _buildSpeakingCard(),
                const SizedBox(height: 20),

                // AI Tutor
                _buildAITutorCard(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChildProfile child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hi ${child.name}! 👋',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      "Let's learn and have fun!",
                      style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatChip(
                          emoji: '⭐',
                          value: '${child.totalXP}',
                          label: 'XP',
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        CoinCounter(coins: child.coins),
                        const SizedBox(width: 8),
                        StreakCounter(days: child.streakDays),
                      ],
                    ),
                  ],
                ),
              ),
              NinjaAvatar(avatarId: child.avatarId, size: 70, showGlow: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(ChildProfile child) {
    return AnimatedCard(
      gradientColors: AppColors.goldGradient,
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Challenge',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                Text("Complete today's challenge and earn 50 coins!",
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push(AppRoutes.quiz, extra: {'subject': 'Mathematics', 'difficulty': 'Medium'}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Start',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(ChildProfile child) {
    final continuing = [
      {'subject': 'Mathematics', 'topic': 'Math Addition Game', 'emoji': '🔢', 'progress': 0.7},
      {'subject': 'English', 'topic': 'Speaking Practice', 'emoji': '📖', 'progress': 0.45},
    ];

    return Column(
      children: continuing.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedCard(
            onTap: () => context.push(AppRoutes.quiz,
                extra: {'subject': item['subject'] as String, 'difficulty': 'Easy'}),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['topic'] as String,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(item['subject'] as String,
                          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item['progress'] as double,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectsGrid(ChildProfile child) {
    final subjectColors = {
      'English': AppColors.englishColor,
      'Marathi': AppColors.marathiColor,
      'Mathematics': AppColors.mathColor,
      'Science': AppColors.scienceColor,
      'History': AppColors.historyColor,
      'Geography': AppColors.geographyColor,
    };

    final subjects = SubjectInfo.all.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: subjects.length,
      itemBuilder: (_, i) {
        final sub = subjects[i];
        final color = subjectColors[sub.name] ?? AppColors.primary;
        final enabled = child.enabledSubjects.contains(sub.name);
        return SubjectCard(
          subject: sub.name,
          emoji: sub.emoji,
          progressPercent: 60 + (i * 7) % 40,
          xpReward: 50 + (i * 15),
          color: color,
          isEnabled: enabled,
          onTap: () => context.push(AppRoutes.quiz, extra: {'subject': sub.name, 'difficulty': 'Easy'}),
        );
      },
    );
  }

  Widget _buildSpeakingCard() {
    return AnimatedCard(
      onTap: () => context.push(AppRoutes.speaking, extra: 'English'),
      gradientColors: [const Color(0xFF00C2FF), const Color(0xFF0070CC)],
      child: Row(
        children: [
          const Text('🎤', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speaking Practice',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Improve your pronunciation with AI tutor',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _langChip('English'),
                    const SizedBox(width: 8),
                    _langChip('Marathi'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langChip(String lang) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.speaking, extra: lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(lang, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildAITutorCard() {
    return AnimatedCard(
      onTap: () => context.push(AppRoutes.aiTutor),
      gradientColors: [const Color(0xFFBB6BFF), const Color(0xFF6C63FF)],
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Ninja Tutor',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Ask any question, get instant help!',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Online 🟢',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == _currentTab;
              return GestureDetector(
                onTap: () {
                  if (i == 0) {
                    setState(() => _currentTab = 0);
                  } else if (i == 1) {
                    context.push(AppRoutes.subjects);
                  } else if (i == 2) {
                    context.push(AppRoutes.games);
                  } else if (i == 3) {
                    context.push(AppRoutes.rewards);
                  } else if (i == 4) {
                    context.push(AppRoutes.childProfile);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? AppGradients.primary : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tab.icon, style: TextStyle(fontSize: selected ? 22 : 20)),
                      if (selected) ...[
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String icon;
  final String label;
  const _TabItem(this.icon, this.label);
}
