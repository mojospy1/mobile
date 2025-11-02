import 'package:flutter/material.dart';
import 'package:apphoctienganh/model/flashcard.dart';

class QuizProvider with ChangeNotifier {
  final List<Flashcard> _flashcard = [];
  void load(List<Flashcard> flashcards) {
    _flashcard.clear();
    _flashcard.addAll(flashcards);
  }
  int _currentIndex = 0;
  int _incorrectAnswers = 0;

  int get currentIndex => _currentIndex;
  int get incorrectAnswers => _incorrectAnswers;
  
  Flashcard get currentflashcard => _flashcard[_currentIndex];
  
  List<Flashcard> get allflashcard => _flashcard;
  bool get isLastQuestion => _currentIndex >= _flashcard.length - 1;

  bool isCorrect(String selectedAnswer) {
    final isRight = selectedAnswer == currentflashcard.answer;
    if (!isRight) {
      _incorrectAnswers++;
    }
    return isRight;
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
