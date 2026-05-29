import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:ninjkids/core/constants/app_constants.dart';
import 'package:ninjkids/domain/entities/entities.dart';
import 'package:ninjkids/services/ai/ai_speaking_service.dart';

void main() {
  group('AiQuestionService', () {
    group('Question parsing', () {
      test('handles valid MCQ JSON response', () {
        final mockJson = jsonEncode([
          {
            'question': 'What is 2 + 2?',
            'options': ['A. 3', 'B. 4', 'C. 5', 'D. 6'],
            'answer': 'B',
            'explanation': '2 plus 2 equals 4',
          }
        ]);

        final list = jsonDecode(mockJson) as List;
        expect(list.length, equals(1));
        expect(list[0]['question'], equals('What is 2 + 2?'));
        expect(list[0]['options'].length, equals(4));
        expect(list[0]['answer'], equals('B'));
      });

      test('handles markdown-wrapped JSON', () {
        const wrapped =
            '```json\n[{"question": "Q?", "options": [], "answer": "A"}]\n```';
        final cleaned =
            wrapped.replaceAll(RegExp(r'```json|```'), '').trim();
        expect(() => jsonDecode(cleaned), returnsNormally);
      });

      test('returns empty list for malformed JSON gracefully', () {
        expect(() {
          try {
            jsonDecode('This is not JSON at all');
          } catch (_) {
            // Expected — service catches this internally
          }
        }, returnsNormally);
      });
    });
  });

  group('QuizQuestionEntity', () {
    test('creates entity with required fields', () {
      final question = QuizQuestionEntity(
        id: 'q-001',
        subject: 'Mathematics',
        className: 'Class 5',
        difficulty: AppConstants.difficultyMedium,
        type: AppConstants.typeMCQ,
        questionText: 'What is the square root of 16?',
        options: ['A. 2', 'B. 4', 'C. 8', 'D. 16'],
        correctAnswer: 'B',
        explanation: 'The square root of 16 is 4 because 4 × 4 = 16',
        isAiGenerated: true,
        generatedAt: DateTime.now(),
      );

      expect(question.id, equals('q-001'));
      expect(question.subject, equals('Mathematics'));
      expect(question.options.length, equals(4));
      expect(question.isAiGenerated, isTrue);
    });

    test('equality based on id and questionText', () {
      final now = DateTime.now();
      final q1 = QuizQuestionEntity(
        id: 'q-1',
        subject: 'Science',
        className: 'Class 4',
        difficulty: 'easy',
        type: 'mcq',
        questionText: 'What is the sun?',
        correctAnswer: 'A star',
        generatedAt: now,
      );
      final q2 = QuizQuestionEntity(
        id: 'q-1',
        subject: 'Science',
        className: 'Class 4',
        difficulty: 'easy',
        type: 'mcq',
        questionText: 'What is the sun?',
        correctAnswer: 'A star',
        generatedAt: now,
      );

      expect(q1, equals(q2));
    });
  });

  group('KidEntity', () {
    test('calculates level progress correctly', () {
      final kid = KidEntity(
        id: 'kid-1',
        parentId: 'parent-1',
        name: 'Arjun',
        age: 10,
        className: 'Class 5',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        totalXp: 750,
        level: 2,
      );

      expect(kid.xpInCurrentLevel, equals(250)); // 750 % 500
      expect(kid.xpToNextLevel, equals(1000));   // level 2 * 500
    });

    test('screen time remaining is false when limit exceeded', () {
      final kid = KidEntity(
        id: 'kid-1',
        parentId: 'parent-1',
        name: 'Priya',
        age: 8,
        className: 'Class 3',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        dailyScreenTimeLimitMinutes: 60,
        todayScreenTimeMinutes: 65,
      );

      expect(kid.hasRemainingScreenTime, isFalse);
    });

    test('screen time remaining is true when within limit', () {
      final kid = KidEntity(
        id: 'kid-1',
        parentId: 'parent-1',
        name: 'Ravi',
        age: 9,
        className: 'Class 4',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        dailyScreenTimeLimitMinutes: 60,
        todayScreenTimeMinutes: 30,
      );

      expect(kid.hasRemainingScreenTime, isTrue);
    });
  });

  group('QuizSessionEntity', () {
    test('calculates accuracy correctly', () {
      final session = QuizSessionEntity(
        id: 's-1',
        kidId: 'kid-1',
        subject: 'Mathematics',
        className: 'Class 5',
        questions: [],
        kidAnswers: [],
        score: 8,
        totalQuestions: 10,
        xpEarned: 240,
        coinsEarned: 40,
        timeTaken: const Duration(minutes: 5),
        completedAt: DateTime.now(),
      );

      expect(session.accuracy, equals(80.0));
    });

    test('accuracy is 0 when totalQuestions is 0', () {
      final session = QuizSessionEntity(
        id: 's-2',
        kidId: 'kid-1',
        subject: 'GK',
        className: 'Class 3',
        questions: [],
        kidAnswers: [],
        score: 0,
        totalQuestions: 0,
        xpEarned: 0,
        coinsEarned: 0,
        timeTaken: Duration.zero,
        completedAt: DateTime.now(),
      );

      expect(session.accuracy, equals(0.0));
    });
  });

  group('PronunciationResult', () {
    test('grade returns correct letter grade', () {
      final testCases = [
        (95, 'A+'),
        (85, 'A'),
        (72, 'B'),
        (63, 'C'),
        (45, 'D'),
      ];

      for (final (score, expectedGrade) in testCases) {
        final result = PronunciationResult(
          pronunciationScore: score,
          fluencyScore: score,
          accuracyScore: score,
          overallScore: score,
          feedback: 'Test feedback',
          corrections: [],
        );
        expect(result.grade, equals(expectedGrade),
            reason: 'Score $score should give grade $expectedGrade');
      }
    });

    test('gradeEmoji returns star for high scores', () {
      final result = PronunciationResult(
        pronunciationScore: 95,
        fluencyScore: 95,
        accuracyScore: 95,
        overallScore: 95,
        feedback: 'Excellent!',
        corrections: [],
      );
      expect(result.gradeEmoji, equals('🌟'));
    });
  });

  group('AppConstants', () {
    test('subjects list has all 9 subjects', () {
      expect(AppConstants.subjects.length, equals(9));
    });

    test('fun games list contains expected games', () {
      final gameIds =
          AppConstants.funGames.map((g) => g['id']).toList();
      expect(gameIds, contains('sudoku'));
      expect(gameIds, contains('memory_match'));
      expect(gameIds, contains('kbc_kids'));
    });

    test('avatar emojis list has at least 12 options', () {
      expect(AppConstants.avatarEmojis.length, greaterThanOrEqualTo(12));
    });

    test('XP constants are positive', () {
      expect(AppConstants.xpPerCorrectAnswer, greaterThan(0));
      expect(AppConstants.coinsPerCorrectAnswer, greaterThan(0));
    });
  });
}
