import 'package:apphoctienganh/Authencation/profile.dart';
import 'package:apphoctienganh/Flashcash/createflashcard.dart';
import 'package:apphoctienganh/home/home.dart';
import 'package:apphoctienganh/Flashcash/FlashcardProvider.dart';
import 'package:apphoctienganh/Flashcash/chatbox.dart';
import 'package:apphoctienganh/Flashcash/flashcard_item_widget.dart';
import 'package:apphoctienganh/model/listflashcard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditFlashCard extends StatefulWidget {
  final FlashcardList flashcardList;
  const EditFlashCard({super.key, required this.flashcardList});

  @override
  State<EditFlashCard> createState() => _EditFlashCardState();
}

class _EditFlashCardState extends State<EditFlashCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<FlashcardProvider>().loadData(widget.flashcardList.flashcards);
    // đổ dữ liệu vô cho cái thẻ
    _titleController.text = widget.flashcardList.title;
    _descriptionController.text = widget.flashcardList.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sửa Flashcard", style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () async {
                // Lấy giá trị từ các trường tiêu đề và mô tả
                String title = _titleController.text;
                String description = _descriptionController.text;

                // Gọi hàm lưu flashcard
                String result = await context
                    .read<FlashcardProvider>()
                    .saveForEditFlashcardListAsync(
                      id: widget.flashcardList.id,
                      title: title,
                      description: description,
                    );

                // Hiển thị kết quả
                ScaffoldMessenger.of(
                  // ignore: use_build_context_synchronously
                  context,
                ).showSnackBar(SnackBar(content: Text(result)));
                if (result == 'Cập nhật flashcard thành công!') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(83, 209, 197, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(color: Colors.cyan, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lưu lại ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(width: 5),
                  FaIcon(
                    FontAwesomeIcons.penToSquare,
                    color: Colors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                'Tiêu đề',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Viết tiêu đề',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Sự miêu tả',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 5),
              TextFormField(
                maxLines: null,
                minLines: 1,
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Viết miêu tả',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,

                        builder: (context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.9,
                              child: GeminiChatScreen(),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline),
                        SizedBox(width: 10),
                        Text(
                          "Tạo Flashcard bằng AI",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Danh sách Flashcard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              Consumer<FlashcardProvider>(
                builder: (context, myProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: myProvider.flashcardList.length,
                    itemBuilder: (context, index) {
                      final flashcard = myProvider.flashcardList[index];
                      return FlashcardItem_Widget(
                        key: ValueKey(flashcard.id),
                        flashcard: flashcard,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 45,
        height: 45,
        child: FloatingActionButton(
          onPressed: () {
            context.read<FlashcardProvider>().addFlashcard();
          },
          shape: CircleBorder(),
          backgroundColor: Color.fromRGBO(83, 209, 197, 1),
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          Widget nextPage;

          if (index == 0) {
            nextPage = HomePage();
          } else if (index == 1) {
            nextPage = CreateFlashcard();
          } else {
            nextPage = ProfileScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Flashcard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
