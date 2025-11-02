import 'package:apphoctienganh/game_learn/question_answer_provider.dart';
import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuestionAnswerScreen({super.key, required this.flashcards});

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

// ... giữ nguyên các import và class đầu

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<QuestionAnswerProvider>(
      context,
      listen: false,
    );
    controller = TextEditingController(text: provider.userAnswer);
    context.read<QuestionAnswerProvider>().loadData(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionAnswerProvider>(context);

    // Giữ đồng bộ controller với userAnswer
    controller.value = controller.value.copyWith(
      text: provider.userAnswer,
      selection: TextSelection.collapsed(offset: provider.userAnswer.length),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      resizeToAvoidBottomInset: true, // ✅ để bàn phím không vỡ layout
      appBar: AppBar(
        title: const Text("Sắp xong"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.currentCard.question,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: controller,
                      onChanged: provider.updateAnswer,
                      decoration: InputDecoration(
                        hintText: 'Nhập câu trả lời của bạn',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                provider.submitted
                                    ? provider.isCorrect
                                        ? Colors.green
                                        : Colors.red
                                    : Colors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                provider.submitted
                                    ? provider.isCorrect
                                        ? Colors.green
                                        : Colors.red
                                    : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (provider.submitted && !provider.isCorrect) ...[
                      const Text(
                        "Bạn đã nhập:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          provider.userAnswer,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Câu trả lời đúng là:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FAF1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          provider.currentCard.answer,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF12B886),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.checkAnswer,
                      child: const Text("Xác nhận"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final continued = provider.nextQuestion();
                        if (!continued) {
                          Alert(
                            context: context,
                            type: AlertType.success,
                            title: "Kết thúc bài kiểm tra!",
                            desc:
                                "Điểm của bạn: ${provider.score}/${provider.cards.length}",
                            buttons: [
                              DialogButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                width: 120,
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ).show();
                        }
                      },
                      child: const Text("Câu hỏi tiếp theo"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
