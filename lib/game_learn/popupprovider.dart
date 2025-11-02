import 'package:flutter/material.dart';
import 'package:apphoctienganh/model/flashcard.dart';

class Popupprovider extends ChangeNotifier {
  List<Flashcard> _flashcards = [];
  List<Flashcard> get flashcards => _flashcards;

  // Đảm bảo rằng biến vẫn là Set<int>
  final Set<int> _matchedIndexes = {};
  final Set<int> _selectedIndexes = {};
  final Set<int> _incorrectIndexes = {};

  // Và các getter không thay đổi:
  Set<int> get matchedIndexes => _matchedIndexes;
  Set<int> get selectedIndexes => _selectedIndexes;
  Set<int> get incorrectIndexes => _incorrectIndexes;

  void loadInitialFlashcards(List<Flashcard> flashcard) {
    // Lưu tạm flashcards gốc từ list đầu tiên
    final original = flashcard;

    // Gọi lại như trong hàm loadData nhưng từ firstList
    _flashcards = [];
    for (var card in original) {
      _flashcards.add(
        Flashcard(
          id: '${card.id}_q',
          question: card.question,
          answer: card.answer,
          questionImage: card.questionImage,
          answerImage: card.answerImage,
        ),
      );
      _flashcards.add(
        Flashcard(
          id: '${card.id}_a',
          question: card.question,
          answer: card.answer,
          questionImage: card.questionImage,
          answerImage: card.answerImage,
        ),
      );
    }

    _flashcards.shuffle();
  }

  void selectCard(int index) {
    if (_selectedIndexes.contains(index) || _matchedIndexes.contains(index))
      return;

    _selectedIndexes.add(index);
    notifyListeners(); // cập nhật UI khi chọn

    if (_selectedIndexes.length == 2) {
      Future.delayed(Duration(milliseconds: 500), () {
        final selected = _selectedIndexes.toList();
        final firstIndex = selected[0];
        final secondIndex = selected[1];

        final firstCard = _flashcards[firstIndex];
        final secondCard = _flashcards[secondIndex];

        // Tách ID gốc ra để so sánh
        String normalizeId(String id) =>
            id.replaceAll('_q', '').replaceAll('_a', '');

        if (normalizeId(firstCard.id) == normalizeId(secondCard.id) &&
            firstCard.id != secondCard.id) {
          // Trùng ID gốc và không giống hệt nhau (phải là một câu và một đáp án)
          _matchedIndexes.addAll([firstIndex, secondIndex]);
          notifyListeners();

          Future.delayed(Duration(milliseconds: 800), () {
            _removeMatchedCards(firstIndex, secondIndex);
            _selectedIndexes.clear(); // Xóa sau khi remove
            notifyListeners();
          });
        } else {
          _incorrectIndexes.addAll([firstIndex, secondIndex]);
          notifyListeners();

          Future.delayed(Duration(milliseconds: 800), () {
            _selectedIndexes.clear();
            _incorrectIndexes.clear();
            notifyListeners();
          });
        }
      });
    }
  }

  void _removeMatchedCards(int index1, int index2) {
    final indexes = [index1, index2]..sort(); // Đảm bảo index1 < index2
    final removedIndex1 = indexes[0];
    final removedIndex2 = indexes[1];

    // Ghi nhận cặp đúng trước khi xoá
    _matchedIndexes.addAll([removedIndex1, removedIndex2]);

    // Xoá flashcard (index lớn hơn phải xoá trước)
    _flashcards.removeAt(removedIndex2);
    _flashcards.removeAt(removedIndex1);

    // Xóa các index đã bị xoá ra khỏi các set
    _matchedIndexes.removeAll([removedIndex1, removedIndex2]);
    _incorrectIndexes.removeAll([removedIndex1, removedIndex2]);
    _selectedIndexes.clear();

    // ✅ Cập nhật lại index các set
    final newMatched = _adjustIndexesAfterRemoval(
      _matchedIndexes,
      removedIndex1,
      removedIndex2,
    );
    final newIncorrect = _adjustIndexesAfterRemoval(
      _incorrectIndexes,
      removedIndex1,
      removedIndex2,
    );

    _matchedIndexes
      ..clear()
      ..addAll(newMatched);

    _incorrectIndexes
      ..clear()
      ..addAll(newIncorrect);

    notifyListeners();
  }

  Set<int> _adjustIndexesAfterRemoval(Set<int> oldIndexes, int i1, int i2) {
    Set<int> newSet = {};
    for (int i in oldIndexes) {
      if (i < i1) {
        newSet.add(i);
      } else if (i > i2) {
        newSet.add(i - 2);
      } else if (i > i1 && i < i2) {
        newSet.add(i - 1);
      }
      // else: bị xóa, bỏ qua
    }
    return newSet;
  }
}
