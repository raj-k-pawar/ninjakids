import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth/auth_service.dart';

class AddKidScreen extends ConsumerStatefulWidget {
  const AddKidScreen({super.key});

  @override
  ConsumerState<AddKidScreen> createState() => _AddKidScreenState();
}

class _AddKidScreenState extends ConsumerState<AddKidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _selectedAvatar = '🦊';
  String _selectedClass = 'Class 5';
  int _selectedAge = 10;
  int _screenTimeLimit = 60;
  List<String> _allowedSubjects = List.from(AppConstants.subjects);
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final authService = ref.read(authServiceProvider);
      final parentId = authService.currentUser?.uid ?? '';
      await authService.addKidProfile(
        parentId: parentId,
        name: _nameCtrl.text.trim(),
        avatarEmoji: _selectedAvatar,
        age: _selectedAge,
        className: _selectedClass,
        pin: _pinCtrl.text.trim(),
        allowedSubjects: _allowedSubjects,
        dailyScreenTimeLimitMinutes: _screenTimeLimit,
      );
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('Add Kid Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar picker
              const Text('Choose Avatar',
                style: TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 14, color: AppTheme.darkNavy)),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.avatarEmojis.length,
                  itemBuilder: (context, i) {
                    final emoji = AppConstants.avatarEmojis[i];
                    final selected = emoji == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = emoji),
                      child: Container(
                        width: 52,
                        height: 52,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryPurple : AppTheme.cardBg,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: AppTheme.primaryPurple, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: "Kid's name",
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              // Age + Class row
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedAge,
                    decoration: const InputDecoration(labelText: 'Age'),
                    items: List.generate(16, (i) => i + 3)
                        .map((a) => DropdownMenuItem(value: a, child: Text('$a yrs')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAge = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedClass,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: AppConstants.classes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClass = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              // PIN
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '4-digit PIN for kid',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: (v) =>
                    v == null || v.length != 4 ? 'Enter a 4-digit PIN' : null,
              ),
              const SizedBox(height: 12),
              // Screen time
              Row(children: [
                const Text('Daily Screen Time Limit:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_screenTimeLimit ~/ 60}h ${_screenTimeLimit % 60}m',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppTheme.primaryPurple)),
              ]),
              Slider(
                value: _screenTimeLimit.toDouble(),
                min: 15,
                max: 180,
                divisions: 11,
                activeColor: AppTheme.primaryPurple,
                onChanged: (v) => setState(() => _screenTimeLimit = v.round()),
              ),
              const SizedBox(height: 8),
              // Subjects
              const Text('Allowed Subjects',
                style: TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 14, color: AppTheme.darkNavy)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.subjects.map((s) {
                  final allowed = _allowedSubjects.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: allowed,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _allowedSubjects.add(s);
                      } else {
                        _allowedSubjects.remove(s);
                      }
                    }),
                    selectedColor: AppTheme.cardBg,
                    checkmarkColor: AppTheme.primaryPurple,
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                    style: const TextStyle(color: Color(0xFF991B1B))),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Profile 🥷'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
