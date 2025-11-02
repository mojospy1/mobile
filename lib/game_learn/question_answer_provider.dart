import 'package:flutter/material.dart';
import '../model/flashcard.dart';

class QuestionAnswerProvider extends ChangeNotifier {
  final List<Flashcard> flashcards = [];
  int _currentIndex = 0;
  int _score = 0;
  String _userAnswer = '';
  bool _submitted = false;
  bool _isCorrect = false;
  final List<int> _wrongAnswers = [];

  QuestionAnswerProvider();

  int get currentIndex => _currentIndex;
  int get score => _score;
  String get userAnswer => _userAnswer;
  bool get submitted => _submitted;
  bool get isCorrect => _isCorrect;
  List<Flashcard> get cards => flashcards;
  List<int> get wrongAnswers => _wrongAnswers;

  Flashcard get currentCard => flashcards[_currentIndex];

  void loadData(List<Flashcard> flashcards) {
    this.flashcards.clear();
    this.flashcards.addAll(flashcards);
    _currentIndex = 0;
  }

  void updateAnswer(String value) {
    _userAnswer = value;
    notifyListeners();
  }

  void checkAnswer() {
    _submitted = true;
    _isCorrect =
        _userAnswer.trim().toLowerCase() ==
        currentCard.answer.trim().toLowerCase();

    if (_isCorrect) {
      _score++;
    } else {
      _wrongAnswers.add(_currentIndex);
    }

    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentIndex < flashcards.length - 1) {
      _currentIndex++;
      _submitted = false;
      _isCorrect = false;
      _userAnswer = '';
      notifyListeners();
      return true;
    }
    return false;
  }

  void retryWrongQuestions() {
    if (_wrongAnswers.isNotEmpty) {
      _currentIndex = _wrongAnswers.first;
      _submitted = false;
      _isCorrect = false;
      _userAnswer = '';
      notifyListeners();
    }
  }

  void reset() {
    _currentIndex = 0;
    _score = 0;
    _userAnswer = '';
    _submitted = false;
    _isCorrect = false;
    _wrongAnswers.clear();
    notifyListeners();
  }
}
