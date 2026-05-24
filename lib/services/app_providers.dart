import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninjakids/shared/models/app_models.dart';
import 'package:ninjakids/core/constants/app_constants.dart';

// ─── Theme Provider ───────────────────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.kThemeMode) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kThemeMode, state);
  }
}

// ─── Auth Provider ────────────────────────────────────────────────────────────
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final bool isParent;
  final ParentUser? parentUser;
  final ChildProfile? activeChild;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isParent = false,
    this.parentUser,
    this.activeChild,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isParent,
    ParentUser? parentUser,
    ChildProfile? activeChild,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isParent: isParent ?? this.isParent,
      parentUser: parentUser ?? this.parentUser,
      activeChild: activeChild ?? this.activeChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.kIsLoggedIn) ?? false;
    final isParent = prefs.getBool(AppConstants.kIsParent) ?? false;
    if (isLoggedIn) {
      state = state.copyWith(isLoggedIn: true, isParent: isParent);
    }
  }

  Future<bool> loginParent(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));
    // Demo login - replace with Firebase
    if (email.isNotEmpty && password.length >= 6) {
      final parent = ParentUser(
        id: 'parent_001',
        name: 'Parent User',
        email: email,
        createdAt: DateTime.now(),
        childIds: ['child_001'],
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.kIsLoggedIn, true);
      await prefs.setBool(AppConstants.kIsParent, true);
      state = state.copyWith(isLoggedIn: true, isParent: true, parentUser: parent, isLoading: false);
      return true;
    }
    state = state.copyWith(isLoading: false, error: 'Invalid credentials');
    return false;
  }

  Future<bool> registerParent(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));
    final parent = ParentUser(
      id: 'parent_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kIsLoggedIn, true);
    await prefs.setBool(AppConstants.kIsParent, true);
    state = state.copyWith(isLoggedIn: true, isParent: true, parentUser: parent, isLoading: false);
    return true;
  }

  void setActiveChild(ChildProfile child) {
    // isLoggedIn must be true — router checks it and redirects to splash if false
    state = state.copyWith(isLoggedIn: true, isParent: false, activeChild: child);
  }

  void switchToParent() {
    state = state.copyWith(isParent: true, activeChild: null);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }
}

// ─── Children Provider ────────────────────────────────────────────────────────
final childrenProvider = StateNotifierProvider<ChildrenNotifier, List<ChildProfile>>((ref) {
  return ChildrenNotifier();
});

class ChildrenNotifier extends StateNotifier<List<ChildProfile>> {
  ChildrenNotifier() : super(_demoChildren);

  static const _demoChildren = [
    ChildProfile(
      id: 'child_001',
      parentId: 'parent_001',
      name: 'Aarav',
      age: 8,
      grade: 'Class 3',
      avatarId: 'ninja1',
      totalXP: 1250,
      coins: 560,
      streakDays: 8,
      level: 6,
      enabledSubjects: AppConstants.subjects,
      pin: '1234',
    ),
    ChildProfile(
      id: 'child_002',
      parentId: 'parent_001',
      name: 'Siya',
      age: 11,
      grade: 'Class 6',
      avatarId: 'ninja3',
      totalXP: 3200,
      coins: 1200,
      streakDays: 15,
      level: 10,
      enabledSubjects: AppConstants.subjects,
      pin: '5678',
    ),
  ];

  void addChild(ChildProfile child) {
    state = [...state, child];
  }

  void updateChild(ChildProfile updated) {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }

  void removeChild(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void updateChildPin(String childId, String newPin) {
    state = state.map((c) {
      if (c.id != childId) return c;
      return ChildProfile(
        id: c.id, parentId: c.parentId, name: c.name, age: c.age,
        grade: c.grade, avatarId: c.avatarId, language: c.language,
        voiceLearningEnabled: c.voiceLearningEnabled, aiTutorEnabled: c.aiTutorEnabled,
        dailyScreenTimeMinutes: c.dailyScreenTimeMinutes,
        enabledSubjects: c.enabledSubjects, totalXP: c.totalXP,
        coins: c.coins, streakDays: c.streakDays, level: c.level, pin: newPin,
      );
    }).toList();
  }

  void addXP(String childId, int xp) {
    state = state.map((c) {
      if (c.id == childId) {
        final newXP = c.totalXP + xp;
        final newLevel = (newXP / 500).floor() + 1;
        return c.copyWith(totalXP: newXP, level: newLevel);
      }
      return c;
    }).toList();
  }

  void addCoins(String childId, int coins) {
    state = state.map((c) {
      if (c.id == childId) return c.copyWith(coins: c.coins + coins);
      return c;
    }).toList();
  }
}

// ─── Quiz Provider ────────────────────────────────────────────────────────────
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final bool isAnswered;
  final int correctCount;
  final int timeLeft;
  final bool isComplete;
  final String subject;
  final String difficulty;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswered = false,
    this.correctCount = 0,
    this.timeLeft = 30,
    this.isComplete = false,
    this.subject = '',
    this.difficulty = 'Easy',
  });

  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length ? questions[currentIndex] : null;

  double get accuracy => questions.isNotEmpty ? (correctCount / questions.length) * 100 : 0;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedAnswer,
    bool? isAnswered,
    int? correctCount,
    int? timeLeft,
    bool? isComplete,
    String? subject,
    String? difficulty,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      correctCount: correctCount ?? this.correctCount,
      timeLeft: timeLeft ?? this.timeLeft,
      isComplete: isComplete ?? this.isComplete,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(const QuizState());

  void loadQuiz(String subject, String difficulty) {
    final questions = _generateQuestions(subject, difficulty);
    state = QuizState(
      questions: questions,
      subject: subject,
      difficulty: difficulty,
      timeLeft: 30,
    );
  }

  void selectAnswer(int index) {
    if (state.isAnswered) return;
    final isCorrect = index == state.currentQuestion?.correctIndex;
    state = state.copyWith(
      selectedAnswer: index,
      isAnswered: true,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
    );
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.questions.length) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedAnswer: null,
        isAnswered: false,
        timeLeft: 30,
      );
    }
  }

  void tickTimer() {
    if (state.timeLeft > 0 && !state.isAnswered) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else if (state.timeLeft == 0 && !state.isAnswered) {
      state = state.copyWith(isAnswered: true, selectedAnswer: -1);
    }
  }

  void reset() {
    state = const QuizState();
  }

  List<QuizQuestion> _generateQuestions(String subject, String difficulty) {
    // Demo questions - replace with AI generation
    final mathQuestions = [
      QuizQuestion(
        id: '1', question: 'Which number comes next in the sequence?\n2, 4, 6, 8, ?',
        options: ['9', '10', '12', '14'], correctIndex: 1,
        explanation: 'The sequence increases by 2 each time. 8 + 2 = 10',
        subject: 'Mathematics', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '2', question: 'What is 7 × 8?',
        options: ['54', '56', '58', '64'], correctIndex: 1,
        explanation: '7 × 8 = 56. Remember: 7 eights are 56!',
        subject: 'Mathematics', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '3', question: 'What is 144 ÷ 12?',
        options: ['10', '11', '12', '13'], correctIndex: 2,
        explanation: '144 ÷ 12 = 12. It\'s a perfect square!',
        subject: 'Mathematics', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '4', question: 'What fraction is shaded if 3 out of 8 parts are shaded?',
        options: ['3/5', '5/8', '3/8', '8/3'], correctIndex: 2,
        explanation: 'Fraction = parts shaded / total parts = 3/8',
        subject: 'Mathematics', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '5', question: 'What is the perimeter of a square with side 9 cm?',
        options: ['18 cm', '27 cm', '36 cm', '81 cm'], correctIndex: 2,
        explanation: 'Perimeter = 4 × side = 4 × 9 = 36 cm',
        subject: 'Mathematics', difficulty: difficulty,
      ),
    ];

    final englishQuestions = [
      QuizQuestion(
        id: '1', question: 'Choose the correct spelling:',
        options: ['Recieve', 'Receive', 'Receve', 'Receeve'], correctIndex: 1,
        explanation: '"Receive" follows the rule: i before e except after c!',
        subject: 'English', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '2', question: 'What is the plural of "child"?',
        options: ['Childs', 'Childes', 'Children', 'Childrens'], correctIndex: 2,
        explanation: '"Children" is the irregular plural of "child".',
        subject: 'English', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '3', question: 'Which word means the opposite of "brave"?',
        options: ['Bold', 'Cowardly', 'Strong', 'Fearless'], correctIndex: 1,
        explanation: 'Cowardly is the antonym (opposite) of brave.',
        subject: 'English', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '4', question: 'Identify the noun: "The quick fox jumped."',
        options: ['Quick', 'Fox', 'Jumped', 'The'], correctIndex: 1,
        explanation: '"Fox" is the noun — it\'s a person, place, or thing.',
        subject: 'English', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '5', question: 'Which sentence is grammatically correct?',
        options: [
          'She go to school.',
          'She goes to school.',
          'She going to school.',
          'She goed to school.',
        ], correctIndex: 1,
        explanation: 'With singular subjects (she/he/it), add "s" to the verb: "goes".',
        subject: 'English', difficulty: difficulty,
      ),
    ];

    final scienceQuestions = [
      QuizQuestion(
        id: '1', question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Jupiter', 'Mars', 'Saturn'], correctIndex: 2,
        explanation: 'Mars is called the Red Planet due to iron oxide (rust) on its surface.',
        subject: 'Science', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '2', question: 'What gas do plants absorb during photosynthesis?',
        options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'], correctIndex: 2,
        explanation: 'Plants absorb CO₂ and release O₂ during photosynthesis.',
        subject: 'Science', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '3', question: 'How many bones are in the adult human body?',
        options: ['106', '206', '306', '406'], correctIndex: 1,
        explanation: 'An adult human body has 206 bones.',
        subject: 'Science', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '4', question: 'What is the powerhouse of the cell?',
        options: ['Nucleus', 'Ribosome', 'Mitochondria', 'Vacuole'], correctIndex: 2,
        explanation: 'Mitochondria produce ATP (energy) for the cell.',
        subject: 'Science', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '5', question: 'What is H₂O?',
        options: ['Hydrogen', 'Oxygen', 'Water', 'Carbon dioxide'], correctIndex: 2,
        explanation: 'H₂O is the chemical formula for water — 2 Hydrogen + 1 Oxygen.',
        subject: 'Science', difficulty: difficulty,
      ),
    ];

    final gkQuestions = [
      QuizQuestion(
        id: '1', question: 'What is the capital of India?',
        options: ['Mumbai', 'Kolkata', 'New Delhi', 'Chennai'], correctIndex: 2,
        explanation: 'New Delhi is the capital and seat of government of India.',
        subject: 'General Knowledge', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '2', question: 'Who wrote the Indian National Anthem?',
        options: ['Mahatma Gandhi', 'Rabindranath Tagore', 'Jawaharlal Nehru', 'Subhas Chandra Bose'], correctIndex: 1,
        explanation: 'Jana Gana Mana was written by Rabindranath Tagore.',
        subject: 'General Knowledge', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '3', question: 'How many states are in India?',
        options: ['25', '26', '28', '29'], correctIndex: 2,
        explanation: 'India currently has 28 states and 8 Union Territories.',
        subject: 'General Knowledge', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '4', question: 'Which is the longest river in India?',
        options: ['Yamuna', 'Ganga', 'Godavari', 'Krishna'], correctIndex: 1,
        explanation: 'The Ganga (Ganges) is the longest river in India at ~2,525 km.',
        subject: 'General Knowledge', difficulty: difficulty,
      ),
      QuizQuestion(
        id: '5', question: 'Which sport is Sachin Tendulkar associated with?',
        options: ['Football', 'Hockey', 'Cricket', 'Tennis'], correctIndex: 2,
        explanation: 'Sachin Tendulkar is the legendary Indian cricketer.',
        subject: 'General Knowledge', difficulty: difficulty,
      ),
    ];

    switch (subject) {
      case 'Mathematics': return mathQuestions;
      case 'English': return englishQuestions;
      case 'Science': return scienceQuestions;
      default: return gkQuestions;
    }
  }
}

// ─── AI Chat Provider ─────────────────────────────────────────────────────────
final aiChatProvider = StateNotifierProvider<AIChatNotifier, List<ChatMessage>>((ref) {
  return AIChatNotifier();
});

class AIChatNotifier extends StateNotifier<List<ChatMessage>> {
  AIChatNotifier() : super([
    ChatMessage(
      id: '0',
      content: 'Hi there! 👋 I\'m Ninja Sensei, your AI tutor! Ask me anything about your subjects. I\'m here to help you learn! 🥷',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];
    _isLoading = true;

    // Simulate AI response - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 1200));
    final response = _generateResponse(text);
    final aiMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [...state, aiMsg];
    _isLoading = false;
  }

  String _generateResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('capital') && q.contains('india')) {
      return 'Great question! 🗺️ The capital of India is **New Delhi**. It\'s located in the northern part of India and is the seat of the Indian government. Did you know New Delhi was designed by British architect Edwin Lutyens?';
    } else if (q.contains('photosynthesis')) {
      return 'Photosynthesis is how plants make their own food! 🌱\n\nThe formula is:\n**CO₂ + H₂O + Sunlight → Glucose + O₂**\n\nPlants absorb sunlight through chlorophyll (which makes them green), take in CO₂ from the air, and water from the soil, then produce sugar for energy and oxygen for us to breathe! 🌿';
    } else if (q.contains('math') || q.contains('multiply') || q.contains('divide')) {
      return 'Math can be fun! 🔢 Let me help you. Can you tell me which specific math topic you\'re working on? For example: multiplication, fractions, geometry, or algebra? I\'ll explain it step by step!';
    } else if (q.contains('hello') || q.contains('hi')) {
      return 'Hello, young ninja! 🥷⚡ Ready to learn something amazing today? You can ask me about any subject — Math, Science, English, History, or anything else. What shall we explore?';
    } else if (q.contains('help')) {
      return 'Of course! I\'m here to help you. 💪 Just ask me:\n• Explain a concept\n• Solve a problem step-by-step\n• Give examples\n• Quiz me on a topic\n\nWhat subject are you studying today?';
    } else {
      return 'That\'s a great question! 🌟 Let me think...\n\nAs a Ninja scholar, I\'d say: keep asking questions — that\'s the first step to mastery! Could you give me more details so I can help you better? For example, which subject is this for? 📚';
    }
  }

  void clearChat() {
    state = [
      ChatMessage(
        id: '0',
        content: 'Chat cleared! Ready for a fresh start! 🥷 What would you like to learn today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

// ─── Subject Progress Provider ─────────────────────────────────────────────────
final subjectProgressProvider = Provider<List<SubjectProgress>>((ref) {
  return [
    const SubjectProgress(subject: 'English', totalLessons: 20, completedLessons: 17, accuracy: 85, xpEarned: 420),
    const SubjectProgress(subject: 'Mathematics', totalLessons: 25, completedLessons: 19, accuracy: 78, xpEarned: 380),
    const SubjectProgress(subject: 'Science', totalLessons: 18, completedLessons: 16, accuracy: 90, xpEarned: 350),
    const SubjectProgress(subject: 'Marathi', totalLessons: 15, completedLessons: 12, accuracy: 80, xpEarned: 280),
    const SubjectProgress(subject: 'History', totalLessons: 12, completedLessons: 8, accuracy: 72, xpEarned: 180),
    const SubjectProgress(subject: 'Geography', totalLessons: 10, completedLessons: 6, accuracy: 68, xpEarned: 140),
    const SubjectProgress(subject: 'Coding', totalLessons: 8, completedLessons: 3, accuracy: 95, xpEarned: 120),
    const SubjectProgress(subject: 'General Knowledge', totalLessons: 30, completedLessons: 22, accuracy: 76, xpEarned: 480),
  ];
});
