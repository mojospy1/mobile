import 'dart:math';
import 'package:flutter/material.dart';
import 'package:apphoctienganh/model/flashcard.dart';

class WordGuessProvider extends ChangeNotifier {
  final List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _submitted = false;
  bool _isCorrect = false;
  String _userInput = '';
  late int _hiddenCharIndex;

  Flashcard get current => _flashcards[_currentIndex];

  // Method to load flashcards and shuffle them
  void load(List<Flashcard> flashcards) {
    _flashcards.clear();
    _flashcards.addAll(flashcards);
    _flashcards.shuffle();
    _prepareCard();
    notifyListeners();
  }

  // Get masked word with a hidden character
  String get maskedWord {
    final word = current.question;
    if (word.length < 2) return word;

    final chars = word.split('');
    if (_hiddenCharIndex >= chars.length) {
      // Default to 0 if the index is invalid
      _hiddenCharIndex = 0;
    }
    chars[_hiddenCharIndex] = '_';
    return chars.join('');
  }

  // Getters for the game state
  bool get submitted => _submitted;
  bool get isCorrect => _isCorrect;
  String get userInput => _userInput;

  // Update the user's input
  void updateInput(String value) {
    _userInput = value;
    notifyListeners();
  }

  // Submit the user's guess
  void submit() {
    if (_userInput.isNotEmpty &&
        _userInput.toLowerCase() == current.question[_hiddenCharIndex].toLowerCase()) {
      _isCorrect = true;
    } else {
      _isCorrect = false;
    }
    _submitted = true;
    notifyListeners();
  }

  // Move to the next flashcard
  void next() {
    if (_currentIndex < _flashcards.length - 1) {
      _currentIndex++;
      _prepareCard();
    } else {
      _submitted = false;
      _isCorrect = false;
    }
    notifyListeners();
  }

  // Prepare the card for the game
  void _prepareCard() {
    _submitted = false;
    _isCorrect = false;
    _userInput = '';
    if (current.question.length > 1) {
      _hiddenCharIndex = _randomIndex(current.question.length);
    } else {
      _hiddenCharIndex = 0; // For short words, hide the first character
    }
  }

  // Generate a random index for hiding a character
  int _randomIndex(int length) {
    if (length < 2) return 0; // For very short words
    final rand = Random();
    return rand.nextInt(length);
  }

  // Notify listeners of state change
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
