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

class ChildManagementScreen extends ConsumerStatefulWidget {
  final String childId;
  const ChildManagementScreen({super.key, required this.childId});

  @override
  ConsumerState<ChildManagementScreen> createState() => _ChildManagementScreenState();
}

class _ChildManagementScreenState extends ConsumerState<ChildManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider);
    final child = children.firstWhere(
      (c) => c.id == widget.childId,
      orElse: () => children.isNotEmpty ? children.first : const ChildProfile(
        id: '', parentId: '', name: 'Unknown', age: 8,
        grade: 'Class 1', avatarId: 'ninja1',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${child.name}\'s Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.book_outlined), text: 'Subjects'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(child: child),
          _SubjectsTab(child: child),
          _SettingsTab(child: child),
        ],
      ),
    );
  }
}

// ─── Overview Tab ────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final ChildProfile child;
  const _OverviewTab({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child hero card
          AnimatedCard(
            gradientColors: AppColors.primaryGradient,
            child: Row(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(child: Text(_emoji(child.avatarId), style: const TextStyle(fontSize: 40))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('${child.grade} • Age ${child.age}', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _chip('⭐ ${child.totalXP} XP', Colors.white),
                          const SizedBox(width: 8),
                          _chip('🪙 ${child.coins}', Colors.white),
                          const SizedBox(width: 8),
                          _chip('🔥 ${child.streakDays}d', Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Level progress
          const SectionHeader(title: '⭐ Level Progress'),
          const SizedBox(height: 12),
          AnimatedCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${child.level}',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Text('${child.totalXP % 500} / 500 XP',
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
                  ],
                ),
                const SizedBox(height: 8),
                XPProgressBar(current: child.totalXP % 500, max: 500, level: child.level),
                const SizedBox(height: 8),
                Text('${500 - (child.totalXP % 500)} XP until Level ${child.level + 1}',
                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats grid
          const SectionHeader(title: '📊 Stats at a Glance'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.0,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _statCard('🎯', 'Quizzes Done', '47', AppColors.primary),
              _statCard('✅', 'Correct Answers', '384', AppColors.green),
              _statCard('⏱️', 'Time Spent', '6h 30m', AppColors.blue),
              _statCard('🏆', 'Badges', '3 / ${AppBadge.allBadges.length}', AppColors.secondary),
            ],
          ),

          const SizedBox(height: 20),

          // Subject performance
          const SectionHeader(title: '📚 Subject Performance'),
          const SizedBox(height: 12),
          AnimatedCard(
            child: Column(
              children: [
                _subjectRow('English', 0.85, AppColors.blue),
                _subjectRow('Mathematics', 0.78, AppColors.primary),
                _subjectRow('Science', 0.90, AppColors.green),
                _subjectRow('Marathi', 0.80, AppColors.orange),
                _subjectRow('History', 0.65, AppColors.historyColor),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent activity
          const SectionHeader(title: '🕒 Recent Activity'),
          const SizedBox(height: 12),
          ..._recentActivity(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _statCard(String emoji, String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textGrey)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _subjectRow(String subject, double progress, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(subject, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(progress * 100).toInt()}%',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    ),
  );

  List<Widget> _recentActivity() {
    final activities = [
      ('🧮', 'Math Quiz', 'Scored 90% • Earned 45 XP', '2 hours ago', AppColors.primary),
      ('📖', 'English Speaking', 'Pronunciation score: 88%', 'Yesterday', AppColors.blue),
      ('🔬', 'Science Quiz', 'Scored 75% • Earned 30 XP', '2 days ago', AppColors.green),
      ('🤖', 'AI Tutor', 'Asked 5 questions', '3 days ago', AppColors.purple),
    ];
    return activities.map((a) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedCard(
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: a.$5.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(a.$1, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.$2, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(a.$3, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),
            Text(a.$4, style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textGrey)),
          ],
        ),
      ),
    )).toList();
  }

  String _emoji(String id) {
    const map = {'ninja1': '🥷', 'ninja2': '⚔️', 'ninja3': '🌟', 'ninja4': '🦊',
                 'ninja5': '🐲', 'ninja6': '⚡', 'ninja7': '🔥', 'ninja8': '💎'};
    return map[id] ?? '🥷';
  }
}

// ─── Subjects Tab ─────────────────────────────────────────────────────────────
class _SubjectsTab extends ConsumerStatefulWidget {
  final ChildProfile child;
  const _SubjectsTab({required this.child});

  @override
  ConsumerState<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends ConsumerState<_SubjectsTab> {
  late Map<String, bool> _enabled;
  late Map<String, String> _difficulty;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _enabled = {for (final s in AppConstants.subjects) s: widget.child.enabledSubjects.contains(s)};
    _difficulty = {for (final s in AppConstants.subjects) s: 'Medium'};
  }

  void _save() {
    final enabledList = _enabled.entries.where((e) => e.value).map((e) => e.key).toList();
    ref.read(childrenProvider.notifier).updateChild(
      widget.child.copyWith(enabledSubjects: enabledList),
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _saved = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_saved)
          Container(
            width: double.infinity,
            color: AppColors.green,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('✅ Saved!', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: SubjectInfo.all.length,
            itemBuilder: (_, i) {
              final sub = SubjectInfo.all[i];
              final isOn = _enabled[sub.name] ?? true;
              final diff = _difficulty[sub.name] ?? 'Medium';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnimatedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: isOn ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(sub.emoji, style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(sub.description, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: isOn,
                            activeColor: AppColors.primary,
                            onChanged: (v) => setState(() => _enabled[sub.name] = v),
                          ),
                        ],
                      ),
                      if (isOn) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: ['Easy', 'Medium', 'Hard'].map((d) {
                            final sel = diff == d;
                            final c = d == 'Easy' ? AppColors.green : d == 'Medium' ? AppColors.secondary : AppColors.red;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _difficulty[sub.name] = d),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel ? c : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(d, textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
                                          color: sel ? Colors.white : AppColors.textGrey)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GradientButton(text: '💾 Save Subject Settings', onTap: _save),
        ),
      ],
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────
class _SettingsTab extends ConsumerStatefulWidget {
  final ChildProfile child;
  const _SettingsTab({required this.child});

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  late double _screenTime;
  late bool _voiceLearning;
  late bool _aiTutor;
  late TimeOfDay _studyStart;
  late TimeOfDay _studyEnd;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _screenTime = widget.child.dailyScreenTimeMinutes / 60.0;
    _voiceLearning = widget.child.voiceLearningEnabled;
    _aiTutor = widget.child.aiTutorEnabled;
    _studyStart = const TimeOfDay(hour: 7, minute: 0);
    _studyEnd = const TimeOfDay(hour: 20, minute: 0);
  }

  void _save() {
    ref.read(childrenProvider.notifier).updateChild(
      widget.child.copyWith(
        dailyScreenTimeMinutes: (_screenTime * 60).toInt(),
        voiceLearningEnabled: _voiceLearning,
        aiTutorEnabled: _aiTutor,
      ),
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _saved = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_saved)
          Container(
            width: double.infinity,
            color: AppColors.green,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('✅ Settings Saved!', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: '⏰ Screen Time'),
                const SizedBox(height: 12),
                AnimatedCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Limit', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${_screenTime.toStringAsFixed(1)} hrs',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                      Slider(
                        value: _screenTime,
                        min: 0.5, max: 6, divisions: 11,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                        onChanged: (v) => setState(() => _screenTime = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('30 min', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                          Text('6 hrs', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                AnimatedCard(
                  child: Column(
                    children: [
                      _timePicker('📅 Study Start', _studyStart, () async {
                        final t = await showTimePicker(context: context, initialTime: _studyStart);
                        if (t != null) setState(() => _studyStart = t);
                      }),
                      const Divider(height: 20),
                      _timePicker('📅 Study End', _studyEnd, () async {
                        final t = await showTimePicker(context: context, initialTime: _studyEnd);
                        if (t != null) setState(() => _studyEnd = t);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const SectionHeader(title: '🎓 Learning Features'),
                const SizedBox(height: 12),
                AnimatedCard(
                  child: Column(
                    children: [
                      _toggle('🎤 Voice Learning', 'Learn with AI voice guidance',
                          _voiceLearning, (v) => setState(() => _voiceLearning = v)),
                      const Divider(height: 20),
                      _toggle('🤖 AI Tutor', 'Chat with AI tutor anytime',
                          _aiTutor, (v) => setState(() => _aiTutor = v)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const SectionHeader(title: '🔐 Security'),
                const SizedBox(height: 12),
                AnimatedCard(
                  child: Row(
                    children: [
                      const Text('📌', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Child PIN', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('Current PIN: ${widget.child.pin}', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showChangePinDialog(),
                        child: Text('Change', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Danger zone
                AnimatedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('⚠️ Danger Zone', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.red)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _confirmDelete(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('🗑️ Delete Child Profile',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.red),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GradientButton(text: '💾 Save Settings', onTap: _save),
        ),
      ],
    );
  }

  Widget _timePicker(String label, TimeOfDay time, VoidCallback onTap) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(time.format(context),
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ),
    ],
  );

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
      ),
      Switch.adaptive(value: value, activeColor: AppColors.primary, onChanged: onChanged),
    ],
  );

  void _showChangePinDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change PIN', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Enter new 4-digit PIN',
              hintStyle: GoogleFonts.nunito()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.length == 4) {
                ref.read(childrenProvider.notifier).updateChildPin(widget.child.id, ctrl.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PIN updated! ✅', style: GoogleFonts.poppins()), backgroundColor: AppColors.green),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Profile?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.red)),
        content: Text('This will permanently delete ${widget.child.name}\'s profile and all progress. This cannot be undone.',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              ref.read(childrenProvider.notifier).removeChild(widget.child.id);
              Navigator.pop(context);
              context.go(AppRoutes.parentDashboard);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
