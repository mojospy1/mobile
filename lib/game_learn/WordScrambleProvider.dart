import 'dart:math';
import 'package:flutter/material.dart';
import '../model/flashcard.dart'; // Cần import nếu dùng Flashcard

class LetterUnit {
  final String char;
  final String id;

  LetterUnit(this.char) : id = UniqueKey().toString();

  @override
  String toString() => char;

  @override
  bool operator ==(Object other) => other is LetterUnit && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class WordScrambleProvider extends ChangeNotifier {
  final List<Flashcard> flashcards = [];
  int currentIndex = 0;

  late String originalWord;
  late List<LetterUnit> shuffledLetters;
  late List<LetterUnit?> userAnswer;

  bool submitted = false;
  bool isCorrect = false;

  final List<Flashcard> _wrongAnswers = []; // ✅ danh sách câu sai

  int totalCorrect = 0;
  int totalWrong = 0;

  WordScrambleProvider();

  Flashcard get currentCard => flashcards[currentIndex];

  void loadData(List<Flashcard> flashcards) {
    this.flashcards.clear();
    this.flashcards.addAll(flashcards);
    this.flashcards.shuffle();

    currentIndex = 0;
    _initGame(this.flashcards[currentIndex].question);
  }

  void _initGame(String word) {
    originalWord = word;
    shuffledLetters =
        word.split('').map((c) => LetterUnit(c)).toList()..shuffle(Random());
    userAnswer = List.filled(word.length, null);
    submitted = false;
    isCorrect = false;
    notifyListeners();
  }

  void submit() {
    submitted = true;
    final currentAnswer = userAnswer.map((e) => e?.char ?? '').join();
    isCorrect = currentAnswer == originalWord;

    if (isCorrect) {
      totalCorrect++;
    } else {
      totalWrong++;
      _wrongAnswers.add(currentCard); // ✅ lưu câu sai
    }

    notifyListeners();
  }

  bool next() {
    if (currentIndex < flashcards.length - 1) {
      currentIndex++;
      _initGame(flashcards[currentIndex].question);
      return true;
    }
    return false;
  }

  void acceptLetter(LetterUnit letter, int index) {
    if (userAnswer[index] == null) {
      final idx = shuffledLetters.indexOf(letter);
      if (idx != -1) {
        userAnswer[index] = shuffledLetters.removeAt(idx);
        notifyListeners();
      }
    }
  }

  void moveLetterBetweenTargets(LetterUnit letter, int fromIndex, int toIndex) {
    if (userAnswer[fromIndex] == letter && userAnswer[toIndex] == null) {
      userAnswer[toIndex] = letter;
      userAnswer[fromIndex] = null;
      notifyListeners();
    }
  }

  void removeLetterFromAnswer(int index) {
    final letter = userAnswer[index];
    if (letter != null) {
      userAnswer[index] = null;
      shuffledLetters.add(letter);
      shuffledLetters.shuffle(Random());
      notifyListeners();
    }
  }

  void reset() {
    totalCorrect = 0;
    totalWrong = 0;
    _wrongAnswers.clear();
    currentIndex = 0;
    loadData(flashcards);
  }

  void retryWrongQuestions() {
    if (_wrongAnswers.isEmpty) return;

    flashcards
      ..clear()
      ..addAll(_wrongAnswers);
    _wrongAnswers.clear();
    currentIndex = 0;
    totalCorrect = 0;
    totalWrong = 0;
    _initGame(flashcards[currentIndex].question);
    notifyListeners();
  }

  int get wrongCount => _wrongAnswers.length;
  int get correctCount => totalCorrect;
  bool get isLast => currentIndex >= flashcards.length - 1;
}
