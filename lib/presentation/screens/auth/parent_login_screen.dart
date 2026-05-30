import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth/auth_service.dart';

class ParentLoginScreen extends ConsumerStatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  ConsumerState<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends ConsumerState<ParentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedRole = 0; // 0 = Parent, 1 = Kid

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginParent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ref.read(authServiceProvider).loginParent(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go(Routes.parentDashboard);
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go(Routes.parentDashboard);
    } catch (e) {
      setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) return 'Incorrect email or password.';
    if (raw.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    if (raw.contains('network')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('🥷', style: TextStyle(fontSize: 36)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Welcome Back!',
                  style: TextStyle(
                    fontFamily: 'FredokaOne',
                    fontSize: 28,
                    color: AppTheme.darkNavy,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('Sign in to NinjaKids',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 28),
              // Role tabs
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _roleTab(0, '👨‍👩‍👧 Parent'),
                    _roleTab(1, '🧒 Kid'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedRole == 0) ...[
                // Parent login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.length < 6 ? 'Min 6 characters' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginParent,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  icon: const Text('G', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF4285F4))),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("New user? ", style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () => context.push(Routes.register),
                    child: const Text('Create account'),
                  ),
                ]),
              ] else ...[
                // Kid login — redirect to parent dashboard which handles PIN
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    const Text('🧒', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text('Kid Login',
                      style: TextStyle(
                        fontFamily: 'FredokaOne', fontSize: 20,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ask your parent to open the app and select your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _selectedRole = 0),
                      child: const Text('Parent Login Instead'),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTab(int index, String label) {
    final isSelected = _selectedRole == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isSelected ? AppTheme.primaryPurple : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}
