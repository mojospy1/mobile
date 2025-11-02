import 'package:flutter/material.dart';
import 'package:apphoctienganh/model/flashcard.dart';

class BigFlashcardProvider with ChangeNotifier {
  // Danh sách các thẻ flashcard
  final List<Flashcard> _Flashcard = [];

  void load(List<Flashcard> flashcards) {
    _Flashcard.clear();
    _Flashcard.addAll(flashcards);

    // Update _isFavoritedList dynamically based on the number of flashcards
    _isFavoritedList.clear();
    _isFavoritedList.addAll(List.generate(flashcards.length, (index) => false));
  }

  // Danh sách trạng thái yêu thích cho từng thẻ
  final List<bool> _isFavoritedList = [];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  int get totalCards => _Flashcard.length;

  // Trả về thẻ flashcard hiện tại
  Flashcard get currentFlashcard => _Flashcard[_currentIndex];

  bool get isLastCard => _currentIndex == _Flashcard.length - 1;
  bool get isFirstCard => _currentIndex == 0;
  List<Flashcard> get questions => _Flashcard;

  // Chuyển tới thẻ tiếp theo
  void nextCard() {
    if (_currentIndex < _Flashcard.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  // Quay lại thẻ trước
  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  // Đánh dấu yêu thích cho thẻ hiện tại
  bool get isFavorited =>
      _isFavoritedList.isNotEmpty && _isFavoritedList[_currentIndex];
  void toggleFavorite() {
    if (_isFavoritedList.isNotEmpty) {
      _isFavoritedList[_currentIndex] = !_isFavoritedList[_currentIndex];
      notifyListeners();
    }
  }

  // Đếm số lượng thẻ đã yêu thích
  int get countFavorited => _isFavoritedList.where((isFav) => isFav).length;

  // Đếm số lượng thẻ chưa yêu thích
  int get countNotFavorited => _isFavoritedList.where((isFav) => !isFav).length;
}
