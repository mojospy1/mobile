

class Flashcard {
  String id;

  String question;

  String answer;

  String? questionImage;

  String? answerImage;
  //  Chuyển từ Map Firebase sang Flashcard
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      questionImage: map['questionImage'],
      answerImage: map['answerImage'],
    );
  }

  //  Chuyển từ Flashcard sang Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'questionImage': questionImage,
      'answerImage': answerImage,
    };
  }

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
  });
}
