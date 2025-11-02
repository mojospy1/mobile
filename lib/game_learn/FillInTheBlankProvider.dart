import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';

class FillInTheBlank {
  final String id;
  final String word; // Từ cần điền vào

  FillInTheBlank({required this.id, required this.word});
}

class FillInTheBlankProvider with ChangeNotifier {
  final List<FillInTheBlank> _questions = [];

  int _currentIndex = 0;
  int _incorrectAnswers = 0;

  int get currentIndex => _currentIndex;
  int get incorrectAnswers => _incorrectAnswers;

  List<FillInTheBlank> get allQuestions => _questions;
  FillInTheBlank get currentQuestion => _questions[_currentIndex];

  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  bool isCorrect(String input) {
    final correct =
        input.trim().toLowerCase() == currentQuestion.word.toLowerCase();
    if (!correct) _incorrectAnswers++;
    return correct;
  }

  void loadData(List<Flashcard> flashcards) {
    _questions.clear();
    _questions.addAll(
      flashcards.map(
        (flashcard) => FillInTheBlank(
          id: flashcard.id,
          word:
              flashcard
                  .question, // Hoặc flashcard.answer nếu ông chủ muốn điền đáp án
        ),
      ),
    );
    _currentIndex = 0;
    _incorrectAnswers = 0;
    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentIndex = 0;
    _incorrectAnswers = 0;
    notifyListeners();
  }
}
