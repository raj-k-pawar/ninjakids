import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

/// Manages all AI-powered question generation using OpenAI GPT-4o-mini.
/// Includes duplicate prevention via question hash caching in Firestore.
class AiQuestionService {
  final String _apiKey;
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  AiQuestionService({
    required String apiKey,
    FirebaseFirestore? firestore,
  })  : _apiKey = apiKey,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Generate a batch of quiz questions ──────────────────────────────────

  Future<List<QuizQuestionEntity>> generateQuestions({
    required String subject,
    required String className,
    required String difficulty,
    required String questionType,
    required int count,
    required String kidId,
  }) async {
    // Fetch previously asked question hashes to prevent repeats
    final usedHashes = await _getUsedQuestionHashes(
      kidId: kidId,
      subject: subject,
    );

    final prompt = _buildQuestionPrompt(
      subject: subject,
      className: className,
      difficulty: difficulty,
      questionType: questionType,
      count: count + 2, // Generate extras to compensate for possible duplicates
      usedHashes: usedHashes,
    );

    final rawQuestions = await _callOpenAI(prompt);
    final questions = _parseQuestions(
      rawQuestions,
      subject: subject,
      className: className,
      difficulty: difficulty,
      questionType: questionType,
    );

    // Filter out any duplicates
    final unique = _deduplicateQuestions(questions, usedHashes);

    // Cache the hashes of the new questions
    await _cacheQuestionHashes(
      kidId: kidId,
      subject: subject,
      questions: unique.take(count).toList(),
    );

    return unique.take(count).toList();
  }

  // ─── Generate AI speaking lesson ─────────────────────────────────────────

  Future<Map<String, dynamic>> generateSpeakingLesson({
    required String language,
    required String level,
    required String kidName,
    required int kidAge,
  }) async {
    final prompt = '''
You are a child-friendly language teacher. Generate a speaking lesson for:
- Language: $language
- Level: $level (beginner/intermediate/advanced)
- Student name: $kidName, Age: $kidAge years

Return JSON ONLY with this structure:
{
  "title": "lesson title",
  "topic": "lesson topic",
  "words": ["word1", "word2", "word3", "word4", "word5"],
  "sentences": [
    {"text": "sentence to repeat", "phonetic": "pho-ne-tic help"},
    {"text": "sentence 2", "phonetic": "pho-ne-tic help"}
  ],
  "conversation": [
    {"role": "ai", "text": "Hello! How are you?"},
    {"role": "kid", "expected": "I am fine, thank you!"}
  ],
  "tip": "One pronunciation tip"
}
''';

    final response = await _callOpenAI(prompt, isJson: true);
    return jsonDecode(response) as Map<String, dynamic>;
  }

  // ─── Generate AI performance insight ─────────────────────────────────────

  Future<String> generatePerformanceInsight({
    required String kidName,
    required Map<String, double> subjectScores,
    required int streak,
    required String className,
  }) async {
    final scoresText = subjectScores.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}%')
        .join(', ');

    final prompt = '''
You are a friendly educational coach. Write a short, encouraging performance insight for a parent 
about their child $kidName ($className). 

Performance data:
- Subject scores: $scoresText
- Current streak: $streak days

Write 2-3 sentences. Be positive, specific, and actionable. 
Mention the strongest subject and one area to improve.
Keep it warm and child-friendly.
''';

    return await _callOpenAI(prompt);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  String _buildQuestionPrompt({
    required String subject,
    required String className,
    required String difficulty,
    required String questionType,
    required int count,
    required Set<String> usedHashes,
  }) {
    final typeInstructions = switch (questionType) {
      AppConstants.typeMCQ => '''
Generate $count MCQ questions. Each must have exactly 4 options (A, B, C, D).
Return JSON array:
[{
  "question": "...",
  "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
  "answer": "B",
  "explanation": "brief explanation"
}]''',
      AppConstants.typeTrueFalse => '''
Generate $count True/False questions.
Return JSON array:
[{
  "question": "...",
  "options": ["True", "False"],
  "answer": "True",
  "explanation": "brief explanation"
}]''',
      AppConstants.typeFillBlank => '''
Generate $count fill-in-the-blank questions. Use ___ for the blank.
Return JSON array:
[{
  "question": "The capital of India is ___.",
  "options": [],
  "answer": "New Delhi",
  "explanation": "brief explanation"
}]''',
      _ => '''
Generate $count MCQ questions.
Return JSON array with question, options, answer, explanation.'''
    };

    return '''
You are an expert educational content creator for Indian school children.
Subject: $subject
Class: $className  
Difficulty: $difficulty
Age-appropriate, curriculum-aligned, engaging questions.

$typeInstructions

Rules:
- Questions MUST be unique and different from each other
- Match the exact curriculum level for $className
- Use simple, clear language children understand
- Make questions educational and interesting
- Return ONLY the JSON array, no other text
''';
  }

  Future<String> _callOpenAI(String prompt, {bool isJson = false}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.openAiModel,
        'max_tokens': AppConstants.maxTokens,
        'temperature': 0.8,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an expert educational content generator for Indian school kids. '
                    'Always return valid JSON when asked. Be creative and educational.'
          },
          {'role': 'user', 'content': prompt},
        ],
        if (isJson) 'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  List<QuizQuestionEntity> _parseQuestions(
    String rawJson, {
    required String subject,
    required String className,
    required String difficulty,
    required String questionType,
  }) {
    try {
      // Strip markdown code fences if present
      var cleaned = rawJson.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'```json|```'), '').trim();
      }

      final list = jsonDecode(cleaned) as List;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return QuizQuestionEntity(
          id: _uuid.v4(),
          subject: subject,
          className: className,
          difficulty: difficulty,
          type: questionType,
          questionText: map['question'] as String,
          options: (map['options'] as List?)?.cast<String>() ?? [],
          correctAnswer: map['answer'] as String,
          explanation: map['explanation'] as String?,
          isAiGenerated: true,
          generatedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<QuizQuestionEntity> _deduplicateQuestions(
    List<QuizQuestionEntity> questions,
    Set<String> usedHashes,
  ) {
    final seen = <String>{};
    return questions.where((q) {
      final hash = _questionHash(q.questionText);
      if (usedHashes.contains(hash) || seen.contains(hash)) return false;
      seen.add(hash);
      return true;
    }).toList();
  }

  String _questionHash(String text) {
    // Simple hash: lowercase, remove punctuation, take first 60 chars
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim()
        .substring(0, text.length.clamp(0, 60));
  }

  Future<Set<String>> _getUsedQuestionHashes({
    required String kidId,
    required String subject,
  }) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.colAiQuestions)
          .doc('${kidId}_${subject.toLowerCase()}')
          .get();

      if (!doc.exists) return {};
      final data = doc.data()!;
      final hashes = data['hashes'] as List? ?? [];
      return Set<String>.from(hashes.cast<String>());
    } catch (_) {
      return {};
    }
  }

  Future<void> _cacheQuestionHashes({
    required String kidId,
    required String subject,
    required List<QuizQuestionEntity> questions,
  }) async {
    if (questions.isEmpty) return;
    try {
      final newHashes = questions.map((q) => _questionHash(q.questionText)).toList();
      final docRef = _firestore
          .collection(AppConstants.colAiQuestions)
          .doc('${kidId}_${subject.toLowerCase()}');

      await docRef.set({
        'hashes': FieldValue.arrayUnion(newHashes),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-fatal — question history not saved this time
    }
  }
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────

final aiQuestionServiceProvider = Provider<AiQuestionService>((ref) {
  // In production, load from flutter_secure_storage or env config
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiQuestionService(apiKey: apiKey);
});
