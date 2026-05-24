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
    _welcomeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _welcomeOpacity = CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn);
    _welcomeController.forward();
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
  }

  static const _tabs = [
    _TabItem('🏠', 'Home'),
    _TabItem('📚', 'Subjects'),
    _TabItem('🎮', 'Games'),
    _TabItem('🏆', 'Rewards'),
    _TabItem('👤', 'Profile'),
  ];

  void _onTabTap(int i) {
    if (i == 0) {
      setState(() => _currentTab = 0);
    } else if (i == 1) {
      setState(() => _currentTab = 1);
      context.push(AppRoutes.subjects).then((_) => setState(() => _currentTab = 0));
    } else if (i == 2) {
      setState(() => _currentTab = 2);
      context.push(AppRoutes.games).then((_) => setState(() => _currentTab = 0));
    } else if (i == 3) {
      setState(() => _currentTab = 3);
      context.push(AppRoutes.rewards).then((_) => setState(() => _currentTab = 0));
    } else if (i == 4) {
      setState(() => _currentTab = 4);
      context.push(AppRoutes.childProfile).then((_) => setState(() => _currentTab = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final children = ref.watch(childrenProvider);
    final child = auth.activeChild ?? (children.isNotEmpty ? children.first : null);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (child == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading...', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
      body: FadeTransition(
        opacity: _welcomeOpacity,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 185,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF0EEFF),
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(background: _buildHeader(child)),
              actions: [
                IconButton(
                  icon: const Text('🔔', style: TextStyle(fontSize: 20)),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'Switch to Parent',
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
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
                  // XP bar
                  XPProgressBar(current: child.totalXP % 500, max: 500, level: child.level),
                  const SizedBox(height: 20),
                  _buildDailyChallenge(child),
                  const SizedBox(height: 20),
                  SectionHeader(title: '▶️ Continue Learning', actionText: 'View All',
                      onAction: () => context.push(AppRoutes.subjects)),
                  const SizedBox(height: 12),
                  _buildContinueLearning(),
                  const SizedBox(height: 20),
                  SectionHeader(title: '📚 Your Subjects', actionText: 'All',
                      onAction: () => context.push(AppRoutes.subjects)),
                  const SizedBox(height: 12),
                  _buildSubjectsGrid(child),
                  const SizedBox(height: 20),
                  _buildSpeakingCard(),
                  const SizedBox(height: 16),
                  _buildAITutorCard(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 64, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hi ${child.name}! 👋',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text("Let's learn and have fun!",
                        style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        StatChip(emoji: '⭐', value: '${child.totalXP}', label: 'XP', color: AppColors.secondary),
                        CoinCounter(coins: child.coins),
                        StreakCounter(days: child.streakDays),
                      ],
                    ),
                  ],
                ),
              ),
              NinjaAvatar(avatarId: child.avatarId, size: 68, showGlow: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge(ChildProfile child) {
    return AnimatedCard(
      gradientColors: AppColors.goldGradient,
      onTap: () => context.push(AppRoutes.quiz, extra: {'subject': 'Mathematics', 'difficulty': 'Medium'}),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Challenge', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                Text("Complete today's challenge and earn 50 coins!",
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text('Start', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning() {
    final items = [
      {'subject': 'Mathematics', 'topic': 'Math Addition Game', 'emoji': '🔢', 'progress': 0.7},
      {'subject': 'English', 'topic': 'Speaking Practice', 'emoji': '📖', 'progress': 0.45},
    ];
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedCard(
          onTap: () => context.push(AppRoutes.quiz, extra: {'subject': item['subject'] as String, 'difficulty': 'Easy'}),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['topic'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(item['subject'] as String, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item['progress'] as double,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSubjectsGrid(ChildProfile child) {
    final subjectColors = {
      'English': AppColors.englishColor, 'Marathi': AppColors.marathiColor,
      'Mathematics': AppColors.mathColor, 'Science': AppColors.scienceColor,
      'History': AppColors.historyColor, 'Geography': AppColors.geographyColor,
    };
    final subjects = SubjectInfo.all.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15,
      ),
      itemCount: subjects.length,
      itemBuilder: (_, i) {
        final sub = subjects[i];
        final color = subjectColors[sub.name] ?? AppColors.primary;
        final enabled = child.enabledSubjects.contains(sub.name);
        return SubjectCard(
          subject: sub.name, emoji: sub.emoji,
          progressPercent: 60 + (i * 7) % 40,
          xpReward: 50 + (i * 15),
          color: color, isEnabled: enabled,
          onTap: () => _showSubjectOptions(sub.name),
        );
      },
    );
  }

  void _showSubjectOptions(String subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.bgDarkCard : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(subject, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _sheetOption('🧠', 'Take a Quiz', AppColors.primary,
                () { Navigator.pop(context); context.push(AppRoutes.quiz, extra: {'subject': subject, 'difficulty': 'Easy'}); }),
            const SizedBox(height: 10),
            _sheetOption('🎤', 'Speaking Practice', AppColors.blue,
                () { Navigator.pop(context); context.push(AppRoutes.speaking, extra: subject); }),
            const SizedBox(height: 10),
            _sheetOption('🤖', 'Ask AI Tutor', AppColors.purple,
                () { Navigator.pop(context); context.push(AppRoutes.aiTutor); }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(String emoji, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakingCard() {
    return AnimatedCard(
      onTap: () => context.push(AppRoutes.speaking, extra: 'English'),
      gradientColors: const [Color(0xFF00C2FF), Color(0xFF0070CC)],
      child: Row(
        children: [
          const Text('🎤', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speaking Practice', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('AI pronunciation tutor', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
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

  Widget _langChip(String lang) => GestureDetector(
    onTap: () => context.push(AppRoutes.speaking, extra: lang),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(lang, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    ),
  );

  Widget _buildAITutorCard() {
    return AnimatedCard(
      onTap: () => context.push(AppRoutes.aiTutor),
      gradientColors: const [Color(0xFFBB6BFF), Color(0xFF6C63FF)],
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Ninja Tutor', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Ask any question, get instant help!', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text('🟢 Online', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                onTap: () => _onTabTap(i),
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
                        Text(tab.label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
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
