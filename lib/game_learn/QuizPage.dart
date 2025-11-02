import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'quizprovider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class QuizPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuizPage({super.key, required this.flashcards});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<List<String>> generateAnswersWithGemini(
    String question,
    String correctAnswer,
  ) async {
    final response = await Gemini.instance.prompt(
      parts: [
        Part.text(''' 
Bạn là một trợ lý tạo câu hỏi trắc nghiệm. Hãy tạo ra 3 đáp án sai cho câu hỏi sau: "$question", biết rằng đáp án đúng là "$correctAnswer". 
Chỉ trả về danh sách 3 đáp án sai, mỗi dòng một đáp án, không thêm mô tả hay số thứ tự.
      '''),
      ],
    );

    print("Gemini response: ${response?.output}");

    final output = response?.output;
    if (output == null) {
      throw Exception("Gemini không phản hồi hoặc output rỗng.");
    }

    final lines = output.trim().split('\n');
    final wrongAnswers =
        lines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // Thêm câu trả lời đúng vào danh sách
    wrongAnswers.add(correctAnswer);

    // Trộn danh sách để câu trả lời đúng không ở vị trí cố định
    wrongAnswers.shuffle();

    return wrongAnswers
        .take(4)
        .toList(); // Lấy 4 câu trả lời (bao gồm câu đúng)
  }

  void _handleAnswer(BuildContext context, String selectedAnswer) {
    final quizProvider = context.read<QuizProvider>();

    final isCorrect = quizProvider.isCorrect(selectedAnswer);

    // Tạo overlay
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green[600] : Colors.red[600],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isCorrect
                        ? 'Chính xác! Bạn đã chọn đáp án đúng.'
                        : 'Sai rồi. Vui lòng thử lại.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    // Ẩn sau 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      entry.remove();

      if (!quizProvider.isLastQuestion) {
        quizProvider.nextQuestion();
      } else {
        Alert(
          context: context,
          type: AlertType.success,
          title: "Quiz Completed!",
          desc: "Bạn có ${quizProvider.incorrectAnswers} đáp án sai.",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              width: 120,
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ).show();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Load flashcards into the provider when the screen is initialized
    context.read<QuizProvider>().load(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final question = quizProvider.currentflashcard;

    return Scaffold(
      appBar: AppBar(title: const Text("Câu hỏi trắc nghiệm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value:
                  (quizProvider.currentIndex + 1) /
                  quizProvider.allflashcard.length,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: generateAnswersWithGemini(
                question.question,
                question.answer,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final options = snapshot.data!;
                return Column(
                  children:
                      options.map((opt) {
                        return OptionButton(
                          text: opt,
                          onPressed: () => _handleAnswer(context, opt),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OptionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
