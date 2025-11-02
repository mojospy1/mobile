import 'package:apphoctienganh/home/SpeechProvider';
import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'BigFlashcardProvider.dart';
import 'package:flip_card/flip_card.dart';

class BigFlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const BigFlashcardScreen({super.key, required this.flashcards});

  @override
  _BigFlashcardScreenState createState() => _BigFlashcardScreenState();
}

class _BigFlashcardScreenState extends State<BigFlashcardScreen> {
  @override
  void initState() {
    super.initState();
    // Load flashcards into the provider when the screen is initialized
    context.read<BigFlashcardProvider>().load(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<BigFlashcardProvider>();

    String question = flashcardProvider.currentFlashcard.question;
    String answer = flashcardProvider.currentFlashcard.answer;
    String? pathimagequesion = flashcardProvider.currentFlashcard.questionImage;
    String? pathimageanswer = flashcardProvider.currentFlashcard.answerImage;

    return Scaffold(
      appBar: AppBar(title: const Text("Học Flashcard")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FlipCard to flip between question and answer
              FlipCard(
                front: _buildCard(question, pathimagequesion),
                back: _buildCard(answer, pathimageanswer),
              ),
              const SizedBox(height: 32),
              // Hiển thị số lượng thẻ yêu thích và chưa yêu thích dưới flashcard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFavoriteCountWidget(
                      flashcardProvider.countFavorited,
                      Colors.green[200]!,
                    ),
                    _buildFavoriteCountWidget(
                      flashcardProvider.countNotFavorited,
                      Colors.red[200]!,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Favorite and sound buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      flashcardProvider.isFavorited
                          ? Icons.star
                          : Icons.star_border,
                      color:
                          flashcardProvider.isFavorited
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    onPressed: () {
                      flashcardProvider.toggleFavorite();
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      context.read<SpeechProvider>().speakText(question, true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.navigate_before, size: 50),
                    onPressed:
                        flashcardProvider.isFirstCard
                            ? null
                            : () {
                              flashcardProvider.previousCard();
                            },
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next, size: 50),
                    onPressed:
                        flashcardProvider.isLastCard
                            ? null
                            : () {
                              flashcardProvider.nextCard();
                            },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display current card index
              Text(
                '${flashcardProvider.currentIndex + 1} / ${flashcardProvider.totalCards}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCountWidget(int count, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3), // Làm màu nhạt hơn
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCard(String text, String? pathImage) {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Phần văn bản chiếm 50%
          Expanded(
            flex: 1, // Chiếm 1 phần
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
          // Phần hình ảnh chiếm 50%
          if (pathImage != null)
            Expanded(
              flex: 1, // Chiếm 1 phần
              child: Image.network(
                pathImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover, // Đảm bảo ảnh không bị méo
              ),
            ),
        ],
      ),
    );
  }
}
