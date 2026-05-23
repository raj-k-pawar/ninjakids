class AppConstants {
  static const appName = 'NinjaKids';
  static const appTagline = 'Learn • Play • Level Up';

  // SharedPreferences Keys
  static const kIsLoggedIn = 'is_logged_in';
  static const kIsParent = 'is_parent';
  static const kThemeMode = 'theme_mode';
  static const kSelectedChild = 'selected_child';
  static const kUserEmail = 'user_email';
  static const kUserId = 'user_id';
  static const kOnboardingDone = 'onboarding_done';

  // Firestore Collections
  static const kUsers = 'users';
  static const kChildren = 'children';
  static const kProgress = 'progress';
  static const kQuizResults = 'quiz_results';
  static const kRewards = 'rewards';

  // XP & Rewards
  static const xpPerCorrectAnswer = 10;
  static const xpPerQuizComplete = 50;
  static const xpPerStreakDay = 25;
  static const coinsPerCorrectAnswer = 2;
  static const coinsPerQuizComplete = 15;

  // Subjects
  static const subjects = [
    'English',
    'Marathi',
    'Mathematics',
    'Science',
    'History',
    'Geography',
    'Logical Reasoning',
    'Coding',
    'General Knowledge',
  ];

  // Grades
  static const grades = [
    'Class 1', 'Class 2', 'Class 3', 'Class 4',
    'Class 5', 'Class 6', 'Class 7', 'Class 8',
    'Class 9', 'Class 10',
  ];

  // Ages
  static const ages = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

  // Difficulty Levels
  static const difficulties = ['Easy', 'Medium', 'Hard'];

  // API
  static const openAiBaseUrl = 'https://api.openai.com/v1';
  static const geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Animation Durations
  static const fastAnimation = Duration(milliseconds: 200);
  static const normalAnimation = Duration(milliseconds: 400);
  static const slowAnimation = Duration(milliseconds: 800);

  // Quiz Settings
  static const quizTimePerQuestion = 30; // seconds
  static const hintsPerQuiz = 3;
}

class SubjectInfo {
  final String name;
  final String emoji;
  final String description;

  const SubjectInfo({required this.name, required this.emoji, required this.description});

  static const List<SubjectInfo> all = [
    SubjectInfo(name: 'Mathematics', emoji: '🔢', description: 'Numbers, algebra & more'),
    SubjectInfo(name: 'English', emoji: '📖', description: 'Grammar, vocab & speaking'),
    SubjectInfo(name: 'Science', emoji: '🔬', description: 'Physics, chemistry & biology'),
    SubjectInfo(name: 'Marathi', emoji: '🗣️', description: 'Marathi language & culture'),
    SubjectInfo(name: 'History', emoji: '🏛️', description: 'World & Indian history'),
    SubjectInfo(name: 'Geography', emoji: '🌍', description: 'Maps, countries & nature'),
    SubjectInfo(name: 'Coding', emoji: '💻', description: 'Programming fundamentals'),
    SubjectInfo(name: 'General Knowledge', emoji: '🌟', description: 'Current affairs & facts'),
    SubjectInfo(name: 'Logical Reasoning', emoji: '🧩', description: 'Puzzles & problem solving'),
  ];
}
