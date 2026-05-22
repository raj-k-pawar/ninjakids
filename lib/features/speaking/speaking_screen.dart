import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninjakids/core/theme/app_theme.dart';
import 'package:ninjakids/shared/widgets/shared_widgets.dart';

class SpeakingScreen extends ConsumerStatefulWidget {
  final String subject;
  const SpeakingScreen({super.key, required this.subject});

  @override
  ConsumerState<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends ConsumerState<SpeakingScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _hasRecorded = false;
  int _score = 0;
  int _currentPhraseIndex = 0;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  final _englishPhrases = [
    'Repeat after me',
    'How are you today?',
    'The quick brown fox jumps over the lazy dog.',
    'I love learning new things every day.',
    'Practice makes perfect!',
  ];

  final _marathiPhrases = [
    'माझे नाव काय आहे?',
    'तुम्ही कसे आहात?',
    'मला शिकणे आवडते.',
    'आज खूप छान दिवस आहे.',
    'मराठी ही आपली भाषा आहे.',
  ];

  List<String> get _phrases =>
      widget.subject == 'Marathi' ? _marathiPhrases : _englishPhrases;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..repeat();
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _hasRecorded = false;
        _score = 0;
        _recordSeconds = 0;
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() => _recordSeconds++);
          if (_recordSeconds >= 5) _stopListening();
        });
      } else {
        _stopListening();
      }
    });
  }

  void _stopListening() {
    _recordTimer?.cancel();
    setState(() {
      _isListening = false;
      _hasRecorded = true;
      _score = 75 + Random().nextInt(26); // Simulated score 75-100
    });
  }

  void _nextPhrase() {
    setState(() {
      _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
      _hasRecorded = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = widget.subject == 'Marathi';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isMarathi
        ? [AppColors.marathiColor, const Color(0xFFE65100)]
        : [AppColors.blue, const Color(0xFF0070CC)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientColors.first.withOpacity(0.1), isDark ? AppColors.bgDark : Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.bgDarkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${isMarathi ? '🗣️' : '📖'} ${widget.subject} Speaking',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          Text('AI Pronunciation Tutor',
                              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPhraseIndex + 1}/${_phrases.length}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Tutor mascot
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, child) => Transform.scale(
                  scale: _isListening ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.4),
                        blurRadius: _isListening ? 24 : 12,
                        spreadRadius: _isListening ? 6 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isMarathi ? '👩‍🏫' : '👨‍🏫',
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isMarathi ? 'AI मराठी शिक्षक' : 'AI English Tutor',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 24),

              // Phrase cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // "Repeat after me" card
                    AnimatedCard(
                      gradientColors: gradientColors,
                      child: Column(
                        children: [
                          Text(
                            'Repeat after me',
                            style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _phrases[_currentPhraseIndex],
                            style: GoogleFonts.poppins(
                              fontSize: isMarathi ? 20 : 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Play button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.volume_up, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Listen', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Waveform display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgDarkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
                      ),
                      child: _isListening
                          ? _buildWaveform(gradientColors)
                          : Center(
                              child: Text(
                                _hasRecorded ? 'Analysing your pronunciation...' : 'Tap the mic to speak',
                                style: GoogleFonts.nunito(color: AppColors.textGrey, fontSize: 14),
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Score display
                    if (_hasRecorded) ...[
                      AnimatedCard(
                        gradientColors: _score >= 85
                            ? AppColors.greenGradient
                            : _score >= 70
                                ? AppColors.goldGradient
                                : AppColors.redGradient,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _score >= 85 ? '🎉 Excellent!' : _score >= 70 ? '👍 Good job!' : '💪 Keep practicing!',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                Text('Score: $_score/100',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '$_score',
                              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _nextPhrase,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Next Phrase',
                                style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Mic button
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Container(
                    width: _isListening ? 90 : 80,
                    height: _isListening ? 90 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isListening
                          ? const LinearGradient(colors: [AppColors.red, Color(0xFFFF8C42)])
                          : LinearGradient(colors: gradientColors),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? AppColors.red : gradientColors.first).withOpacity(0.4),
                          blurRadius: _isListening ? 24 : 16,
                          spreadRadius: _isListening ? 6 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isListening
                    ? '🔴 Recording... ${_recordSeconds}s'
                    : _hasRecorded
                        ? '🔄 Try again'
                        : '🎙️ Tap to speak',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveform(List<Color> colors) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(30, (i) {
            final height = (sin((_waveController.value * 2 * pi) + (i * 0.4)) + 1) * 20 + 8;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }
}
