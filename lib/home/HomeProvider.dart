import 'package:apphoctienganh/model/flashcard.dart';
import 'package:apphoctienganh/model/listflashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  List<FlashcardList> _flashcardLists = [];
  List<FlashcardList> get flashcardLists => _flashcardLists;
  List<Flashcard> _originalFlashcards =
      []; // bản gốc trả về khi sắp xếp ở next stepcarrd
  

  

  

 Future<void> loadDataforsetstateinhomepage() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Kiểm tra xem người dùng có đăng nhập hay không
  if (currentUser == null) {
    _flashcardLists = []; 
    notifyListeners(); 
    return;
  }

  try {
    // Lấy dữ liệu từ Firestore, lọc theo userId
    final snapshot = await FirebaseFirestore.instance
        .collection('flashcardLists')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    // Chuyển đổi dữ liệu từ snapshot thành danh sách FlashcardList
    _flashcardLists = snapshot.docs
        .map((doc) => FlashcardList.fromMap(doc.data()))
        .toList();

    notifyListeners();
  } catch (e) {
    _flashcardLists = [];
    notifyListeners();
  }
}


  // xóa bộ flashcard
  Future<void> deleteFlashcardListById(String id) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('flashcardLists')
        .where('id', isEqualTo: id)
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('flashcardLists')
          .doc(doc.id)
          .delete();
    }

    _flashcardLists.removeWhere((list) => list.id == id);
    notifyListeners();
  } catch (e) {
    print('Lỗi khi xóa flashcard list: $e');
  }
}


  // viết cho  screen netstepcard

  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;

  // Lấy danh sách flashcards
  List<Flashcard> get flashcards => _flashcards;

  // Lấy chỉ số thẻ flashcard hiện tại
  int get currentIndex => _currentIndex;

  // Cập nhật danh sách flashcards
  void setFlashcards(List<Flashcard> flashcards) {
    _flashcards = [...flashcards];
    _originalFlashcards = [...flashcards];
    _currentIndex = 0;
  }

  // Di chuyển đến thẻ kế tiếp
  void nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _currentIndex = 0;
      notifyListeners();
    }
  }

  // Di chuyển về thẻ trước
  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  // sắp xếp
  void sortlist(String type) {
    switch (type) {
      case 'A_Z':
        _flashcards.sort(
          (a, b) =>
              a.question.toLowerCase().compareTo(b.question.toLowerCase()),
        );
        break;
      case 'Z_A':
        _flashcards.sort(
          (a, b) =>
              b.question.toLowerCase().compareTo(a.question.toLowerCase()),
        );
        break;
      case 'default':
        _flashcards = [..._originalFlashcards];
        break;
    }
    notifyListeners();
  }
}
   // viết cho  screen netstepcard 


