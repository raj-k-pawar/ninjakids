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

// ─── Subjects Screen ──────────────────────────────────────────────────────────
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  static const _subjectColors = {
    'Mathematics': AppColors.mathColor,
    'English': AppColors.englishColor,
    'Science': AppColors.scienceColor,
    'Marathi': AppColors.marathiColor,
    'History': AppColors.historyColor,
    'Geography': AppColors.geographyColor,
    'Coding': AppColors.codingColor,
    'General Knowledge': AppColors.gkColor,
    'Logical Reasoning': AppColors.reasoningColor,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final children = ref.watch(childrenProvider);
    final child = auth.activeChild ?? (children.isNotEmpty ? children.first : null);
    final progress = ref.watch(subjectProgressProvider);

    return Scaffold(
      appBar: const NinjaAppBar(title: '📚 Subjects', showBack: true),
      body: Column(
        children: [
          // Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AnimatedCard(
              gradientColors: const [AppColors.primary, Color(0xFF9C63FF)],
              child: Row(
                children: [
                  const Text('🥷', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Choose Your Battle!',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Each subject makes you a stronger ninja!',
                            style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: SubjectInfo.all.length,
              itemBuilder: (_, i) {
                final sub = SubjectInfo.all[i];
                final color = _subjectColors[sub.name] ?? AppColors.primary;
                final enabled = child?.enabledSubjects.contains(sub.name) ?? true;
                final prog = progress.firstWhere(
                  (p) => p.subject == sub.name,
                  orElse: () => SubjectProgress(
                    subject: sub.name, totalLessons: 20,
                    completedLessons: 0, accuracy: 0, xpEarned: 0,
                  ),
                );

                return SubjectCard(
                  subject: sub.name,
                  emoji: sub.emoji,
                  progressPercent: (prog.progressPercent * 100).toInt(),
                  xpReward: prog.xpEarned,
                  color: color,
                  isEnabled: enabled,
                  onTap: () => _showSubjectOptions(context, sub.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSubjectOptions(BuildContext context, String subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubjectBottomSheet(subject: subject),
    );
  }
}

class _SubjectBottomSheet extends StatelessWidget {
  final String subject;
  const _SubjectBottomSheet({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(subject,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Choose how you want to learn',
              style: GoogleFonts.nunito(color: AppColors.textGrey)),
          const SizedBox(height: 20),
          _option(context, '🧠', 'Take a Quiz', 'Test your knowledge', AppColors.primary,
              () {
                Navigator.pop(context);
                context.push(AppRoutes.quiz, extra: {'subject': subject, 'difficulty': 'Easy'});
              }),
          const SizedBox(height: 12),
          _option(context, '🎤', 'Speaking Practice', 'Improve pronunciation', AppColors.blue,
              () {
                Navigator.pop(context);
                context.push(AppRoutes.speaking, extra: subject);
              }),
          const SizedBox(height: 12),
          _option(context, '🤖', 'Ask AI Tutor', 'Get explanations instantly', AppColors.purple,
              () {
                Navigator.pop(context);
                context.push(AppRoutes.aiTutor);
              }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String emoji, String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(sub, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Games Screen ─────────────────────────────────────────────────────────────
class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String _selectedFilter = 'All';
  String _selectedSubject = 'Mathematics';

  final _filters = ['All', 'Easy', 'Medium', 'Hard', 'Recommended'];

  final _games = [
    {'title': 'Add the Numbers', 'subject': 'Mathematics', 'difficulty': 'Easy', 'xp': '+10 XP', 'emoji': '➕', 'progress': 0.76},
    {'title': 'Math Puzzle', 'subject': 'Mathematics', 'difficulty': 'Medium', 'xp': '+20 XP', 'emoji': '🧩', 'progress': 0.0},
    {'title': 'Multiplication Fun', 'subject': 'Mathematics', 'difficulty': 'Easy', 'xp': '+15 XP', 'emoji': '✖️', 'progress': 0.0},
    {'title': 'Math Treasure', 'subject': 'Mathematics', 'difficulty': 'Hard', 'xp': '+25 XP', 'emoji': '💎', 'progress': 0.0},
    {'title': 'Number Ninja', 'subject': 'Mathematics', 'difficulty': 'Medium', 'xp': '+20 XP', 'emoji': '🥷', 'progress': 0.0},
    {'title': 'Word Builder', 'subject': 'English', 'difficulty': 'Easy', 'xp': '+10 XP', 'emoji': '🔤', 'progress': 0.5},
    {'title': 'Spell Master', 'subject': 'English', 'difficulty': 'Medium', 'xp': '+20 XP', 'emoji': '✏️', 'progress': 0.0},
    {'title': 'Grammar Quest', 'subject': 'English', 'difficulty': 'Hard', 'xp': '+25 XP', 'emoji': '📝', 'progress': 0.0},
    {'title': 'Science Explorer', 'subject': 'Science', 'difficulty': 'Medium', 'xp': '+20 XP', 'emoji': '🔬', 'progress': 0.3},
    {'title': 'Planet Hunt', 'subject': 'Science', 'difficulty': 'Easy', 'xp': '+10 XP', 'emoji': '🪐', 'progress': 0.0},
  ];

  List<Map<String, dynamic>> get _filteredGames {
    return _games.where((g) {
      final filterMatch = _selectedFilter == 'All' || _selectedFilter == 'Recommended' ||
          g['difficulty'] == _selectedFilter;
      return filterMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NinjaAppBar(title: '🎮 Games'),
      body: Column(
        children: [
          // Subject tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['Mathematics', 'English', 'Science', 'General Knowledge'].map((s) {
                final selected = s == _selectedSubject;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected ? AppGradients.primary : null,
                      color: selected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Difficulty filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) {
                final selected = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.secondary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.secondary : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Games list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredGames.length,
              itemBuilder: (_, i) {
                final game = _filteredGames[i];
                final diffColor = game['difficulty'] == 'Easy'
                    ? AppColors.green
                    : game['difficulty'] == 'Medium'
                        ? AppColors.secondary
                        : AppColors.red;
                final progress = game['progress'] as double;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedCard(
                    onTap: () => context.push(AppRoutes.quiz,
                        extra: {'subject': game['subject'] as String, 'difficulty': game['difficulty'] as String}),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(game['emoji'] as String, style: const TextStyle(fontSize: 26)),
                              if (progress > 0)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, size: 8, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(game['title'] as String,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      game['difficulty'] as String,
                                      style: GoogleFonts.poppins(fontSize: 10, color: diffColor, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(game['xp'] as String,
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              if (progress > 0) ...[
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rewards Screen ───────────────────────────────────────────────────────────
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final children = ref.watch(childrenProvider);
    final child = auth.activeChild ?? (children.isNotEmpty ? children.first : null);
    final badges = AppBadge.allBadges;

    return Scaffold(
      appBar: const NinjaAppBar(title: '🏆 Rewards & Achievements'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(child: _rewardStat('⭐', '${child?.totalXP ?? 0}', 'Total XP', AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _rewardStat('🪙', '${child?.coins ?? 0}', 'Coins', AppColors.secondary)),
                const SizedBox(width: 8),
                Expanded(child: _rewardStat('🔥', '${child?.streakDays ?? 0}', 'Streak', AppColors.orange)),
              ],
            ),

            const SizedBox(height: 20),

            // Trophy showcase
            AnimatedCard(
              gradientColors: AppColors.goldGradient,
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 8),
                  Text('Congratulations!',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('You earned a new badge: Math Master',
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 8),
                  Text('+50 🪙 Coins Earned',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Claim',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: '🥋 Ninja Badges'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final badge = badges[i];
                final unlocked = i < 3;
                return RewardBadge(
                  emoji: badge.emoji,
                  name: badge.name,
                  isUnlocked: unlocked,
                  coins: badge.coinsReward,
                );
              },
            ),

            const SizedBox(height: 24),

            const SectionHeader(title: '🏅 Leaderboard'),
            const SizedBox(height: 12),
            ..._buildLeaderboard(),

            const SizedBox(height: 24),

            // Daily streak card
            AnimatedCard(
              gradientColors: const [Color(0xFFFF6B35), Color(0xFFFFB84C)],
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 44)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${child?.streakDays ?? 0} Day Streak! 🎉',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('Keep it up! Come back tomorrow to continue',
                            style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _rewardStat(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  List<Widget> _buildLeaderboard() {
    final leaders = [
      ('🥇', 'Aarav', '3,250 XP', AppColors.secondary),
      ('🥈', 'Priya', '2,980 XP', Colors.grey.shade400),
      ('🥉', 'Rohan', '2,750 XP', const Color(0xFFCD7F32)),
      ('4️⃣', 'Siya', '2,400 XP', AppColors.primary),
      ('5️⃣', 'Ananya', '2,100 XP', AppColors.primary),
    ];

    return leaders.map((l) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AnimatedCard(
          child: Row(
            children: [
              Text(l.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              NinjaAvatar(avatarId: 'ninja${leaders.indexOf(l) + 1}', size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l.$2,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: l.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(l.$3,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: l.$4)),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ─── Child Profile Screen ─────────────────────────────────────────────────────
class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final children = ref.watch(childrenProvider);
    final child = auth.activeChild ?? (children.isNotEmpty ? children.first : null);

    if (child == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: NinjaAppBar(
        title: 'My Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF9C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  NinjaAvatar(avatarId: child.avatarId, size: 90, showGlow: true),
                  const SizedBox(height: 12),
                  Text(child.name,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('${child.grade} • Ninja Level ${child.level}',
                      style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _headerStat('⭐', '${child.totalXP}', 'XP'),
                      _vDivider(),
                      _headerStat('🪙', '${child.coins}', 'Coins'),
                      _vDivider(),
                      _headerStat('🔥', '${child.streakDays}', 'Streak'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  XPProgressBar(
                    current: child.totalXP % 500,
                    max: 500,
                    level: child.level,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar change
                  const SectionHeader(title: '🥷 Change Avatar'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AvatarOption.all.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final av = AvatarOption.all[i];
                        final selected = av.id == child.avatarId;
                        return GestureDetector(
                          onTap: () {},
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: selected ? AppGradients.gold : null,
                              color: selected ? null : Colors.grey.shade100,
                              boxShadow: selected ? [
                                BoxShadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 10),
                              ] : [],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(av.emoji, style: const TextStyle(fontSize: 32)),
                                if (av.isPremium)
                                  const Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Text('⭐', style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SectionHeader(title: '📊 My Stats'),
                  const SizedBox(height: 12),
                  AnimatedCard(
                    child: Column(
                      children: [
                        _statRow('🎯', 'Quizzes Completed', '47'),
                        _divider(),
                        _statRow('✅', 'Correct Answers', '384'),
                        _divider(),
                        _statRow('⏱️', 'Total Learning Time', '6h 30m'),
                        _divider(),
                        _statRow('🏆', 'Badges Earned', '3'),
                        _divider(),
                        _statRow('📅', 'Member Since', 'Jan 2025'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menu items
                  const SectionHeader(title: '⚙️ Settings'),
                  const SizedBox(height: 12),
                  AnimatedCard(
                    child: Column(
                      children: [
                        _menuItem('🏅', 'My Badges', () => context.push(AppRoutes.rewards)),
                        _divider(),
                        _menuItem('📜', 'My Certificates', () {}),
                        _divider(),
                        _menuItem('⚙️', 'Settings', () => context.push(AppRoutes.settings)),
                        _divider(),
                        _menuItem('🚪', 'Switch to Parent', () {
                          ref.read(authStateProvider.notifier).switchToParent();
                          context.go(AppRoutes.parentDashboard);
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60)),
      ],
    );
  }

  Widget _vDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _statRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text(value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }

  Widget _menuItem(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 20);
}
