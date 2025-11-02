


import 'package:apphoctienganh/model/flashcard.dart';

class FlashcardList {
  String id;

  String title;

  String description;

  List<Flashcard> flashcards;

  String userId;

  // Chuyển từ Firebase -> FlashcardList
factory FlashcardList.fromMap(Map<String, dynamic> map) {
  return FlashcardList(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    flashcards: (map['flashcards'] as List)
        .map((item) => Flashcard.fromMap(item as Map<String, dynamic>))
        .toList(),
    userId: map['userId'] ?? '',
  );
}

// Chuyển từ FlashcardList -> Firebase
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'title': title,
    'description': description,
    'flashcards': flashcards.map((f) => f.toMap()).toList(),
    'userId': userId,
  };
}

  FlashcardList({
    required this.id,
    required this.title,
    required this.description,
    required this.flashcards,
    required this.userId,
  });
}
