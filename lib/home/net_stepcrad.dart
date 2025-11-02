import 'package:apphoctienganh/Flashcash/editflashcard.dart';
import 'package:apphoctienganh/game_learn/BigFlashcard.dart';
import 'package:apphoctienganh/game_learn/FillInTheBlank.dart';
import 'package:apphoctienganh/game_learn/QuestionAnswerScreen.dart';
import 'package:apphoctienganh/game_learn/QuizPage.dart';
import 'package:apphoctienganh/game_learn/WordScrambleScreen.dart';
import 'package:apphoctienganh/game_learn/popup.dart';
import 'package:apphoctienganh/game_learn/speakquestion.dart';
import 'package:apphoctienganh/game_learn/word_guessing_screen.dart';
import 'package:apphoctienganh/home/SpeechProvider';
import 'package:apphoctienganh/home/home.dart';
import 'package:apphoctienganh/model/listflashcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:apphoctienganh/home/HomeProvider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class FlashcardScreen extends StatefulWidget {
  final FlashcardList flashcardList;
  const FlashcardScreen({super.key, required this.flashcardList});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final List<GlobalKey<FlipCardState>> flipCardKeys = [];

  @override
  void initState() {
    super.initState();
    // Lưu danh sách flashcards vào provider khi màn hình được tạo
    context.read<HomeProvider>().setFlashcards(widget.flashcardList.flashcards);

    // Tạo flip card keys cho từng flashcard
    for (var i = 0; i < widget.flashcardList.flashcards.length; i++) {
      flipCardKeys.add(GlobalKey<FlipCardState>());
    }
  }

  // giao diện của cái card
  Widget _buildCard(String text, String? pathImage, bool isEnglish) {
    return Stack(
      children: [
        Container(
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
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (pathImage != null)
                  Expanded(child: Image.network(pathImage, fit: BoxFit.cover)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.volume_up),
            color: Colors.black54,
            onPressed: () {
              context.read<SpeechProvider>().speakText(text, isEnglish);
            },
          ),
        ),
      ],
    );
  }

  // flipcard
  Widget _buildFlashcard() {
    final homeProvider = context.watch<HomeProvider>();
    final flashcard = homeProvider.flashcards[homeProvider.currentIndex];
    return FlipCard(
      key: flipCardKeys[context.watch<HomeProvider>().currentIndex],
      direction: FlipDirection.HORIZONTAL,
      front: _buildCard(flashcard.question, flashcard.questionImage, true),
      back: _buildCard(flashcard.answer, flashcard.answerImage, false),
    );
  }

  // mở cái cửa sổ học để chọn các chế độ học khác nhau
  Widget _buildStudyOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ignore: unused_element của doanh
  void _showStudyOptions() {
    final colors = [
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Tiêu đề
                  Text(
                    'Học',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // GridView nội dung
                  Expanded(
                    child: GridView.count(
                      controller: scrollController,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuestionAnswerScreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.psychology,
                            'Học hỏi',
                            'Điền nghĩa từ vựng',
                            colors[0],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizPage(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.assignment,
                            'Bài luyện tập',
                            'Luyện tập trắc nghiệm',
                            colors[1],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WordGuessScreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.schedule,
                            'Đoán chữ',
                            'Đoán chữ còn thiếu',
                            colors[2],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Popupscreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.extension,
                            'Trò chơi ghép hình',
                            'Chọn hai cặp thẻ trùng nhau',
                            colors[3],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BigFlashcardScreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.style,
                            'Flashcards',
                            'Lật thẻ ghi nhớ',
                            colors[4],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizWithChoicesPage(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.ad_units,
                            'Điền vào chỗ trống',
                            'Điền từ vựng vào chỗ trống sao cho câu có nghĩa',
                            colors[5],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SpeechQuizScreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.mic,
                            'Học phát âm',
                            'Luyện phát âm từ vựng',
                            colors[5],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => WordScrambleScreen(
                                      flashcards:
                                          widget.flashcardList.flashcards,
                                    ),
                              ),
                            );
                          },
                          child: _buildStudyOption(
                            Icons.smart_toy,
                            'Xếp chữ',
                            'Xếp chữ phù hợp tạo từ vựng',
                            colors[5],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //dùng thư viện  rflutter_alert
  // ignore: unused_element
  void _showDeleteConfirm(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.error,
      style: AlertStyle(
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        descStyle: TextStyle(fontSize: 14, color: Colors.black54),
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
      title: "Xóa bộ flashcard này?",
      desc: "Bạn có chắc chắn muốn xóa không?",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
          child: Text(
            "Hủy",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<HomeProvider>().deleteFlashcardListById(
              widget.flashcardList.id,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          color: Colors.red,
          child: Text(
            "Xóa",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Flashcards"),
        actions: [
          // Nút Edit
          Container(
            padding: const EdgeInsets.all(1.0),
            width: 30.0,
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.edit_rounded, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditFlashCard(flashcardList: widget.flashcardList),
                  ),
                );
              },
            ),
          ),
          // nút delete
          Container(
            padding: const EdgeInsets.all(1.0),
            width: 40.0,
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.delete_forever_rounded, color: Colors.black),
              onPressed: () {
                _showDeleteConfirm(context);
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),

            // Flashcard view
            SizedBox(height: 300, child: Center(child: _buildFlashcard())),

            // Nút nhấn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    iconSize: 26,
                    onPressed: context.read<HomeProvider>().previousCard,
                  ),
                  // mấy nút chấm khi next slide
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      context.watch<HomeProvider>().flashcards.length > 5
                          ? 5
                          : context.watch<HomeProvider>().flashcards.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 16,
                        ),
                        width:
                            context.watch<HomeProvider>().currentIndex == index
                                ? 10
                                : 6,
                        height:
                            context.watch<HomeProvider>().currentIndex == index
                                ? 10
                                : 6,
                        decoration: BoxDecoration(
                          color:
                              context.watch<HomeProvider>().currentIndex ==
                                      index
                                  ? Colors.black
                                  : Color(0xFFD6D6D6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    iconSize: 26,
                    onPressed: context.read<HomeProvider>().nextCard,
                  ),
                ],
              ),
            ),

            // card
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Thuật ngữ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      context.read<HomeProvider>().sortlist(value);
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'default',
                            child: Center(child: Text('Theo thứ tự gốc')),
                          ),
                          const PopupMenuItem<String>(
                            value: 'A_Z',
                            child: Center(child: Text('Theo chữ cái A-Z')),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Z_A',
                            child: Center(child: Text('Theo chữ cái Z-A')),
                          ),
                        ],
                    icon: Icon(Icons.sort),
                  ),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: context.watch<HomeProvider>().flashcards.length,
              itemBuilder: (context, index) {
                final flashcard =
                    context.watch<HomeProvider>().flashcards[index];
                return container_card(flashcard.question, flashcard.answer);
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),

      floatingActionButton: SizedBox(
        height: 46,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(83, 209, 197, 1),
            disabledBackgroundColor: Color.fromRGBO(83, 209, 197, 1),
          ),
          onPressed: _showStudyOptions,
          child: Text(
            'Thiết lập chế độ học tiếng Anh',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Container container_card(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minHeight: 130),
      child: Card(
        color: Colors.white,
        child: Padding(
          // Thêm Padding tổng thể để tránh tràn
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 17),
                      softWrap: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: Colors.black54,
                    onPressed: () {
                      context.read<SpeechProvider>().speakText(question, true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                answer,
                softWrap: true,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
