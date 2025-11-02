import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechQuestion {
  final String id;
  final String question;

  SpeechQuestion({required this.id, required this.question});
}

class SpeechQuestionProvider with ChangeNotifier {
  final List<SpeechQuestion> _questions = []; // KHÔNG FIX CỨNG NỮA!

  int _currentIndex = 0;
  int _incorrectAnswers = 0;
  String _spokenText = '';
  bool _isListening = false;

  final stt.SpeechToText _speech = stt.SpeechToText();

  int get currentIndex => _currentIndex;
  int get incorrectAnswers => _incorrectAnswers;
  String get spokenText => _spokenText;
  bool get isListening => _isListening;

  List<SpeechQuestion> get allQuestions => _questions;
  SpeechQuestion get currentQuestion => _questions[_currentIndex];

  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          _spokenText = result.recognizedWords;
          notifyListeners();
        },
      );
    } else {
      _isListening = false;
      _speech.stop();
    }
    notifyListeners();
  }

  void loadData(List<Flashcard> flashcards) {
    _questions.clear();
    _questions.addAll(
      flashcards.map(
        (flashcard) => SpeechQuestion(
          id: flashcard.id,
          question:
              flashcard
                  .question, // Hoặc flashcard.answer nếu ông chủ muốn điền đáp án
        ),
      ),
    );
    _currentIndex = 0;
    _spokenText = '';
    _incorrectAnswers = 0;
    notifyListeners();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  bool checkAnswer() {
    final expected = _removePunctuation(
      currentQuestion.question.toLowerCase().trim(),
    );
    final spoken = _removePunctuation(_spokenText.toLowerCase().trim());
    bool isCorrect = expected == spoken;
    if (!isCorrect) _incorrectAnswers++;
    return isCorrect;
  }

  String _removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentIndex++;
      _spokenText = '';
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentIndex = 0;
    _incorrectAnswers = 0;
    _spokenText = '';
    notifyListeners();
  }
}
