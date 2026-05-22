import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/routes/app_router.dart';
import 'package:ninjakids/services/app_providers.dart';
import 'package:ninjakids/shared/models/app_models.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';
import 'package:ninjakids/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class CreateChildProfile extends ConsumerStatefulWidget {
  const CreateChildProfile({super.key});

  @override
  ConsumerState<CreateChildProfile> createState() => _CreateChildProfileState();
}

class _CreateChildProfileState extends ConsumerState<CreateChildProfile> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedAge = 8;
  String _selectedGrade = 'Class 3';
  String _selectedAvatar = 'ninja1';
  String _selectedLanguage = 'English';
  bool _voiceLearning = true;
  bool _aiTutor = true;
  double _screenTime = 1.5;
  String _pin = '1234';
  int _step = 0;

  final _steps = ['Basic Info', 'Avatar', 'Settings'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authStateProvider);
    final child = ChildProfile(
      id: const Uuid().v4(),
      parentId: auth.parentUser?.id ?? 'parent_001',
      name: _nameController.text.trim(),
      age: _selectedAge,
      grade: _selectedGrade,
      avatarId: _selectedAvatar,
      language: _selectedLanguage,
      voiceLearningEnabled: _voiceLearning,
      aiTutorEnabled: _aiTutor,
      dailyScreenTimeMinutes: (_screenTime * 60).toInt(),
      enabledSubjects: AppConstants.subjects,
      pin: _pin,
    );
    ref.read(childrenProvider.notifier).addChild(child);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NinjaAppBar(
        title: 'Create Child Profile',
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: Text('Back', style: GoogleFonts.poppins(color: AppColors.primary)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(_steps.length, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return Expanded(
                    child: Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: done ? AppColors.primary : Colors.grey.shade300,
                            ),
                          ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done || active ? AppColors.primary : Colors.grey.shade300,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: active ? Colors.white : Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: done ? AppColors.primary : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStep(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: GradientButton(
                text: _step < 2 ? 'Continue →' : '✅ Create Profile',
                onTap: () {
                  if (_step < 2) {
                    setState(() => _step++);
                  } else {
                    _createProfile();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildBasicInfo();
      case 1: return _buildAvatarStep();
      case 2: return _buildSettingsStep();
      default: return const SizedBox();
    }
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👦', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('Child\'s Basic Info', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        _label('Child Name'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: _dec('Enter child\'s name', Icons.person_outline),
          validator: (v) => v == null || v.isEmpty ? 'Please enter name' : null,
        ),
        const SizedBox(height: 20),
        _label('Age'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.ages.map((age) {
            final selected = age == _selectedAge;
            return GestureDetector(
              onTap: () => setState(() => _selectedAge = age),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.primary : null,
                  color: selected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    '$age',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _label('Class / Standard'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.grades.map((grade) {
            final selected = grade == _selectedGrade;
            return GestureDetector(
              onTap: () => setState(() => _selectedGrade = grade),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.primary : null,
                  color: selected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                ),
                child: Text(
                  grade,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _label('Preferred Language'),
        const SizedBox(height: 8),
        Row(
          children: ['English', 'Marathi', 'Hindi'].map((lang) {
            final selected = lang == _selectedLanguage;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedLanguage = lang),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: selected ? AppGradients.primary : null,
                    color: selected ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                  ),
                  child: Text(
                    lang,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🥷', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('Choose Your Ninja', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Pick a ninja avatar for ${_nameController.text.isEmpty ? "your child" : _nameController.text}',
            style: GoogleFonts.nunito(color: AppColors.textGrey)),
        const SizedBox(height: 24),
        // Preview
        Center(
          child: NinjaAvatar(avatarId: _selectedAvatar, size: 100, showGlow: true),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: AvatarOption.all.length,
          itemBuilder: (_, i) {
            final av = AvatarOption.all[i];
            final selected = av.id == _selectedAvatar;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = av.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected ? AppGradients.gold : null,
                  color: selected ? null : Colors.grey.shade100,
                  boxShadow: selected ? [
                    BoxShadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2),
                  ] : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(av.emoji, style: const TextStyle(fontSize: 36)),
                    if (av.isPremium)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: const Text('⭐', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚙️', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text('Learning Settings', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),

        AnimatedCard(
          child: Column(
            children: [
              _settingToggle('🎤 Enable Voice Learning', 'Learn with AI voice guidance', _voiceLearning,
                  (v) => setState(() => _voiceLearning = v)),
              const Divider(height: 24),
              _settingToggle('🤖 Enable AI Tutor', 'Get help from AI tutor anytime', _aiTutor,
                  (v) => setState(() => _aiTutor = v)),
            ],
          ),
        ),

        const SizedBox(height: 20),

        AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('⏰ Daily Screen Time', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${_screenTime.toStringAsFixed(1)} hrs',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10)),
                child: Slider(
                  value: _screenTime,
                  min: 0.5,
                  max: 4,
                  divisions: 7,
                  activeThumbColor: AppColors.primary,
                  inactiveThumbColor: AppColors.primary.withValues(alpha: 0.2),
                  onChanged: (v) => setState(() => _screenTime = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('30 min', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                  Text('4 hrs', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔐 Child PIN', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Child will use this PIN to access the app',
                  style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _pin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (v) => _pin = v,
                decoration: _dec('4-digit PIN', Icons.pin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
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
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
  );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
