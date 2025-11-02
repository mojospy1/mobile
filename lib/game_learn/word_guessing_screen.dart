import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/flashcard.dart';
import 'word_guessing_provider.dart';

class WordGuessScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const WordGuessScreen({super.key, required this.flashcards});

  @override
  _WordGuessScreenState createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WordGuessProvider>().load(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final card = context.watch<WordGuessProvider>().current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Đoán Từ', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // Ensure everything scrolls when keyboard is opened
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E1), // Vàng rất nhạt
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFFE082)), // Vàng nhạt
                  ),
                  child: Text(
                    'Đoán chữ cái bị ẩn:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037), // Nâu đậm
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Hiển thị từ đã ẩn
                Center(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFECB3),
                            Color(0xFFFFD54F),
                          ], // Vàng nhạt đến vàng
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        context.watch<WordGuessProvider>().maskedWord,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: Color(0xFF33691E), // Xanh lá đậm
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Input chữ cái (chỉ có 1 ký tự)
                if (!context.watch<WordGuessProvider>().submitted)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      maxLength: 1,
                      decoration: InputDecoration(
                        labelText: 'Nhập chữ cái',
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(83, 209, 197, 1),
                        ), // Xanh lá trung bình
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(83, 209, 197, 1),
                          ), // Xanh lá rất nhạt
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(83, 209, 197, 1),
                            width: 2,
                          ), // Xanh lá
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: "",
                        prefixIcon: Icon(
                          Icons.edit,
                          color: Color.fromRGBO(83, 209, 197, 1),
                        ), // Xanh lá
                      ),
                      onChanged: context.read<WordGuessProvider>().updateInput,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(83, 209, 197, 1), // Xanh lá đậm
                      ),
                    ),
                  ),
                const SizedBox(height: 25),

                // Nút Xác nhận / Tiếp theo
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        backgroundColor: Color.fromRGBO(83, 209, 197, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (context.read<WordGuessProvider>().submitted) {
                          context.read<WordGuessProvider>().next();
                        } else {
                          context.read<WordGuessProvider>().submit();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.watch<WordGuessProvider>().submitted
                                ? 'Tiếp theo'
                                : 'Xác nhận',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            context.watch<WordGuessProvider>().submitted
                                ? Icons.arrow_forward
                                : Icons.check,
                            size: 24, // Increased icon size
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Hiển thị kết quả sau khi submit
                if (context.watch<WordGuessProvider>().submitted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F8E9), // Xanh lá rất nhạt
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            context.watch<WordGuessProvider>().isCorrect
                                ? Color(0xFFAED581) // Xanh lá nhạt
                                : Color(0xFFFFCC80), // Cam nhạt
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              context.watch<WordGuessProvider>().isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  context.watch<WordGuessProvider>().isCorrect
                                      ? Color(0xFF689F38) // Xanh lá đậm
                                      : Color(0xFFEF6C00), // Cam đậm
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              context.watch<WordGuessProvider>().isCorrect
                                  ? 'Chính xác!'
                                  : 'Sai rồi!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    context.watch<WordGuessProvider>().isCorrect
                                        ? Color(0xFF689F38) // Xanh lá đậm
                                        : Color(0xFFEF6C00), // Cam đậm
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color(0xFFE0E0E0), height: 20),
                        Text(
                          'Từ đầy đủ: ${card.question}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723), // Nâu đậm
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nghĩa: ${card.answer}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037), // Nâu nhạt hơn
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
