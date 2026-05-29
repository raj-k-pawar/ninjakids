import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/entities.dart';
import '../../../providers/parent_providers.dart';
import '../../../widgets/parent/weekly_chart.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState
    extends ConsumerState<ParentDashboardScreen> {
  int _selectedKidIndex = 0;
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(currentParentProvider);
    final kidsAsync = ref.watch(parentKidsProvider);

    return Scaffold(
      body: parentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (parent) => kidsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (kids) => _buildDashboard(parent, kids),
        ),
      ),
    );
  }

  Widget _buildDashboard(ParentEntity parent, List<KidEntity> kids) {
    final selectedKid = kids.isNotEmpty ? kids[_selectedKidIndex] : null;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(parent),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildOverviewTab(parent, kids, selectedKid),
                _buildAnalyticsTab(selectedKid),
                _buildControlsTab(selectedKid),
                _buildSettingsTab(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader(ParentEntity parent) {
    return Container(
      color: AppTheme.darkNavy,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${parent.name.split(' ').first}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'FredokaOne',
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${parent.subscriptionPlan == 'premium' ? '⭐ Premium' : '🆓 Free'} Plan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white70),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Colors.white70),
                onPressed: () => context.push(Routes.parentSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    ParentEntity parent,
    List<KidEntity> kids,
    KidEntity? selectedKid,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Text(
                  'My Children',
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 18,
                    color: AppTheme.darkNavy,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(Routes.addKid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add,
                            size: 16, color: AppTheme.primaryPurple),
                        SizedBox(width: 4),
                        Text(
                          'Add Kid',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: kids.isEmpty
                ? _buildAddKidPrompt()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                    itemCount: kids.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedKidIndex = index),
                        child: _buildKidChip(
                          kids[index],
                          isSelected: index == _selectedKidIndex,
                        ),
                      );
                    },
                  ),
          ),
          if (selectedKid != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _buildScreenTimeCard(selectedKid)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildQuizStatsCard(selectedKid)),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Weekly Activity',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 18,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  WeeklyChart(kidId: selectedKid.id),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '📚 Subject Performance',
                        style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize: 18,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            context.push(Routes.parentAnalytics),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  SubjectPerformanceList(kidId: selectedKid.id),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildKidChip(KidEntity kid, {required bool isSelected}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.cardBg : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPurple
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Center(
              child:
                  Text(kid.avatarEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kid.name.split(' ').first,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppTheme.primaryPurple : AppTheme.darkNavy,
            ),
          ),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeCard(KidEntity kid) {
    final used = kid.todayScreenTimeMinutes;
    final limit = kid.dailyScreenTimeLimitMinutes;
    final pct = (used / limit).clamp(0.0, 1.0);
    final isNearLimit = pct > 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNearLimit ? const Color(0xFFFFF3CD) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearLimit
              ? const Color(0xFFFFD93D)
              : const Color(0xFFE8E4FF),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNearLimit ? '⚠️ Screen Time' : '⏱ Screen Time',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isNearLimit
                  ? const Color(0xFF92660A)
                  : AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatMinutes(used)} / ${_formatMinutes(limit)}',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: isNearLimit
                  ? const Color(0xFF92660A)
                  : AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit
                    ? AppTheme.accentOrange
                    : AppTheme.accentGreen,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).round()}% used',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStatsCard(KidEntity kid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF5E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 This Week',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '34 / 40',
            style: TextStyle(
              fontFamily: 'FredokaOne',
              fontSize: 18,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '85% accuracy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${kid.currentStreak} day streak',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddKidPrompt() {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(Routes.addKid),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppTheme.primaryPurple),
              SizedBox(width: 8),
              Text(
                'Add your first child to get started!',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(KidEntity? kid) {
    if (kid == null) {
      return const Center(child: Text('Select a child first'));
    }
    return const Center(child: Text('📊 Detailed Analytics'));
  }

  Widget _buildControlsTab(KidEntity? kid) {
    if (kid == null) {
      return const Center(child: Text('Select a child first'));
    }
    return const Center(child: Text('🎮 Parental Controls'));
  }

  Widget _buildSettingsTab() => const Center(child: Text('⚙️ Settings'));

  Widget _buildBottomNav() {
    const tabs = [
      {'icon': Icons.home_rounded, 'label': 'Overview'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics'},
      {'icon': Icons.shield_rounded, 'label': 'Controls'},
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t['icon'] as IconData),
                  label: t['label'] as String,
                ))
            .toList(),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
