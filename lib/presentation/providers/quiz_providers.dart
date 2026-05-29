import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';

// Active quiz session state
class QuizSessionState {
  final List<QuizQuestionEntity> questions;
  final int currentIndex;
  final List<String?> answers;
  final bool isFinished;

  const QuizSessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.isFinished = false,
  });

  int get score {
    int s = 0;
    for (int i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) s++;
    }
    return s;
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  QuizSessionNotifier() : super(const QuizSessionState());

  void setQuestions(List<QuizQuestionEntity> questions) {
    state = QuizSessionState(
      questions: questions,
      answers: List.filled(questions.length, null),
    );
  }

  void submitAnswer(String answer) {
    if (state.currentIndex >= state.questions.length) return;
    final newAnswers = List<String?>.from(state.answers);
    newAnswers[state.currentIndex] = answer;
    state = QuizSessionState(
      questions: state.questions,
      currentIndex: state.currentIndex,
      answers: newAnswers,
    );
  }

  void nextQuestion() {
    final next = state.currentIndex + 1;
    if (next >= state.questions.length) {
      state = QuizSessionState(
        questions: state.questions,
        currentIndex: state.currentIndex,
        answers: state.answers,
        isFinished: true,
      );
    } else {
      state = QuizSessionState(
        questions: state.questions,
        currentIndex: next,
        answers: state.answers,
      );
    }
  }

  void reset() {
    state = const QuizSessionState();
  }
}

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSessionState>(
  (ref) => QuizSessionNotifier(),
);
