/// Central constants for the NinjaKids app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'NinjaKids';
  static const String appTagline = 'Learn Smart. Play Smart.';
  static const String appVersion = '1.0.0';

  // OpenAI
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiModel = 'gpt-4o-mini';
  static const int maxTokens = 800;

  // Firebase Collections
  static const String colUsers = 'users';
  static const String colParents = 'parents';
  static const String colKids = 'kids';
  static const String colQuizHistory = 'quiz_history';
  static const String colAiQuestions = 'ai_questions';
  static const String colSpeakingScores = 'speaking_scores';
  static const String colAchievements = 'achievements';
  static const String colSubscriptions = 'subscriptions';
  static const String colScreenTimeLogs = 'screen_time_logs';
  static const String colGames = 'games';

  // Subjects
  static const List<String> subjects = [
    'English', 'Marathi', 'Science', 'History',
    'Geography', 'GK', 'Mathematics', 'Coding Basics', 'Logical Reasoning',
  ];

  // Classes / Standards
  static const List<String> classes = [
    'Nursery', 'KG', 'Class 1', 'Class 2', 'Class 3',
    'Class 4', 'Class 5', 'Class 6', 'Class 7',
    'Class 8', 'Class 9', 'Class 10',
  ];

  // Difficulty Levels
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';

  // Question Types
  static const String typeMCQ = 'mcq';
  static const String typeTrueFalse = 'true_false';
  static const String typeFillBlank = 'fill_blank';
  static const String typeMatchFollowing = 'match_following';
  static const String typeVoice = 'voice';

  // Gamification
  static const int xpPerCorrectAnswer = 30;
  static const int xpPerWrongAnswer = 0;
  static const int xpPerStreakBonus = 50;
  static const int coinsPerCorrectAnswer = 5;
  static const int coinsPerLevelUp = 100;

  // Screen Time (minutes)
  static const int defaultDailyScreenTimeMinutes = 60;
  static const int maxDailyScreenTimeMinutes = 240;

  // Shared Prefs Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefCurrentUserId = 'current_user_id';
  static const String prefUserRole = 'user_role';

  // User Roles
  static const String roleParent = 'parent';
  static const String roleKid = 'kid';

  // Fun Games
  static const List<Map<String, dynamic>> funGames = [
    {'id': 'sudoku', 'name': 'Sudoku', 'emoji': '🧩', 'minAge': 8},
    {'id': 'memory_match', 'name': 'Memory Match', 'emoji': '🃏', 'minAge': 5},
    {'id': 'kbc_kids', 'name': 'KBC for Kids', 'emoji': '📺', 'minAge': 6},
    {'id': 'word_puzzle', 'name': 'Word Puzzle', 'emoji': '🔤', 'minAge': 6},
    {'id': 'math_puzzle', 'name': 'Math Puzzle', 'emoji': '🔢', 'minAge': 7},
    {'id': 'typing_speed', 'name': 'Typing Speed', 'emoji': '⌨️', 'minAge': 9},
    {'id': 'brain_challenge', 'name': 'Brain Challenge', 'emoji': '🧠', 'minAge': 8},
    {'id': 'color_match', 'name': 'Color Match', 'emoji': '🎨', 'minAge': 5},
    {'id': 'quiz_battle', 'name': 'Quiz Battle', 'emoji': '⚔️', 'minAge': 7},
    {'id': 'zigzag', 'name': 'ZigZag', 'emoji': '⚡', 'minAge': 6},
  ];

  // Avatar options
  static const List<String> avatarEmojis = [
    '🦊', '🐱', '🐻', '🐼', '🦁', '🐯',
    '🦄', '🐸', '🐧', '🦋', '🦖', '🤖',
  ];
}
