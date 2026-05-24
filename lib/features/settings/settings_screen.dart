import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // All toggle states - local state so they actually work
  bool _soundEffects = true;
  bool _voiceInput = true;
  bool _dailyReminders = true;
  bool _rewardAlerts = true;
  bool _streakReminders = true;
  bool _largeText = false;
  bool _colorBlindMode = false;
  bool _dyslexiaMode = false;
  String _language = 'English';
  String _voiceSpeed = 'Normal';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: const NinjaAppBar(title: '⚙️ Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info
            AnimatedCard(
              gradientColors: AppColors.primaryGradient,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/images/logo.png', width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Text('🥷', style: TextStyle(fontSize: 34))),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NinjaKids', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Learn • Play • Level Up', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                      Text('Version 1.0.0', style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Appearance ──────────────────────────────────────────────
            _sectionLabel('🎨 Appearance'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _toggleRow(
                    emoji: '🌙',
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                    value: isDark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                  ),
                  _divider(),
                  _dropdownRow(
                    emoji: '🌐',
                    title: 'Language',
                    value: _language,
                    options: ['English', 'Marathi', 'Hindi'],
                    onChanged: (v) { if (v != null) setState(() => _language = v); },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Audio & Voice ────────────────────────────────────────────
            _sectionLabel('🔊 Audio & Voice'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _toggleRow(
                    emoji: '🔊',
                    title: 'Sound Effects',
                    subtitle: 'Game sounds and alerts',
                    value: _soundEffects,
                    onChanged: (v) => setState(() => _soundEffects = v),
                  ),
                  _divider(),
                  _toggleRow(
                    emoji: '🎤',
                    title: 'Voice Input',
                    subtitle: 'Speak your answers',
                    value: _voiceInput,
                    onChanged: (v) => setState(() => _voiceInput = v),
                  ),
                  _divider(),
                  _dropdownRow(
                    emoji: '🤖',
                    title: 'AI Voice Speed',
                    value: _voiceSpeed,
                    options: ['Slow', 'Normal', 'Fast'],
                    onChanged: (v) { if (v != null) setState(() => _voiceSpeed = v); },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Notifications ────────────────────────────────────────────
            _sectionLabel('🔔 Notifications'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _toggleRow(
                    emoji: '🔔',
                    title: 'Daily Reminders',
                    subtitle: 'Get reminded to learn each day',
                    value: _dailyReminders,
                    onChanged: (v) => setState(() => _dailyReminders = v),
                  ),
                  _divider(),
                  _toggleRow(
                    emoji: '🏆',
                    title: 'Reward Alerts',
                    subtitle: 'Notify when badges are earned',
                    value: _rewardAlerts,
                    onChanged: (v) => setState(() => _rewardAlerts = v),
                  ),
                  _divider(),
                  _toggleRow(
                    emoji: '🔥',
                    title: 'Streak Reminders',
                    subtitle: 'Don\'t break your learning streak',
                    value: _streakReminders,
                    onChanged: (v) => setState(() => _streakReminders = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Accessibility ────────────────────────────────────────────
            _sectionLabel('♿ Accessibility'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _toggleRow(
                    emoji: '🔠',
                    title: 'Large Text',
                    subtitle: 'Bigger font size for readability',
                    value: _largeText,
                    onChanged: (v) => setState(() => _largeText = v),
                  ),
                  _divider(),
                  _toggleRow(
                    emoji: '🎨',
                    title: 'Color Blind Mode',
                    subtitle: 'High contrast colours',
                    value: _colorBlindMode,
                    onChanged: (v) => setState(() => _colorBlindMode = v),
                  ),
                  _divider(),
                  _toggleRow(
                    emoji: '📖',
                    title: 'Dyslexia-Friendly Mode',
                    subtitle: 'Easier-to-read font',
                    value: _dyslexiaMode,
                    onChanged: (v) => setState(() => _dyslexiaMode = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Account ──────────────────────────────────────────────────
            _sectionLabel('👤 Account'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _navRow(emoji: '⭐', title: 'Premium Plans', subtitle: 'Unlock all features',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(gradient: AppGradients.gold, borderRadius: BorderRadius.circular(8)),
                        child: Text('Upgrade', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      onTap: () => context.push(AppRoutes.subscription)),
                  _divider(),
                  _navRow(emoji: '🔒', title: 'Privacy & Safety', subtitle: 'Data and permissions',
                      onTap: () => _showComingSoon('Privacy settings')),
                  _divider(),
                  _navRow(emoji: '📋', title: 'Terms of Service', subtitle: 'App usage policies',
                      onTap: () => _showComingSoon('Terms of Service')),
                  _divider(),
                  _navRow(emoji: '💬', title: 'Help & Support', subtitle: 'FAQs and contact',
                      onTap: () => _showComingSoon('Help & Support')),
                  _divider(),
                  _navRow(
                    emoji: '🚪',
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    titleColor: AppColors.red,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Logout?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                          content: Text('Are you sure you want to logout?', style: GoogleFonts.nunito()),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Logout', style: TextStyle(color: AppColors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) context.go(AppRoutes.splash);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey));

  Widget _divider() => const Divider(height: 20);

  Widget _toggleRow({
    required String emoji, required String title, required String subtitle,
    required bool value, required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dropdownRow({
    required String emoji, required String title, required String value,
    required List<String> options, required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _navRow({
    required String emoji, required String title, required String subtitle,
    Widget? trailing, VoidCallback? onTap, Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor)),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon! 🚀', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Subscription Screen ──────────────────────────────────────────────────────
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 2;

  static const _plans = [
    _Plan(label: 'Free', price: '₹0', period: 'forever', emoji: '🆓',
        color: Color(0xFF888888), features: ['5 quizzes/day', 'Basic subjects', 'Limited AI tutor'], isPopular: false),
    _Plan(label: 'Monthly', price: '₹199', period: '/month', emoji: '⭐',
        color: AppColors.primary, features: ['Unlimited quizzes', 'All subjects', 'Full AI tutor', 'Progress reports'], isPopular: false),
    _Plan(label: 'Yearly', price: '₹999', period: '/year', emoji: '🏆',
        color: AppColors.secondary, features: ['All Monthly features', 'Premium games', 'Advanced analytics', 'Offline mode'], isPopular: true, savings: 'Save 58%'),
    _Plan(label: 'Family', price: '₹1499', period: '/year', emoji: '👨‍👩‍👧‍👦',
        color: AppColors.green, features: ['Up to 5 children', 'All Yearly features', 'Family dashboard'], isPopular: false),
  ];

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];
    return Scaffold(
      appBar: const NinjaAppBar(title: '⭐ Premium Plans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedCard(
              gradientColors: AppColors.goldGradient,
              child: Column(children: [
                const Text('🥷', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text('Go Premium!', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Unlock all features & premium content', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
              ]),
            ),

            const SizedBox(height: 20),

            ...List.generate(_plans.length, (i) {
              final p = _plans[i];
              final sel = i == _selectedPlan;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: sel ? LinearGradient(colors: [p.color, p.color.withValues(alpha: 0.7)]) : null,
                    color: sel ? null : (Theme.of(context).brightness == Brightness.dark ? AppColors.bgDarkCard : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? p.color : Colors.grey.withValues(alpha: 0.2), width: sel ? 2 : 1),
                    boxShadow: [BoxShadow(color: (sel ? p.color : Colors.black).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(p.label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: sel ? Colors.white : null)),
                              if (p.isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: sel ? Colors.white.withValues(alpha: 0.25) : AppColors.secondary, borderRadius: BorderRadius.circular(6)),
                                  child: Text('BEST', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ],
                              if (p.savings != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.green.withValues(alpha: sel ? 0.3 : 0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(p.savings!, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.green)),
                                ),
                              ],
                            ]),
                            const SizedBox(height: 4),
                            ...p.features.take(3).map((f) => Text('✓ $f',
                                style: GoogleFonts.nunito(fontSize: 11, color: sel ? Colors.white.withValues(alpha: 0.9) : AppColors.textGrey))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(p.price, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: sel ? Colors.white : p.color)),
                          Text(p.period, style: GoogleFonts.nunito(fontSize: 11, color: sel ? Colors.white70 : AppColors.textGrey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            GradientButton(
              text: _selectedPlan == 0 ? 'Continue Free' : 'Subscribe — ${plan.price}${plan.period}',
              colors: [plan.color, plan.color.withValues(alpha: 0.7)],
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment integration coming soon! 🚀', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text('Cancel anytime • Secure payment • No hidden fees',
                style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Plan {
  final String label, price, period, emoji;
  final Color color;
  final List<String> features;
  final bool isPopular;
  final String? savings;
  const _Plan({required this.label, required this.price, required this.period,
      required this.emoji, required this.color, required this.features,
      required this.isPopular, this.savings});
}
