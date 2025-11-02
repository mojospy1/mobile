import 'package:apphoctienganh/Flashcash/widget_Image_icon.dart';
import 'package:apphoctienganh/model/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:apphoctienganh/Flashcash/FlashcardProvider.dart';
import 'package:provider/provider.dart';

class FlashcardItem_Widget extends StatefulWidget {
  final Flashcard flashcard;
  final int index;

  const FlashcardItem_Widget({
    super.key,
    required this.flashcard,
    required this.index,
  });

  @override
  _FlashcardItem_WidgetState createState() => _FlashcardItem_WidgetState();
}

class _FlashcardItem_WidgetState extends State<FlashcardItem_Widget> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với giá trị ban đầu của flashcard
    _questionController = TextEditingController(
      text: widget.flashcard.question,
    );
    _answerController = TextEditingController(text: widget.flashcard.answer);
  }

  @override
  void didUpdateWidget(FlashcardItem_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra nếu flashcard đã thay đổi và cập nhật lại controller
    if (oldWidget.flashcard.question != widget.flashcard.question) {
      _questionController.text = widget.flashcard.question;
    }
    if (oldWidget.flashcard.answer != widget.flashcard.answer) {
      _answerController.text = widget.flashcard.answer;
    }
  }

  @override
  void dispose() {
    // Đừng quên dispose controller khi widget bị hủy
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: Text(
                            "${widget.index + 1}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<FlashcardProvider>()
                                  .updateFlashcardByGemini(
                                    id: widget.flashcard.id,
                                  );
                            },
                            child: Row(
                              children: [
                                // thêm loading
                                Consumer<FlashcardProvider>(
                                  builder: (context, provider, child) {
                                    final isLoading = provider
                                        .isFlashcardLoading(
                                          widget.flashcard.id,
                                        );
                                    return isLoading
                                        ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Row(
                                          children: [
                                            Icon(Icons.auto_awesome),
                                            SizedBox(width: 10),
                                            Text(
                                              "Ask Gemini",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<FlashcardProvider>()
                                  .deleteFlashcardById(widget.flashcard.id);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(0.5),
                            ),
                            child: Icon(
                              Icons.delete_forever_outlined,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      ImagePickerButton(
                        idFlashcard: widget.flashcard.id,
                        isQuestionImage: true,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _questionController,
                          onChanged: (value) {
                            context
                                .read<FlashcardProvider>()
                                .updateFlashcardContent(
                                  id: widget.flashcard.id,
                                  question: value,
                                );
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: 'Thuật ngữ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      ImagePickerButton(
                        idFlashcard: widget.flashcard.id,
                        isQuestionImage: false,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _answerController,
                          onChanged: (value) {
                            context
                                .read<FlashcardProvider>()
                                .updateFlashcardContent(
                                  id: widget.flashcard.id,
                                  answer: value,
                                );
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: 'Định nghĩa',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
