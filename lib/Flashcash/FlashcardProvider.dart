import 'dart:convert';
import 'dart:io';
import 'package:apphoctienganh/model/flashcard.dart';
import 'package:apphoctienganh/model/listflashcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FlashcardProvider with ChangeNotifier {
  List<Flashcard> _flashcards = [
    Flashcard(
      id: const Uuid().v4(),
      question: "",
      answer: "",
      questionImage: null,
      answerImage: null,
    ),
  ];
  List<Flashcard> get flashcardList => _flashcards;
  set flashcardListset(List<Flashcard> newList) {
    _flashcards = newList;
  }

  final ImagePicker _picker = ImagePicker();

  Set<String> loadingFlashcards =
      {}; // vòng xoay ở nút ask gemini lưu vào đây tí xong thì remove

  // add new flashcard
  void addFlashcard() {
    _flashcards.add(
      Flashcard(
        id: const Uuid().v4(),
        question: "",
        answer: "",
        questionImage: null,
        answerImage: null,
      ),
    );
    notifyListeners();
  }

  void deleteFlashcardById(String id) {
    _flashcards.removeWhere((flashcard) => flashcard.id == id);
    notifyListeners();
  }

  // Tạo thư mục lưu ảnh
  Future<Directory> getAppImageDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imageDirPath = path.join(appDocDir.path, 'imageapplearnenglish');
    final imageDir = Directory(imageDirPath);
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  // Hàm chọn ảnh và tải lên Imgur
  Future<void> pickImage(String id, {required bool isQuestion}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final imageFile = File(pickedFile.path);
        final imageBytes = await imageFile.readAsBytes();
        final imageBase64 = base64Encode(imageBytes);

        // Gửi ảnh lên Imgur và lấy URL
        final url = await uploadImageToImgur(imageBase64);

        // Cập nhật Flashcard với URL ảnh
        final index = _flashcards.indexWhere((fc) => fc.id == id);
        if (index != -1) {
          if (isQuestion) {
            _flashcards[index].questionImage = url;
          } else {
            _flashcards[index].answerImage = url;
          }
          notifyListeners();
        }
      } catch (e) {
        print('Lỗi tải ảnh lên Imgur: $e');
      }
    }
  }

  // Hàm tải ảnh lên Imgur và nhận URL
  Future<String> uploadImageToImgur(String imageBase64) async {
    final clientId = '7f778aa3b39f7ab';
    final headers = {
      'Authorization': 'Client-ID $clientId',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'image': imageBase64, 'type': 'base64'});

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/upload'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['link']; // Trả về URL của ảnh
    } else {
      throw Exception('Không thể tải ảnh lên Imgur');
    }
  }

  // Xóa ảnh câu hỏi
  void removeQuestionImage(String id) {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      _flashcards[index].questionImage = null;
      notifyListeners();
    }
  }

  // Xóa ảnh câu trả lời
  void removeAnswerImage(String id) {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      _flashcards[index].answerImage = null;
      notifyListeners();
    }
  }

  //  save  onchange thuật ngữ và bản dịch
  void updateFlashcardContent({
    required String id,
    String? question,
    String? answer,
  }) {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      if (question != null) {
        _flashcards[index].question = question;
      } else if (answer != null) {
        _flashcards[index].answer = answer;
      }
      notifyListeners();
    }
  }

  Future<void> updateFlashcardByGemini({required String id}) async {
    loadingFlashcards.add(id);
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index == -1) return;

    final old = _flashcards[index];

    // Lấy danh sách tất cả câu hỏi (từ vựng) hiện có trong flashcards
    final existingWords = _flashcards.map((fc) => fc.question).toList();

    if (old.answer.isEmpty && old.question.isNotEmpty) {
      final value = await Gemini.instance.prompt(
        parts: [
          Part.text(
            'Hãy giải thích thật ngắn gọn nghĩa tiếng Việt của từ "${old.question}". Chỉ trả lời nghĩa, không giải thích gì thêm.',
          ),
        ],
      );

      final result = value?.output?.trim();
      if (result != null && result.isNotEmpty) {
        _flashcards[index] = Flashcard(
          id: old.id,
          question: old.question,
          answer: result,
        );
        notifyListeners();
      }
    } else if (old.answer.isNotEmpty && old.question.isEmpty) {
      final value = await Gemini.instance.prompt(
        parts: [
          Part.text(
            'Hãy tìm một từ vựng tiếng Anh phù hợp với nghĩa tiếng Việt sau: "${old.answer}".Chỉ trả lời duy nhất từ vựng đó, không giải thích gì thêm, không ví dụ, không mô tả.',
          ),
        ],
      );

      final result = value?.output?.trim();
      if (result != null && result.isNotEmpty) {
        _flashcards[index] = Flashcard(
          id: old.id,
          answer: old.answer,
          question: result,
        );
        notifyListeners();
      }
    } else {
      // Tạo prompt yêu cầu Gemini tránh trùng với các từ vựng hiện có
      final existingWordsText =
          existingWords.isEmpty
              ? ""
              : "Dưới đây là một số từ vựng đã có. Đảm bảo không sử dụng những từ này khi tạo từ mới: ${existingWords.join(', ')}.";

      final value = await Gemini.instance.prompt(
        parts: [
          Part.text(
            'Hãy tạo một cặp từ vựng tiếng Anh và nghĩa tiếng Việt tương ứng random trong 36000 từ vựng thông dụng. Trả lời theo đúng định dạng: "từ - nghĩa". $existingWordsText .Không giải thích gì thêm .',
          ),
        ],
      );

      final result = value?.output?.trim();
      if (result != null && result.contains('-')) {
        final parts = result.split('-').map((e) => e.trim()).toList();
        if (parts.length == 2) {
          _flashcards[index] = Flashcard(
            id: old.id,
            question: parts[0],
            answer: parts[1],
          );
          notifyListeners();
        }
      }
    }

    await Future.delayed(Duration(milliseconds: 2000));

    loadingFlashcards.remove(id);
    notifyListeners();
  }

  bool isFlashcardLoading(String id) {
    return loadingFlashcards.contains(id);
  }

  // tạo flashcard with gemini
  void createFlashcardsFromGemini(String response, bool replace) {
    final result = response.trim();

    if (result.contains('-')) {
      final lines = result.split('\n');
      final newFlashcards =
          lines
              .map((line) {
                final parts = line.split('-').map((e) => e.trim()).toList();
                if (parts.length == 2) {
                  return Flashcard(
                    id: UniqueKey().toString(),
                    question: parts[0],
                    answer: parts[1],
                  );
                } else {
                  return null;
                }
              })
              .whereType<Flashcard>()
              .toList();

      if (replace) {
        _flashcards.clear();
      }

      _flashcards.addAll(newFlashcards);
      notifyListeners();
    }
  }

  // save  firebase

  Future<String> save_list_flashcard_async({
    required String title,
    String? description,
  }) async {
    try {
      // Kiểm tra xem _flashcards có dữ liệu hay không
      if (_flashcards.isEmpty) {
        return 'Danh sách flashcard không được trống!';
      }

      // Kiểm tra số lượng flashcard
      if (_flashcards.length < 2) {
        return 'Cần ít nhất 2 flashcard!';
      }

      // Kiểm tra xem title có hợp lệ không
      if (title.isEmpty) {
        return 'Tiêu đề không thể trống!';
      }

      // Duyệt qua từng flashcard và kiểm tra question và answer
      for (var flashcard in _flashcards) {
        if (flashcard.question.isEmpty || flashcard.answer.isEmpty) {
          return 'Mỗi flashcard phải có cả câu hỏi và câu trả lời!';
        }
      }

      // Lấy user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return 'Bạn chưa đăng nhập!';
      }

      // Tạo đối tượng FlashcardList
      FlashcardList item = FlashcardList(
        id: const Uuid().v4(),
        title: title,
        description: description ?? '',
        flashcards: _flashcards,
        userId: currentUser.uid,
      );

      // Lấy Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Thêm FlashcardList vào Firestore
      await firestore
          .collection('flashcardLists')
          .doc(item.id)
          .set(item.toMap());

      // Reset danh sách flashcards
      var newcard = [
        Flashcard(
          id: const Uuid().v4(),
          question: "",
          answer: "",
          questionImage: null,
          answerImage: null,
        ),
      ];
      _flashcards = newcard;
      notifyListeners();
      return 'Lưu flashcard thành công!';
    } catch (e) {
      return 'Đã xảy ra lỗi: $e';
    }
  }

  // cho edit
  void loadData(List<Flashcard> flashcards) {
    flashcardListset = flashcards;
  }

  Future<String> saveForEditFlashcardListAsync({
    required String id,
    required String title,
    String? description,
  }) async {
    try {
      // Kiểm tra danh sách flashcard có rỗng không
      if (_flashcards.isEmpty) {
        return 'Danh sách flashcard không được trống!';
      }

      // Kiểm tra số lượng flashcard
      if (_flashcards.length < 2) {
        return 'Cần ít nhất 2 flashcard!';
      }

      // Kiểm tra tiêu đề
      if (title.isEmpty) {
        return 'Tiêu đề không thể trống!';
      }

      // Kiểm tra từng flashcard có đầy đủ câu hỏi và câu trả lời không
      for (var flashcard in _flashcards) {
        if (flashcard.question.isEmpty || flashcard.answer.isEmpty) {
          return 'Mỗi flashcard phải có cả câu hỏi và câu trả lời!';
        }
      }

      // Lấy user hiện tại
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return 'Bạn chưa đăng nhập!';
      }

      // Tạo một đối tượng FlashcardList mới
      FlashcardList updatedItem = FlashcardList(
        id: id,
        title: title,
        description: description ?? '',
        flashcards: _flashcards, // Gán lại danh sách flashcard
        userId: currentUser.uid,
      );

      // Cập nhật dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection('flashcardLists')
          .doc(id) // Sử dụng ID của danh sách flashcard để tìm và cập nhật
          .update(updatedItem.toMap());

      // Reset danh sách flashcards
      var newcard = [
        Flashcard(
          id: const Uuid().v4(),
          question: "",
          answer: "",
          questionImage: null,
          answerImage: null,
        ),
      ];
      _flashcards = newcard;
      notifyListeners();

      return 'Cập nhật flashcard thành công!';
    } catch (e) {
      print('Error: $e');
      return 'Đã xảy ra lỗi: $e';
    }
  }
}
