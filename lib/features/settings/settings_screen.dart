import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

// ─── Settings Screen ──────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: NinjaAppBar(title: '⚙️ Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info header
            AnimatedCard(
              gradientColors: AppColors.primaryGradient,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(child: Text('🥷', style: TextStyle(fontSize: 34))),
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

            _sectionLabel('Appearance'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _settingRow(
                    context,
                    icon: '🌙',
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ),
                  _divider(),
                  _settingRow(
                    context,
                    icon: '🌐',
                    title: 'Language',
                    subtitle: 'English',
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('English', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Audio & Voice'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _settingRow(context, icon: '🔊', title: 'Sound Effects', subtitle: 'Game sounds and alerts',
                      trailing: Switch.adaptive(value: true, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '🎤', title: 'Voice Input', subtitle: 'Speak your answers',
                      trailing: Switch.adaptive(value: true, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '🤖', title: 'AI Voice Speed', subtitle: 'Normal',
                      trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Normal', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
                      ]), onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Notifications'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _settingRow(context, icon: '🔔', title: 'Daily Reminders', subtitle: 'Get reminded to learn',
                      trailing: Switch.adaptive(value: true, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '🏆', title: 'Reward Alerts', subtitle: 'Badges and achievements',
                      trailing: Switch.adaptive(value: true, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '🔥', title: 'Streak Reminders', subtitle: 'Don\'t break your streak',
                      trailing: Switch.adaptive(value: true, activeColor: AppColors.primary, onChanged: (_) {})),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Accessibility'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _settingRow(context, icon: '🔠', title: 'Large Text', subtitle: 'Bigger font size',
                      trailing: Switch.adaptive(value: false, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '🎨', title: 'Color Blind Mode', subtitle: 'High contrast colors',
                      trailing: Switch.adaptive(value: false, activeColor: AppColors.primary, onChanged: (_) {})),
                  _divider(),
                  _settingRow(context, icon: '📖', title: 'Dyslexia Mode', subtitle: 'OpenDyslexic font',
                      trailing: Switch.adaptive(value: false, activeColor: AppColors.primary, onChanged: (_) {})),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Account'),
            const SizedBox(height: 8),
            AnimatedCard(
              child: Column(
                children: [
                  _settingRow(context, icon: '⭐', title: 'Premium Plans', subtitle: 'Unlock all features',
                      onTap: () => context.push(AppRoutes.subscription),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(gradient: AppGradients.gold, borderRadius: BorderRadius.circular(8)),
                        child: Text('Upgrade', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      )),
                  _divider(),
                  _settingRow(context, icon: '🔒', title: 'Privacy & Safety', subtitle: 'Data and permissions',
                      onTap: () {}, trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey)),
                  _divider(),
                  _settingRow(context, icon: '📋', title: 'Terms of Service', subtitle: 'App usage policies',
                      onTap: () {}, trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey)),
                  _divider(),
                  _settingRow(
                    context,
                    icon: '🚪',
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    titleColor: AppColors.red,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Logout?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                          content: Text('Are you sure you want to logout?', style: GoogleFonts.nunito()),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Logout', style: TextStyle(color: AppColors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) context.go(AppRoutes.splash);
                      }
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.red),
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey),
    );
  }

  Widget _settingRow(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor)),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 24);
}

// ─── Subscription Screen ──────────────────────────────────────────────────────
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1; // 0=Free, 1=Monthly, 2=Yearly, 3=Family

  final _plans = [
    _Plan(
      label: 'Free',
      price: '₹0',
      period: 'forever',
      emoji: '🆓',
      color: AppColors.textGrey,
      features: ['5 quizzes/day', 'Basic subjects', 'Limited AI tutor'],
      isPopular: false,
    ),
    _Plan(
      label: 'Monthly',
      price: '₹199',
      period: '/month',
      emoji: '⭐',
      color: AppColors.primary,
      features: ['Unlimited quizzes', 'All subjects', 'Full AI tutor', 'Speaking practice', 'Progress reports'],
      isPopular: false,
    ),
    _Plan(
      label: 'Yearly',
      price: '₹999',
      period: '/year',
      emoji: '🏆',
      color: AppColors.secondary,
      features: ['Everything in Monthly', 'Premium games', 'Advanced analytics', 'Priority support', 'Offline mode'],
      isPopular: true,
      savings: 'Save 58%',
    ),
    _Plan(
      label: 'Family',
      price: '₹1499',
      period: '/year',
      emoji: '👨‍👩‍👧‍👦',
      color: AppColors.green,
      features: ['Up to 5 children', 'All yearly features', 'Family dashboard', 'Custom reports'],
      isPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: NinjaAppBar(title: '⭐ Premium Plans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header banner
            AnimatedCard(
              gradientColors: AppColors.goldGradient,
              child: Column(
                children: [
                  const Text('🥷', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text('Go Premium!', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Unlock all features & premium content',
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Plan cards
            ...List.generate(_plans.length, (i) {
              final plan = _plans[i];
              final selected = i == _selectedPlan;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? LinearGradient(
                            colors: [plan.color, plan.color.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: selected ? null : (Theme.of(context).brightness == Brightness.dark ? AppColors.bgDarkCard : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? plan.color : Colors.grey.withValues(alpha: 0.2),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (selected ? plan.color : Colors.black).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : null,
                                  ),
                                ),
                                if (plan.isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.white.withValues(alpha: 0.25) : AppColors.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'BEST VALUE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                if (plan.savings != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withValues(alpha: selected ? 0.3 : 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      plan.savings!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: selected ? Colors.white : AppColors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: plan.features.take(3).map((f) => Text(
                                '✓ $f',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: selected ? Colors.white.withValues(alpha: 0.9) : AppColors.textGrey,
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.price,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: selected ? Colors.white : plan.color,
                            ),
                          ),
                          Text(
                            plan.period,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: selected ? Colors.white70 : AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Features comparison
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_plans[_selectedPlan].emoji} What\'s included in ${_plans[_selectedPlan].label}',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ..._plans[_selectedPlan].features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _plans[_selectedPlan].color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 12, color: _plans[_selectedPlan].color),
                        ),
                        const SizedBox(width: 10),
                        Text(f, style: GoogleFonts.nunito(fontSize: 14)),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GradientButton(
              text: _selectedPlan == 0 ? 'Continue Free' : 'Subscribe - ${_plans[_selectedPlan].price}${_plans[_selectedPlan].period}',
              colors: [_plans[_selectedPlan].color, _plans[_selectedPlan].color.withValues(alpha: 0.7)],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment integration coming soon! 🚀', style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Text(
              'Cancel anytime • Secure payment • No hidden fees',
              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),

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

  const _Plan({
    required this.label,
    required this.price,
    required this.period,
    required this.emoji,
    required this.color,
    required this.features,
    required this.isPopular,
    this.savings,
  });
}
