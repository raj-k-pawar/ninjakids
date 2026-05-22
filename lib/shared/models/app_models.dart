// User Models
class ParentUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final bool isPremium;
  final DateTime createdAt;
  final List<String> childIds;

  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.isPremium = false,
    required this.createdAt,
    this.childIds = const [],
  });

  factory ParentUser.fromMap(Map<String, dynamic> map) {
    return ParentUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      isPremium: map['isPremium'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      childIds: List<String>.from(map['childIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'childIds': childIds,
    };
  }
}

class ChildProfile {
  final String id;
  final String parentId;
  final String name;
  final int age;
  final String grade;
  final String avatarId;
  final String language;
  final bool voiceLearningEnabled;
  final bool aiTutorEnabled;
  final int dailyScreenTimeMinutes;
  final List<String> enabledSubjects;
  final int totalXP;
  final int coins;
  final int streakDays;
  final int level;
  final String pin;

  const ChildProfile({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.grade,
    required this.avatarId,
    this.language = 'English',
    this.voiceLearningEnabled = true,
    this.aiTutorEnabled = true,
    this.dailyScreenTimeMinutes = 90,
    this.enabledSubjects = const [],
    this.totalXP = 0,
    this.coins = 0,
    this.streakDays = 0,
    this.level = 1,
    this.pin = '0000',
  });

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] ?? '',
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 8,
      grade: map['grade'] ?? 'Class 3',
      avatarId: map['avatarId'] ?? 'ninja1',
      language: map['language'] ?? 'English',
      voiceLearningEnabled: map['voiceLearningEnabled'] ?? true,
      aiTutorEnabled: map['aiTutorEnabled'] ?? true,
      dailyScreenTimeMinutes: map['dailyScreenTimeMinutes'] ?? 90,
      enabledSubjects: List<String>.from(map['enabledSubjects'] ?? []),
      totalXP: map['totalXP'] ?? 0,
      coins: map['coins'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      level: map['level'] ?? 1,
      pin: map['pin'] ?? '0000',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'age': age,
      'grade': grade,
      'avatarId': avatarId,
      'language': language,
      'voiceLearningEnabled': voiceLearningEnabled,
      'aiTutorEnabled': aiTutorEnabled,
      'dailyScreenTimeMinutes': dailyScreenTimeMinutes,
      'enabledSubjects': enabledSubjects,
      'totalXP': totalXP,
      'coins': coins,
      'streakDays': streakDays,
      'level': level,
      'pin': pin,
    };
  }

  ChildProfile copyWith({
    int? totalXP,
    int? coins,
    int? streakDays,
    int? level,
    List<String>? enabledSubjects,
    bool? voiceLearningEnabled,
    bool? aiTutorEnabled,
    int? dailyScreenTimeMinutes,
  }) {
    return ChildProfile(
      id: id,
      parentId: parentId,
      name: name,
      age: age,
      grade: grade,
      avatarId: avatarId,
      language: language,
      voiceLearningEnabled: voiceLearningEnabled ?? this.voiceLearningEnabled,
      aiTutorEnabled: aiTutorEnabled ?? this.aiTutorEnabled,
      dailyScreenTimeMinutes: dailyScreenTimeMinutes ?? this.dailyScreenTimeMinutes,
      enabledSubjects: enabledSubjects ?? this.enabledSubjects,
      totalXP: totalXP ?? this.totalXP,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      pin: pin,
    );
  }
}

// Quiz Models
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String subject;
  final String difficulty;
  final String? imageUrl;
  final QuestionType type;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.subject,
    required this.difficulty,
    this.imageUrl,
    this.type = QuestionType.mcq,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      subject: map['subject'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      imageUrl: map['imageUrl'],
      type: QuestionType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'mcq'),
        orElse: () => QuestionType.mcq,
      ),
    );
  }
}

enum QuestionType { mcq, fillBlanks, matchPairs, imageAnswer, voiceAnswer }

class QuizResult {
  final String childId;
  final String subject;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final int coinsEarned;
  final DateTime completedAt;
  final int timeTakenSeconds;

  const QuizResult({
    required this.childId,
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.coinsEarned,
    required this.completedAt,
    required this.timeTakenSeconds,
  });

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}

// Badge/Achievement Model
class AppBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int coinsReward;
  final BadgeType type;
  final bool isUnlocked;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.coinsReward = 50,
    required this.type,
    this.isUnlocked = false,
  });

  static List<AppBadge> get allBadges => [
    const AppBadge(id: 'first_quiz', name: 'First Strike', description: 'Complete your first quiz', emoji: '⚡', type: BadgeType.achievement),
    const AppBadge(id: 'streak_3', name: '3-Day Ninja', description: '3-day learning streak', emoji: '🔥', coinsReward: 100, type: BadgeType.streak),
    const AppBadge(id: 'streak_7', name: 'Week Warrior', description: '7-day learning streak', emoji: '⚔️', coinsReward: 250, type: BadgeType.streak),
    const AppBadge(id: 'math_master', name: 'Math Master', description: 'Score 100% in Math quiz', emoji: '🔢', coinsReward: 150, type: BadgeType.subject),
    const AppBadge(id: 'english_pro', name: 'English Pro', description: 'Complete 10 English lessons', emoji: '📖', coinsReward: 150, type: BadgeType.subject),
    const AppBadge(id: 'quiz_100', name: 'Century Club', description: 'Complete 100 quizzes', emoji: '💯', coinsReward: 500, type: BadgeType.milestone),
    const AppBadge(id: 'speed_demon', name: 'Speed Demon', description: 'Answer in under 5 seconds', emoji: '💨', coinsReward: 100, type: BadgeType.achievement),
    const AppBadge(id: 'perfect_score', name: 'Perfect Ninja', description: 'Get perfect score in a quiz', emoji: '🥷', coinsReward: 200, type: BadgeType.achievement),
  ];
}

enum BadgeType { achievement, streak, subject, milestone }

// Chat Message Model
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
  });
}

// Subject Progress Model
class SubjectProgress {
  final String subject;
  final int totalLessons;
  final int completedLessons;
  final double accuracy;
  final int xpEarned;

  const SubjectProgress({
    required this.subject,
    required this.totalLessons,
    required this.completedLessons,
    required this.accuracy,
    required this.xpEarned,
  });

  double get progressPercent => totalLessons > 0 ? completedLessons / totalLessons : 0;
}

// Avatar Model
class AvatarOption {
  final String id;
  final String emoji;
  final String name;
  final bool isPremium;

  const AvatarOption({
    required this.id,
    required this.emoji,
    required this.name,
    this.isPremium = false,
  });

  static const List<AvatarOption> all = [
    AvatarOption(id: 'ninja1', emoji: '🥷', name: 'Black Ninja'),
    AvatarOption(id: 'ninja2', emoji: '⚔️', name: 'Sword Ninja'),
    AvatarOption(id: 'ninja3', emoji: '🌟', name: 'Star Ninja'),
    AvatarOption(id: 'ninja4', emoji: '🦊', name: 'Fox Ninja'),
    AvatarOption(id: 'ninja5', emoji: '🐲', name: 'Dragon Ninja', isPremium: true),
    AvatarOption(id: 'ninja6', emoji: '⚡', name: 'Thunder Ninja', isPremium: true),
    AvatarOption(id: 'ninja7', emoji: '🔥', name: 'Fire Ninja', isPremium: true),
    AvatarOption(id: 'ninja8', emoji: '💎', name: 'Diamond Ninja', isPremium: true),
  ];
}

// Game Model
class GameInfo {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final String emoji;
  final int xpReward;
  final GameType type;

  const GameInfo({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.emoji,
    required this.xpReward,
    required this.type,
  });
}

enum GameType { quiz, puzzle, matching, dragDrop, story, voice }
