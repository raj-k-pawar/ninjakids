import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/models/app_models.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';
import 'package:ninjakids/core/constants/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';

// ─── Screen Time Manager ─────────────────────────────────────────────────────
class ScreenTimeManager extends ConsumerStatefulWidget {
  const ScreenTimeManager({super.key});

  @override
  ConsumerState<ScreenTimeManager> createState() => _ScreenTimeManagerState();
}

class _ScreenTimeManagerState extends ConsumerState<ScreenTimeManager> {
  double _dailyLimit = 2.0;
  TimeOfDay _studyStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _studyEnd = const TimeOfDay(hour: 20, minute: 0);
  bool _breakReminder = true;
  bool _appLock = true;
  int _breakInterval = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NinjaAppBar(title: '⏰ Screen Time'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's usage
            AnimatedCard(
              gradientColors: [AppColors.blue, const Color(0xFF0099CC)],
              child: Column(
                children: [
                  Text("Today's Usage", style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '1h 20m',
                    style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text('of ${_dailyLimit.toStringAsFixed(1)}h daily limit',
                      style: GoogleFonts.nunito(color: Colors.white70)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 1.33 / (_dailyLimit * 60) * 60,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SectionHeader(title: 'Daily Limit'),
            const SizedBox(height: 12),
            AnimatedCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Time Limit', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${_dailyLimit.toStringAsFixed(1)} Hours',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue)),
                    ],
                  ),
                  Slider(
                    value: _dailyLimit,
                    min: 0.5,
                    max: 6,
                    divisions: 11,
                    activeColor: AppColors.blue,
                    onChanged: (v) => setState(() => _dailyLimit = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SectionHeader(title: 'Study Schedule'),
            const SizedBox(height: 12),
            AnimatedCard(
              child: Column(
                children: [
                  _timeTile('Study Start Time', _studyStart, () async {
                    final t = await showTimePicker(context: context, initialTime: _studyStart);
                    if (t != null) setState(() => _studyStart = t);
                  }),
                  const Divider(height: 24),
                  _timeTile('Study End Time', _studyEnd, () async {
                    final t = await showTimePicker(context: context, initialTime: _studyEnd);
                    if (t != null) setState(() => _studyEnd = t);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SectionHeader(title: 'App Controls'),
            const SizedBox(height: 12),
            AnimatedCard(
              child: Column(
                children: [
                  _toggleTile('🔔 Break Reminder', 'Every $_breakInterval minutes', _breakReminder,
                      (v) => setState(() => _breakReminder = v)),
                  const Divider(height: 24),
                  _toggleTile('🔒 App Lock After Limit', 'Lock app after daily limit reached', _appLock,
                      (v) => setState(() => _appLock = v)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GradientButton(
              text: '💾 Save Changes',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settings saved! ✅', style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time.format(context),
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
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
  }
}

// ─── Subject Access Screen ────────────────────────────────────────────────────
class SubjectAccessScreen extends ConsumerStatefulWidget {
  final String childId;
  const SubjectAccessScreen({super.key, required this.childId});

  @override
  ConsumerState<SubjectAccessScreen> createState() => _SubjectAccessScreenState();
}

class _SubjectAccessScreenState extends ConsumerState<SubjectAccessScreen> {
  late Map<String, bool> _subjectEnabled;
  late Map<String, String> _subjectDifficulty;

  @override
  void initState() {
    super.initState();
    final children = ref.read(childrenProvider);
    final child = children.firstWhere((c) => c.id == widget.childId, orElse: () => children.first);
    _subjectEnabled = {
      for (final s in AppConstants.subjects)
        s: child.enabledSubjects.contains(s),
    };
    _subjectDifficulty = {
      for (final s in AppConstants.subjects) s: 'Medium',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NinjaAppBar(title: '📗 Subject Access'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AnimatedCard(
              gradientColors: [AppColors.green, const Color(0xFF00A86B)],
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable or disable subjects for your child. AI will auto-recommend based on grade.',
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: SubjectInfo.all.length,
              itemBuilder: (_, i) {
                final sub = SubjectInfo.all[i];
                final enabled = _subjectEnabled[sub.name] ?? true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: enabled ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(sub.emoji, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sub.name,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                                  Text(sub.description,
                                      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: enabled,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _subjectEnabled[sub.name] = v),
                            ),
                          ],
                        ),
                        if (enabled) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: ['Easy', 'Medium', 'Hard'].map((d) {
                              final selected = _subjectDifficulty[sub.name] == d;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _subjectDifficulty[sub.name] = d),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? (d == 'Easy' ? AppColors.green : d == 'Medium' ? AppColors.secondary : AppColors.red)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      d,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected ? Colors.white : AppColors.textGrey,
                                      ),
                                    ),
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
            child: GradientButton(
              text: '💾 Save Changes',
              onTap: () {
                final enabled = _subjectEnabled.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList();
                ref.read(childrenProvider.notifier).updateChild(
                  ref.read(childrenProvider).firstWhere((c) => c.id == widget.childId).copyWith(
                    enabledSubjects: enabled,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Analytics Screen ────────────────────────────────────────────────
class ProgressAnalyticsScreen extends ConsumerWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final progress = ref.watch(subjectProgressProvider);
    final child = children.isNotEmpty ? children.first : null;

    return Scaffold(
      appBar: NinjaAppBar(title: '📊 Progress Report'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child selector
            if (child != null)
              AnimatedCard(
                gradientColors: AppColors.primaryGradient,
                child: Row(
                  children: [
                    NinjaAvatar(avatarId: child.avatarId, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.name,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('${child.grade} • Level ${child.level}',
                              style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const DropdownButton<String>(
                      value: 'This Week',
                      dropdownColor: AppColors.bgDarkCard,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: [
                        DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      ],
                      onChanged: null,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Overall progress
            SectionHeader(title: 'Overall Progress'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedCard(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: 0.78,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                strokeWidth: 10,
                              ),
                            ),
                            Text('78%',
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Overall', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      StatChip(emoji: '⏱️', value: '6h 30m', label: 'Learning\nTime', color: AppColors.blue),
                      const SizedBox(height: 8),
                      StatChip(emoji: '✅', value: '83%', label: 'Quiz\nAccuracy', color: AppColors.green),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Subject performance
            SectionHeader(title: 'Subject Performance'),
            const SizedBox(height: 12),
            AnimatedCard(
              child: Column(
                children: progress.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.subject,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${p.accuracy.toInt()}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.accuracy >= 80 ? AppColors.green : p.accuracy >= 60 ? AppColors.secondary : AppColors.red,
                                )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p.accuracy / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              p.accuracy >= 80 ? AppColors.green : p.accuracy >= 60 ? AppColors.secondary : AppColors.red,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Weekly chart
            SectionHeader(title: 'Weekly Activity'),
            const SizedBox(height: 12),
            AnimatedCard(
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 120,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Text(
                              days[v.toInt()],
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _barGroup(0, 60),
                      _barGroup(1, 90),
                      _barGroup(2, 45),
                      _barGroup(3, 110),
                      _barGroup(4, 75),
                      _barGroup(5, 30),
                      _barGroup(6, 85),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: AppGradients.primary,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}
