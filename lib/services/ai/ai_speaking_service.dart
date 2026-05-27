import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

/// Manages AI-powered speaking practice: TTS, STT, pronunciation scoring.
class AiSpeakingService {
  final FlutterTts _tts;
  final stt.SpeechToText _stt;
  final String _apiKey;
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  bool _isListening = false;
  bool _ttsInitialized = false;

  AiSpeakingService({
    required String apiKey,
    FlutterTts? tts,
    stt.SpeechToText? speechToText,
    FirebaseFirestore? firestore,
  })  : _apiKey = apiKey,
        _tts = tts ?? FlutterTts(),
        _stt = speechToText ?? stt.SpeechToText(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _initTts();
  }

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // Slower for kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // Slightly higher pitch for friendliness
    _ttsInitialized = true;
  }

  // ─── Text-to-Speech ───────────────────────────────────────────────────────

  Future<void> speak(String text, {String language = 'en-US'}) async {
    await _initTts();
    await _tts.setLanguage(language == 'marathi' ? 'mr-IN' : 'en-US');
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ─── Speech-to-Text ───────────────────────────────────────────────────────

  Future<bool> initializeSpeechRecognition() async {
    return await _stt.initialize(
      onStatus: (status) {},
      onError: (error) {},
    );
  }

  Future<void> startListening({
    required Function(String words) onResult,
    required Function() onDone,
    String language = 'en-US',
  }) async {
    if (_isListening) return;
    _isListening = true;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onResult(result.recognizedWords);
          onDone();
        } else {
          onResult(result.recognizedWords); // Live preview
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: language == 'marathi' ? 'mr_IN' : 'en_US',
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }

  bool get isListening => _isListening;

  // ─── Pronunciation Scoring ────────────────────────────────────────────────

  /// Scores a kid's spoken attempt against the expected text.
  Future<PronunciationResult> scorePronunciation({
    required String expected,
    required String spoken,
    required String kidName,
    required int kidAge,
  }) async {
    if (spoken.trim().isEmpty) {
      return PronunciationResult(
        pronunciationScore: 0,
        fluencyScore: 0,
        accuracyScore: 0,
        overallScore: 0,
        feedback: "I couldn't hear you clearly. Please try again! 🎤",
        corrections: [],
      );
    }

    final prompt = '''
You are a friendly children's pronunciation coach. Evaluate this speaking attempt.

Expected text: "$expected"
What the child said: "$spoken"
Child's name: $kidName, Age: $kidAge

Evaluate and return ONLY JSON:
{
  "pronunciation_score": 85,
  "fluency_score": 78,
  "accuracy_score": 90,
  "overall_score": 84,
  "feedback": "Great job, $kidName! You said it almost perfectly! 🌟",
  "corrections": [
    {"word": "example", "issue": "slight mispronunciation", "tip": "try: ex-AM-pul"}
  ],
  "encouragement": "You are doing amazing! Keep practicing!"
}

Scores must be 0-100. Be generous and encouraging for children.
''';

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConstants.openAiModel,
          'max_tokens': 500,
          'temperature': 0.3,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a child-friendly pronunciation coach. Return ONLY valid JSON.'
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) throw Exception('API error');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      final cleaned = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final result = jsonDecode(cleaned) as Map<String, dynamic>;

      return PronunciationResult(
        pronunciationScore: result['pronunciation_score'] as int,
        fluencyScore: result['fluency_score'] as int,
        accuracyScore: result['accuracy_score'] as int,
        overallScore: result['overall_score'] as int,
        feedback: result['feedback'] as String,
        corrections: (result['corrections'] as List?)
                ?.map((c) => CorrectionHint(
                      word: c['word'] as String,
                      issue: c['issue'] as String,
                      tip: c['tip'] as String,
                    ))
                .toList() ??
            [],
      );
    } catch (_) {
      // Fallback: simple string similarity scoring
      final similarity = _simpleSimilarity(expected.toLowerCase(), spoken.toLowerCase());
      final score = (similarity * 100).round();
      return PronunciationResult(
        pronunciationScore: score,
        fluencyScore: score,
        accuracyScore: score,
        overallScore: score,
        feedback: score >= 80
            ? "Great job! Keep it up! 🌟"
            : "Good try! Let's practice again! 💪",
        corrections: [],
      );
    }
  }

  // ─── AI Conversation Bot ──────────────────────────────────────────────────

  Future<String> getConversationResponse({
    required String kidMessage,
    required String kidName,
    required int kidAge,
    required List<Map<String, String>> history,
    required String language,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content': '''You are a fun, friendly AI conversation partner for children learning $language.
Kid's name: $kidName, Age: $kidAge years.
Keep responses SHORT (1-2 sentences), simple vocabulary, age-appropriate.
Be encouraging, use emojis occasionally, ask a follow-up question to keep the conversation going.
Language: ${language == 'marathi' ? 'Marathi' : 'English'}.'''
      },
      ...history.map((m) => {'role': m['role']!, 'content': m['content']!}),
      {'role': 'user', 'content': kidMessage},
    ];

    final response = await http.post(
      Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.openAiModel,
        'max_tokens': 200,
        'temperature': 0.8,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      return "That's wonderful! Tell me more! 😊";
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  // ─── Save speaking score ──────────────────────────────────────────────────

  Future<void> saveSpeakingScore({
    required String kidId,
    required String language,
    required String lessonId,
    required String lessonTitle,
    required PronunciationResult result,
    required String level,
  }) async {
    await _firestore.collection(AppConstants.colSpeakingScores).add({
      'id': _uuid.v4(),
      'kidId': kidId,
      'language': language,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'pronunciationScore': result.pronunciationScore,
      'fluencyScore': result.fluencyScore,
      'accuracyScore': result.accuracyScore,
      'overallScore': result.overallScore,
      'level': level,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _tts.stop();
    await _stt.stop();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  double _simpleSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final aWords = a.split(' ').toSet();
    final bWords = b.split(' ').toSet();
    final intersection = aWords.intersection(bWords).length;
    final union = aWords.union(bWords).length;

    return union > 0 ? intersection / union : 0.0;
  }
}

// ─── Result models ────────────────────────────────────────────────────────────

class PronunciationResult {
  final int pronunciationScore;
  final int fluencyScore;
  final int accuracyScore;
  final int overallScore;
  final String feedback;
  final List<CorrectionHint> corrections;

  const PronunciationResult({
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.overallScore,
    required this.feedback,
    required this.corrections,
  });

  String get grade {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    return 'D';
  }

  String get gradeEmoji {
    if (overallScore >= 90) return '🌟';
    if (overallScore >= 80) return '⭐';
    if (overallScore >= 70) return '👍';
    if (overallScore >= 60) return '💪';
    return '🎯';
  }
}

class CorrectionHint {
  final String word;
  final String issue;
  final String tip;

  const CorrectionHint({
    required this.word,
    required this.issue,
    required this.tip,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final aiSpeakingServiceProvider = Provider<AiSpeakingService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiSpeakingService(apiKey: apiKey);
});
