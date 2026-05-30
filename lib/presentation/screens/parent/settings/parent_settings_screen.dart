import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/app_providers.dart';
import '../../../../services/auth/auth_service.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Account', [
            _tile(Icons.person_outline, 'Profile', () {}),
            _tile(Icons.lock_outline, 'Change Password', () {}),
          ]),
          _section('App', [
            _tile(Icons.dark_mode_outlined, 'Dark Mode', () {
              ref.read(themeModeProvider.notifier).toggle();
            }),
            _tile(Icons.language, 'Language', () {}),
            _tile(Icons.notifications_outlined, 'Notifications', () {}),
          ]),
          _section('Subscription', [
            _tile(Icons.star_outline, 'Upgrade to Premium', () {},
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('PRO',
                  style: TextStyle(
                    color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
          _section('Support', [
            _tile(Icons.help_outline, 'Help & FAQ', () {}),
            _tile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          ]),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go(Routes.parentLogin);
            },
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800,
              color: Colors.grey, letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E4FF), width: 1.5),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryPurple),
      title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
