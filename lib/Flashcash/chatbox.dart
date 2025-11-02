import 'package:apphoctienganh/Flashcash/FlashcardProvider.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});
  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(id: "user");
  String? _lastGeminiOutput;
  final ChatUser _gemini = ChatUser(
    id: "gemini",
    firstName: "Trợ lý ảo",
    profileImage: "assets/logoapp.png",
  );
  bool showbutton = false;

  bool _isTyping = false;
  void _sendMessage(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    String userInput = message.text.toLowerCase();

    // Từ khóa hành động
    final actionKeywords = [
      "tạo",
      "tao",
      "create",
      "make",
      "generate",
      "làm",
      "học",
      "cho tôi",
      "giúp tôi",
    ];

    // Từ khóa chủ đề
    final vocabKeywords = [
      "từ",
      "từ vựng",
      "tu vung",
      "từ vựng tiếng anh",
      "flashcard",
      "vocabulary",
      "english vocabulary",
      "english flashcard",
      "learn vocabulary",
      "make flashcard",
      "create flashcard",
    ];

    final hasActionKeyword = actionKeywords.any((kw) => userInput.contains(kw));
    final hasVocabKeyword = vocabKeywords.any((kw) => userInput.contains(kw));

    String promptToSend;

    if (hasActionKeyword && hasVocabKeyword) {
      promptToSend = '''
Bạn là trợ lý học tiếng Anh. Hãy tạo flashcard từ vựng tiếng Anh theo định dạng:
Từ - Nghĩa tiếng Việt
Không giải thích gì thêm, không thêm mô tả.
không được có kí tự đặc biệt như * bao bọc cặp từ 
Chỉ liệt kê danh sách từ - nghĩa và tối đa 15 cặp từ. Nếu yêu cầu không có số lượng cụ thể, chỉ tạo 10 cặp từ.
Nếu yêu cầu số lượng vượt quá 15, hãy tạo tối đa 15 cặp từ.
Sau đây là yêu cầu của bạn: "${message.text}"
''';
      showbutton = true; // mở button
    } else {
      promptToSend = message.text;
      showbutton = false;
    }

    final response = await Gemini.instance.prompt(
      parts: [Part.text(promptToSend)],
    );

    final output = response?.output?.trim() ?? "Không có phản hồi từ Gemini";
    _lastGeminiOutput = output; // cho biến toàn cục tí  lấy
    final reply = ChatMessage(
      text: output,
      user: _gemini,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, reply);
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/logoapp.png"),
                ),
                const SizedBox(height: 2),
                const Text('Trợ lý ảo', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: DashChat(
              currentUser: _user,
              onSend: _sendMessage,
              messages: _messages,
              typingUsers: _isTyping ? [_gemini] : [],
              inputOptions: InputOptions(
                sendOnEnter: true,
                alwaysShowSend: true,
                inputDecoration: InputDecoration(
                  hintText: "Nhập câu hỏi...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              messageOptions: const MessageOptions(
                showOtherUsersName: true,
                showOtherUsersAvatar: true,
              ),
            ),
          ),
        ],
      ),

      floatingActionButton:
          showbutton
              ? Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Thêm Flashcard',
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Color.fromRGBO(216, 143, 209, 1),
                        onPressed: () {
                          context
                              .read<FlashcardProvider>()
                              .createFlashcardsFromGemini(
                                _lastGeminiOutput.toString(),
                                false,
                              );
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.add, size: 18),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Tooltip(
                      message: 'Thay thế toàn bộ flashcard',
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Color.fromRGBO(83, 209, 197, 1),
                        onPressed: () {
                          context
                              .read<FlashcardProvider>()
                              .createFlashcardsFromGemini(
                                _lastGeminiOutput.toString(),
                                true,
                              );
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.change_circle, size: 18),
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}
