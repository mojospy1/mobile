import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apphoctienganh/Flashcash/FlashcardProvider.dart';

class ImagePickerButton extends StatelessWidget {
  final bool isQuestionImage; // true nếu là ảnh câu hỏi
  final String idFlashcard;

  const ImagePickerButton({
    super.key,
    required this.isQuestionImage,
    required this.idFlashcard,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final flashcard = provider.flashcardList.firstWhere(
          (fc) => fc.id == idFlashcard,
          orElse: () => throw Exception('Flashcard not found'),
        );

        final imagePath =
            isQuestionImage ? flashcard.questionImage : flashcard.answerImage;

        return imagePath == null
            ? IconButton(
                icon: const Icon(Icons.add_a_photo, size: 30),
                onPressed: () {
                  // Gọi hàm pickImage với tham số `isQuestion` được truyền vào
                  provider.pickImage(
                    idFlashcard,
                    isQuestion: isQuestionImage, // isQuestionImage sẽ quyết định xem là ảnh câu hỏi hay câu trả lời
                  );
                },
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9), // bo góc nếu muốn
                    child: Image.network(
                      imagePath, 
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        isQuestionImage
                            ? provider.removeQuestionImage(idFlashcard)
                            : provider.removeAnswerImage(idFlashcard);
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
