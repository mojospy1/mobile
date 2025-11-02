import 'package:apphoctienganh/game_learn/FillInTheBlankProvider.dart';
import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuizWithChoicesPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuizWithChoicesPage({super.key, required this.flashcards});

  @override
  State<QuizWithChoicesPage> createState() => _QuizWithChoicesPageState();
}

class _QuizWithChoicesPageState extends State<QuizWithChoicesPage> {
  late List<String> shuffledOptions;
  String? selectedAnswer;
  late Future<String> sentenceFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FillInTheBlankProvider>();
    provider.loadData(widget.flashcards);
    sentenceFuture = generateClozeSentence();
    shuffledOptions = _generateOptions();
  }

  Future<String> generateClozeSentence() async {
    final word = context.read<FillInTheBlankProvider>().currentQuestion.word;
    final response = await Gemini.instance.prompt(
      parts: [
        Part.text('''
Tạo một câu tiếng Anh có nghĩa, trong đó từ "$word" được thay bằng dấu ___.
Chỉ trả về câu đó, không cần giải thích. Ví dụ: "He opened the ___ and took out a book."
'''),
      ],
    );

    return response?.output?.trim().replaceAll('"', '') ?? '___';
  }

  List<String> _generateOptions() {
    final provider = context.read<FillInTheBlankProvider>();
    final correctWord = provider.currentQuestion.word;
    final allWords = provider.allQuestions.map((q) => q.word).toList();

    // Lấy ra 2 đáp án sai ngẫu nhiên (không trùng đáp án đúng)
    final wrongOptions =
        allWords.where((word) => word != correctWord).toList()..shuffle();

    final choices = [correctWord, ...wrongOptions.take(2)];
    choices.shuffle(); // trộn lại để random vị trí đúng
    return choices;
  }

  void _submitAnswer() {
    final provider = context.read<FillInTheBlankProvider>();
    final isCorrect =
        selectedAnswer?.toLowerCase().trim() ==
        provider.currentQuestion.word.toLowerCase();

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
                        ? ' Chính xác! Bạn đã chọn đáp án đúng.'
                        : ' Sai rồi! Từ đúng là: "${provider.currentQuestion.word}"',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    Future.delayed(Duration(seconds: 2), () {
      entry.remove();

      if (provider.isLastQuestion) {
        Alert(
          context: context,
          type: AlertType.success,
          title: "Hoàn thành!",
          desc:
              "Bạn đã hoàn thành tất cả câu hỏi.\nSố câu sai: ${provider.incorrectAnswers}",
          buttons: [
            DialogButton(
              onPressed: () {
                provider.resetQuiz();
                setState(() {
                  sentenceFuture = generateClozeSentence();
                  shuffledOptions = _generateOptions();
                  selectedAnswer = null;
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Chơi lại",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ).show();
      } else {
        provider.nextQuestion();
        setState(() {
          sentenceFuture = generateClozeSentence();
          shuffledOptions = _generateOptions();
          selectedAnswer = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FillInTheBlankProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Điền vào chỗ trống")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (provider.currentIndex + 1) / provider.allQuestions.length,
              color: Colors.teal,
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: sentenceFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...shuffledOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: selectedAnswer,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswer = value;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: selectedAnswer != null ? _submitAnswer : null,
                      child: const Text("Xác nhận"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
