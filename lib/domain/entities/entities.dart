import 'package:equatable/equatable.dart';

// ─── Parent Entity ────────────────────────────────────────────────────────────

class ParentEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> kidIds;
  final String subscriptionPlan; // 'free' | 'premium' | 'family'
  final DateTime createdAt;
  final bool isActive;

  const ParentEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.kidIds = const [],
    this.subscriptionPlan = 'free',
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, email];
}

// ─── Kid Entity ───────────────────────────────────────────────────────────────

class KidEntity extends Equatable {
  final String id;
  final String parentId;
  final String name;
  final String avatarEmoji;
  final int age;
  final String className; // e.g. 'Class 5'
  final List<String> allowedSubjects;
  final List<String> allowedGames;
  final int dailyScreenTimeLimitMinutes;
  final int todayScreenTimeMinutes;
  final bool isGamesLocked;
  final int totalXp;
  final int level;
  final int coins;
  final int currentStreak;
  final int longestStreak;
  final String pin; // 4-digit kid PIN
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const KidEntity({
    required this.id,
    required this.parentId,
    required this.name,
    this.avatarEmoji = '🦊',
    required this.age,
    required this.className,
    this.allowedSubjects = const [],
    this.allowedGames = const [],
    this.dailyScreenTimeLimitMinutes = 60,
    this.todayScreenTimeMinutes = 0,
    this.isGamesLocked = false,
    this.totalXp = 0,
    this.level = 1,
    this.coins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.pin = '0000',
    required this.createdAt,
    required this.lastActiveAt,
  });

  int get xpToNextLevel => (level * 500);
  int get xpInCurrentLevel => totalXp % 500;
  double get levelProgress => xpInCurrentLevel / xpToNextLevel;

  bool get hasRemainingScreenTime =>
      todayScreenTimeMinutes < dailyScreenTimeLimitMinutes;

  @override
  List<Object?> get props => [id, parentId, name];
}

// ─── Quiz Question Entity ─────────────────────────────────────────────────────

class QuizQuestionEntity extends Equatable {
  final String id;
  final String subject;
  final String className;
  final String difficulty; // easy | medium | hard
  final String type; // mcq | true_false | fill_blank | voice
  final String questionText;
  final List<String> options; // For MCQ; empty for others
  final String correctAnswer;
  final String? explanation;
  final bool isAiGenerated;
  final DateTime generatedAt;

  const QuizQuestionEntity({
    required this.id,
    required this.subject,
    required this.className,
    required this.difficulty,
    required this.type,
    required this.questionText,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.isAiGenerated = true,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [id, questionText];
}

// ─── Quiz Session Entity ──────────────────────────────────────────────────────

class QuizSessionEntity extends Equatable {
  final String id;
  final String kidId;
  final String subject;
  final String className;
  final List<QuizQuestionEntity> questions;
  final List<String> kidAnswers;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int coinsEarned;
  final Duration timeTaken;
  final DateTime completedAt;

  const QuizSessionEntity({
    required this.id,
    required this.kidId,
    required this.subject,
    required this.className,
    required this.questions,
    required this.kidAnswers,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.coinsEarned,
    required this.timeTaken,
    required this.completedAt,
  });

  double get accuracy =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  @override
  List<Object?> get props => [id, kidId, completedAt];
}

// ─── Achievement Entity ───────────────────────────────────────────────────────

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final int requiredCount;
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;
  final int coinReward;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.requiredCount,
    this.currentCount = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 0,
    this.coinReward = 0,
  });

  double get progress =>
      requiredCount > 0 ? (currentCount / requiredCount).clamp(0.0, 1.0) : 0;

  @override
  List<Object?> get props => [id];
}

enum AchievementType {
  quiz,
  streak,
  subject,
  game,
  speaking,
  social,
}

// ─── Speaking Score Entity ────────────────────────────────────────────────────

class SpeakingScoreEntity extends Equatable {
  final String id;
  final String kidId;
  final String language; // 'english' | 'marathi'
  final String lessonId;
  final String lessonTitle;
  final int pronunciationScore; // 0-100
  final int fluencyScore; // 0-100
  final int accuracyScore; // 0-100
  final int overallScore; // 0-100
  final String level; // beginner | intermediate | advanced
  final DateTime completedAt;

  const SpeakingScoreEntity({
    required this.id,
    required this.kidId,
    required this.language,
    required this.lessonId,
    required this.lessonTitle,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.overallScore,
    required this.level,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [id, kidId, lessonId];
}

// ─── Screen Time Log Entity ───────────────────────────────────────────────────

class ScreenTimeLogEntity extends Equatable {
  final String id;
  final String kidId;
  final DateTime date;
  final int totalMinutes;
  final Map<String, int> breakdownBySection; // e.g. {'quiz': 20, 'games': 15}

  const ScreenTimeLogEntity({
    required this.id,
    required this.kidId,
    required this.date,
    required this.totalMinutes,
    this.breakdownBySection = const {},
  });

  @override
  List<Object?> get props => [id, kidId, date];
}
